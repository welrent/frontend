import { required } from "./env.js";

export async function listModels(): Promise<unknown> {
  const base = required("NEON_AI_GATEWAY_BASE_URL").replace(/\/+$/, "");
  const token = required("NEON_AI_GATEWAY_TOKEN");
  const response = await fetch(`${base}/v1/models`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const body = await response.text();
  if (!response.ok) {
    throw new Error(`AI Gateway ${response.status}: ${body.slice(0, 300)}`);
  }
  return JSON.parse(body) as unknown;
}

export async function complete(prompt: string): Promise<string> {
  const base = required("NEON_AI_GATEWAY_BASE_URL").replace(/\/+$/, "");
  const token = required("NEON_AI_GATEWAY_TOKEN");
  const response = await fetch(`${base}/v1/chat/completions`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "gemini-3-flash",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 32,
    }),
  });
  const body = await response.text();
  if (!response.ok) {
    throw new Error(`AI Gateway ${response.status}: ${body.slice(0, 300)}`);
  }
  const data = JSON.parse(body) as {
    choices?: Array<{ message?: { content?: string } }>;
  };
  return data.choices?.[0]?.message?.content ?? "";
}
