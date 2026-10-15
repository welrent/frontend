# Welrent Web

Native Flutter Web rebuild of the Welrent marketplace. The UI is Flutter widgets and Dart. It does not embed the Next.js app, and it does not need Next.js at runtime.

The visual and behavioral reference is [welrent/wr-frontend](https://github.com/welrent/wr-frontend), especially `next-web/`. Route coverage and known gaps are listed in [MIGRATION.md](MIGRATION.md).

## Requirements

- Flutter 3.47 or newer (Dart 3.13+)
- Chrome, or any static host, for the web build

```bash
cd welrent_web
flutter pub get
```

## Configuration

Public settings live in `assets/config.json`. Empty values keep the same fallbacks as the Next.js app: demo cars, and an explicit “auth is not configured” message.

| Key | dart-define | Purpose |
| --- | --- | --- |
| `apiBaseUrl` | `API_BASE_URL` | PHP API origin, no trailing slash |
| `actBaseUrl` | `ACT_BASE_URL` | Welrent Act site. Default `https://act.welrent.com` |
| `firebaseApiKey` | `FIREBASE_API_KEY` | Firebase web API key. Public by design; restrict it in Google Cloud |
| `firebaseProjectId` | `FIREBASE_PROJECT_ID` | Used for the best-effort Firestore bio write |
| `firebaseStorageBucket` | `FIREBASE_STORAGE_BUCKET` | Recorded for parity. Avatar upload does not use Storage |

A non-empty `--dart-define` overrides the JSON file. Do not put server secrets, service-account keys, or database passwords in this app. The compiled web bundle is public.

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=FIREBASE_API_KEY=your-web-api-key \
  --dart-define=FIREBASE_PROJECT_ID=your-project
```

## Development

```bash
flutter run -d chrome
```

Path URLs are enabled (`usePathUrlStrategy`), so routes look like `/offerlist` rather than `/#/offerlist`.

## Tests and analysis

```bash
dart format lib test
flutter analyze
flutter test
flutter build web --release
```

## Deployment

`flutter build web --release` writes `build/web`. The host must serve `index.html` for unknown paths so a refresh on `/vehicle/an-RS6` still loads the app.

- Netlify: `netlify.toml` and `web/_redirects`
- Vercel: `vercel.json`
- Firebase Hosting: `firebase.json`

Copy `assets/config.json` values before building, or pass the same `--dart-define` flags to `flutter build web`.

## Backend behavior

When `API_BASE_URL` is set, the app calls the Welrent API. Locally that is the Neon Function in the repository root (`npm start`, `http://127.0.0.1:8787`). The same paths are:

- `GET /api/cars`
- `GET /api/vehicle/:slug`
- `GET /api/content`
- `GET /api/nav_footer`
- `GET /api/rentals?uid=`
- `POST /api/rentals`
- `POST /api/auth/login`

Failed catalog calls fall back to the same two demo cars the Next.js client uses (`an RS6`, `an EVO`). A booking is posted only when the API base URL and a signed-in user are both present. Otherwise the confirmation says the booking was saved on this device.

Firebase Identity Toolkit is used for sign-in, registration, and password reset when `FIREBASE_API_KEY` is set. Without Firebase, login uses the PHP endpoint when an API base URL is set. Registration through PHP reuses login and stores the display name locally, because the PHP API has no register route.
