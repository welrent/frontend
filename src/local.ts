import { createServer } from "node:http";

import { loadLocalEnv } from "./env.js";

loadLocalEnv();

const { default: app } = await import("../hello.js");

const port = Number(process.env.PORT ?? 8787);
const server = createServer(async (request, response) => {
  const url = new URL(request.url ?? "/", `http://${request.headers.host ?? "127.0.0.1"}`);
  const chunks: Buffer[] = [];
  for await (const chunk of request) chunks.push(chunk as Buffer);
  const body = Buffer.concat(chunks);
  const init: RequestInit = {
    method: request.method,
    headers: request.headers as HeadersInit,
  };
  if (request.method !== "GET" && request.method !== "HEAD") {
    init.body = body;
  }
  const result = await app.fetch(new Request(url, init));
  response.statusCode = result.status;
  result.headers.forEach((value, key) => response.setHeader(key, value));
  response.end(Buffer.from(await result.arrayBuffer()));
});

server.listen(port, "127.0.0.1", () => {
  console.log(`Welrent API listening on http://127.0.0.1:${port}`);
});
