# frontend

The Welrent marketplace frontend is the Flutter Web app in [`welrent_web`](welrent_web/).

Setup, configuration, tests, and deployment are documented in [`welrent_web/README.md`](welrent_web/README.md). The route-by-route migration from the Next.js app is in [`welrent_web/MIGRATION.md`](welrent_web/MIGRATION.md).

## Neon backend

`neon.ts` declares the AI Gateway, a private `uploads` bucket, and the `hello` function (`hello.ts`). That function is the Welrent API: Lakebase Postgres for cars, content, navigation, and rentals; Neon Object Storage for `/api/storage`; and the AI Gateway for `/api/ai`.

Secrets stay in gitignored `.env.local`. Copy `.env.example` and fill it, or let `neon deploy` pull branch variables after you sign in.

```bash
npm install
npm run build
npm start
```

The API listens on `http://127.0.0.1:8787`. Point the Flutter app at it with `API_BASE_URL` (see `welrent_web/README.md`). Do not put `DATABASE_URL` or storage keys in the Flutter web bundle.

`neon deploy` could not run in this environment: the CLI is not signed in and browser login timed out. Sign in with `neon login`, then run `neon deploy --env .env.local` from this directory. That apply also writes `NEON_AI_GATEWAY_BASE_URL` and `NEON_AI_GATEWAY_TOKEN`, which `/api/ai` needs.
