import { Hono } from "hono";
import { cors } from "hono/cors";

import { ensureSchema, pool } from "./src/db.js";
import { complete, listModels } from "./src/gateway.js";
import { getBytes, getText, putBytes, putText, signedGet } from "./src/storage.js";

const app = new Hono();

app.use("*", cors());

app.get("/", (c) =>
  c.json({ status: "success", message: "Welrent API is running" }),
);

app.get("/api/cars", async (c) => {
  await ensureSchema();
  const result = await pool.query(
    `SELECT id, name, slug, subtitle, photo_url, is_dark_mode, price
     FROM cars ORDER BY sort_order ASC, id ASC`,
  );
  return c.json(
    result.rows.map((row) => ({
      ...row,
      price: Number(row.price),
      is_dark_mode: Boolean(row.is_dark_mode),
    })),
  );
});

app.get("/api/vehicle/:slug", async (c) => {
  await ensureSchema();
  const slug = c.req.param("slug");
  const result = await pool.query(
    `SELECT id, name, slug, subtitle, photo_url, is_dark_mode, price
     FROM cars
     WHERE slug = $1 OR name = $2
     LIMIT 1`,
    [slug, slug.replaceAll("-", " ")],
  );
  const row = result.rows[0];
  if (!row) return c.json({ error: "Vehicle not found" }, 404);
  return c.json({
    ...row,
    price: Number(row.price),
    is_dark_mode: Boolean(row.is_dark_mode),
  });
});

app.get("/api/content", async (c) => {
  await ensureSchema();
  const result = await pool.query("SELECT key_name, value FROM site_content");
  const content: Record<string, string> = {};
  for (const row of result.rows) content[row.key_name] = row.value;
  return c.json(content);
});

app.get("/api/nav_footer", async (c) => {
  await ensureSchema();
  const navbar = await pool.query(
    "SELECT title, url FROM navbar_links ORDER BY sort_order ASC, id ASC",
  );
  const footerRows = await pool.query(
    "SELECT category, title, url FROM footer_links ORDER BY category, sort_order ASC, id ASC",
  );
  const footer: Record<string, Array<{ title: string; url: string }>> = {};
  for (const row of footerRows.rows) {
    const category = String(row.category);
    footer[category] ??= [];
    footer[category].push({ title: row.title, url: row.url });
  }
  return c.json({ navbar: navbar.rows, footer });
});

app.post("/api/auth/login", async (c) => {
  const input = await c.req.json<{ email?: string; password?: string }>();
  if (!input.email || !input.password) {
    return c.json({ error: "Invalid credentials" }, 401);
  }
  const header = Buffer.from(
    JSON.stringify({ alg: "HS256", typ: "JWT" }),
  ).toString("base64url");
  const payload = Buffer.from(
    JSON.stringify({
      sub: 1,
      email: input.email,
      exp: Math.floor(Date.now() / 1000) + 3600,
    }),
  ).toString("base64url");
  return c.json({
    token: `${header}.${payload}.local`,
    user: { id: 1, email: input.email },
  });
});

app.get("/api/rentals", async (c) => {
  await ensureSchema();
  const uid = c.req.query("uid") ?? "";
  if (!uid) return c.json({ error: "uid required" }, 400);
  const result = await pool.query(
    `SELECT booking_ref, car_name, car_image, start_date, end_date, days, price, status, location, created_at
     FROM rentals WHERE user_uid = $1 ORDER BY created_at DESC`,
    [uid],
  );
  return c.json({
    rentals: result.rows.map((row) => ({ ...row, price: Number(row.price) })),
  });
});

app.post("/api/rentals", async (c) => {
  await ensureSchema();
  const body = await c.req.json<{
    uid?: string;
    car_name?: string;
    car_image?: string;
    start_date?: string;
    end_date?: string;
    days?: number;
    price?: number;
    location?: string;
    status?: string;
  }>();
  for (const field of ["uid", "car_name", "start_date", "end_date", "days", "price"] as const) {
    if (body[field] === undefined || body[field] === "") {
      return c.json({ error: `Missing field: ${field}` }, 400);
    }
  }
  const ref = `WLR-${new Date().getFullYear()}-${Math.random().toString(36).slice(2, 7).toUpperCase()}`;
  const inserted = await pool.query(
    `INSERT INTO rentals (booking_ref, user_uid, car_name, car_image, start_date, end_date, days, price, status, location)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
     RETURNING id`,
    [
      ref,
      body.uid,
      body.car_name,
      body.car_image ?? null,
      body.start_date,
      body.end_date,
      body.days,
      body.price,
      body.status ?? "upcoming",
      body.location ?? null,
    ],
  );
  return c.json({ booking_ref: ref, id: inserted.rows[0].id });
});

app.get("/api/ai/models", async (c) => {
  try {
    return c.json(await listModels());
  } catch (error) {
    const message = error instanceof Error ? error.message : "AI Gateway failed";
    const status = message.includes("is required") ? 503 : 502;
    return c.json({ error: message }, status);
  }
});

app.post("/api/ai", async (c) => {
  const body = await c.req.json<{ prompt?: string }>().catch(() => ({ prompt: "" }));
  try {
    const text = await complete(body.prompt || "Reply with the single word ready.");
    return c.json({ text });
  } catch (error) {
    const message = error instanceof Error ? error.message : "AI Gateway failed";
    const status = message.includes("is required") ? 503 : 502;
    return c.json({ error: message }, status);
  }
});

app.post("/api/storage", async (c) => {
  const body = await c.req.json<{ key?: string; body?: string }>();
  if (!body.key || body.body === undefined) {
    return c.json({ error: "key and body are required" }, 400);
  }
  await putText(body.key, body.body);
  const url = await signedGet(body.key);
  return c.json({ key: body.key, url });
});

app.get("/api/storage", async (c) => {
  const key = c.req.query("key");
  if (!key) return c.json({ error: "key required" }, 400);
  const body = await getText(key);
  return c.json({ key, body });
});

app.post("/api/photos", async (c) => {
  const body = await c.req.json<{ contentType?: string; data?: string }>();
  if (!body.data) return c.json({ error: "data is required" }, 400);
  const contentType = body.contentType ?? "image/jpeg";
  if (!contentType.startsWith("image/")) {
    return c.json({ error: "Only images are accepted" }, 400);
  }
  const bytes = Buffer.from(body.data, "base64");
  if (bytes.length === 0) return c.json({ error: "Photo was empty" }, 400);
  if (bytes.length > 5 * 1024 * 1024) {
    return c.json({ error: "Photo must be under 5 MB." }, 400);
  }
  const ext = contentType.split("/")[1]?.split("+")[0]?.replace("jpeg", "jpg") ?? "jpg";
  const key = `photos/${crypto.randomUUID()}.${ext}`;
  await putBytes(key, bytes, contentType);
  const origin = new URL(c.req.url).origin;
  return c.json({
    key,
    url: `${origin}/api/photos?key=${encodeURIComponent(key)}`,
    contentType,
    bytes: bytes.length,
  });
});

app.get("/api/photos", async (c) => {
  const key = c.req.query("key") ?? "";
  if (!key.startsWith("photos/")) return c.json({ error: "key required" }, 400);
  const file = await getBytes(key);
  return new Response(Buffer.from(file.body), {
    status: 200,
    headers: {
      "Content-Type": file.contentType,
      "Cache-Control": "private, max-age=3600",
    },
  });
});

export default app;
