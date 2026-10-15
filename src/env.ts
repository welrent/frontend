import dotenv from "dotenv";

let loaded = false;

/** Load gitignored env files before the function reads process.env. */
export function loadLocalEnv(): void {
  if (loaded) return;
  loaded = true;
  dotenv.config({ path: ".env.local" });
  dotenv.config();
}

export function required(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is required`);
  return value;
}
