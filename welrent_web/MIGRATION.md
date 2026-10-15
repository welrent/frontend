# Welrent Next.js to Flutter Web migration

Source of truth: `welrent/wr-frontend` `next-web/`. This app lives in `welrent_web/` and renders with Flutter Web only.

## Design tokens

Taken from `next-web/src/app/globals.css` and the page components.

| Token | Value |
| --- | --- |
| Text | `#1C263A` |
| Muted text | `#A0A4AB` |
| “Rent...” grey | `#D5DBE1` |
| Accent | `#5CAAF6`, hover `#4A98E0` |
| Page background | `#F8F9FB` / `#FAFBFC` |
| Borders | `#EBEBEB` |
| Grid lines | `#F0F2F5` |
| Search field | `#F3F4F6` |
| Field text | `#8C929A` |
| Search button | `#AAB4BF` |
| Error | `#DC2626` |
| Book button | `#FF4D4D` |
| Trust green | `#00B67A` |
| Logo purple | `#371947` |
| Wordmark | `#C6C6C6` |
| Content width | 1100px, padding 40 / 20 |
| Header | 65px, solid white after 10px of scroll |
| Mobile nav | under 768px |

Fonts: Outfit (UI), Playfair Display (hero and legal), Tinos for the “Cars” / “Act” word because Flutter SVG does not paint the original `<text>` wordmark. The WR mark is `WLR_ICON_WR.svg`.

Breakpoints used in layout: 480, 600, 768, 900, 1000, 1024, 1100.

## Routes

| Path | Next.js page | Flutter screen | Status |
| --- | --- | --- | --- |
| `/` | `page.tsx` | `HomeScreen` | Migrated. Hero, search, categories, yacht, destinations |
| `/offerlist` | `offerlist/page.tsx` | `OfferlistScreen` | Migrated. `q` filters; `type` is shown and does not hide cars |
| `/vehicle/:slug` | `vehicle/[slug]/page.tsx` | `VehicleScreen` | Migrated. Book Now posts or explains a local save |
| `/locations` | `locations/page.tsx` | `LocationsScreen` | Migrated |
| `/locations/:city` | `locations/[city]/page.tsx` | `LocationDetailScreen` | Migrated. Unknown cities still show Monaco |
| `/login` | `login/page.tsx` | `LoginScreen` | Migrated |
| `/register` | `register/page.tsx` | `RegisterScreen` | Migrated |
| `/forgot` | `forgot/page.tsx` | `ForgotScreen` | Migrated. Reset requires Firebase |
| `/account` | `account/page.tsx` | `AccountScreen` | Migrated. Signed-out users go to `/login` |
| `/bookings` | `bookings/page.tsx` | `BookingsScreen` | Migrated. Same local sample bookings |
| `/chat` | `chat/page.tsx` | `ChatScreen` | Migrated. Local threads, send, attach filename, mobile picker |
| `/notifications` | `notifications/page.tsx` | `NotificationsScreen` | Migrated. Local notices, mark read |
| `/act` | `act/page.tsx` | `ActScreen` | Migrated. External Act links |
| `/terms` | `terms/page.tsx` | `LegalScreen.terms` | Migrated |
| `/privacy` | `privacy/page.tsx` | `LegalScreen.privacy` | Migrated |
| `/sponsorship/f1/wr/designed` | F1 page | `SponsorshipScreen` | Migrated. Sticky hero plus a dark header |
| unknown | not found | `NotFoundScreen` inside the shell | Migrated |

Query parameters preserved: `type`, `location`, `start`, `end`, `q`.

## Shared UI

| Next.js | Flutter |
| --- | --- |
| `Header.tsx` | `SiteHeader`, `MobileBottomNav`, `SearchShortcut` |
| `Footer.tsx` | `SiteFooter` |
| `layout.tsx` shell | `AppShell` |
| `globals.css` tokens | `AppColors`, `AppText`, `AppTheme`, `AppBreakpoints` |
| `lib/api.ts` | `WelrentApi` |
| `lib/firebase.ts` | `AuthRepository` (Identity Toolkit REST) |
| `lib/demo-data.ts` | `DemoData` |
| `lib/act.ts` | `AppConfig.actUrl` and `ActScreen` |

State is Riverpod. Routing is `go_router` with path URLs.

## Intentional behavior kept from Next.js

- Header links whose titles contain booking, notification, or chat are hidden. Default nav is Welrent Act, Locations, Vehicles.
- Offer list does not filter the fleet by `type`.
- Geolocation success always sets “Amsterdam Central”.
- Prices stay `$` on vehicles and `€` on destinations, bookings, and account.
- Bookings, chat, and notifications are local data. The original pages were not API-backed.
- Language control highlights EN, NL, or FR. The source app has no translations.
- City pages for Amsterdam and the other non-catalog slugs render the Monaco story.

## Differences and blockers

- Logo word “Cars” / “Act” is Tinos text beside the original WR svg, not the SVG `<text>` node.
- Trustpilot is the green word plus stars. The CDN wordmark SVG was not shipped in the repo.
- App Store and Google Play badges explain that no store URL exists.
- Yacht assistance and concierge dialogs say there is no API. The Next.js buttons did not call one.
- Avatar pick is a local data URL (5 MB cap). Firebase Storage resumable upload is not implemented.
- Profile bio is stored locally and, when a Firebase project id and ID token exist, also patched to Firestore.
- PHP registration has no register endpoint, so it signs in and keeps the chosen name on this device. The PHP login accepts any non-empty email and password and returns a token.
- Password reset only works with `FIREBASE_API_KEY`.
- Without `API_BASE_URL`, cars are the two demo vehicles. That is the same offline path as `lib/api.ts`, and the booking dialog says the API was not called.
- F1 motion uses the sticky section’s own scroll range rather than one global scroll percent.
- Header search and the vehicle-type icons hide below 1100px so the bar does not overflow. They return in the mobile header under 768px.
- Hero arrows cycle RS6 and EVO. The original arrows did not change the slide.
- NL and FR labels do not translate the UI.
- No Firebase or API credentials are in the repository, so live login and live inventory were not exercised against production.
