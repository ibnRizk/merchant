# SSM Merchant App: Final Pre-Launch Audit

| | |
|---|---|
| **Date** | 2026-10-01 |
| **Scope** | Whole Flutter codebase (`lib/`, `test/`, `lang/`, `android/`, `ios/`, `pubspec.yaml`) compared with the server contract in [docs/SSM_MERCHANT_API_README.md](docs/SSM_MERCHANT_API_README.md) and the Postman collection |
| **Commit** | `master` @ `fcce42e` |
| **Health checks** | `flutter analyze`: 3 lint infos, no warnings or errors. `flutter test`: 255/255 passing. |

**Priority legend**

| Priority | Meaning |
|---|---|
| **P0** | Launch blocker. Merchants lose orders, get stuck, or the store submission is rejected. |
| **P1** | Fix before launch if at all possible. Merchants see wrong data or reach dead ends. |
| **P2** | Fix after launch. Polish, hardening and cleanup. |

---

## 0. Executive summary

The architecture is sound. Layers are clean, the error contract (`Either<Failure, T>`) is applied consistently, and every list screen has loading, error, empty and retry states. Order commands are idempotent and use version checks. Product, order, hours and profile flows are wired to real endpoints, and **no mock data or fake charts were found**.

The gaps come from what the app never receives or never sends. These are the main ones:

1. **No realtime and no push.** The app has no FCM or Pusher integration, so a new order appears only when the merchant pulls to refresh or reopens a screen. For a merchant app this is the most serious problem.
2. **Order queues go stale.** Nothing refreshes them automatically. When a customer cancels or dispatch fails, the merchant is not told.
3. **Pending merchants get stuck.** A pending merchant who relaunches the app lands on a broken home screen.
4. **Hardcoded business data:** the currency (SAR for an Egyptian zone), a "Nabra Governorate" time note, a free-trial promise, a single English-only store translation, and zone, module and tax values.
5. **Store-compliance gaps:** release builds are signed with the debug key, and there is no in-app account deletion and no privacy policy link.
6. **About a third of the server API is unused** (13 of 41 endpoints), including stock, notifications, onboarding status and FCM token registration.

### Launch blockers (P0)

| ID | Blocker | Owner |
|---|---|---|
| C-01 | No push or realtime: new orders are never delivered to an idle app | Frontend + Backend |
| C-02 | Order queues and dashboard never refresh on their own | Frontend |
| C-03 | A pending merchant who relaunches the app lands on a home screen full of 403 errors | Frontend |
| A-01 | Realtime contract is incomplete (Pusher channel auth endpoint and keys delivery are undefined) | Backend |
| A-02 | No way to recover an order stuck in `assignment_failed` | Backend + Product |
| A-03 | No account deletion endpoint (App Store guideline 5.1.1(v)) | Backend |
| B-01 | Currency is hardcoded to SAR while the live zone is Mansoura, Egypt | Design + Backend |
| C-04 | Release build is signed with the debug keystore | Frontend / DevOps |

### Answer to "what if a customer cancels while the merchant is preparing?"

The merchant is **not told**. The Active Orders screen keeps showing the order as *Preparing* until it is refreshed by hand. If the merchant taps **Ready for pickup**, the server answers `422 order-transition-invalid`. The app shows that as a generic error snackbar and **does not reload** the order, because only `409` triggers a reload ([current_orders_cubit.dart:116](lib/features/orders/presentation/cubit/current_orders/current_orders_cubit.dart#L116)). After the next manual refresh the order vanishes from the active list without any explanation. See C-02, C-05 and B-12.

---

## A. Backend API Requirements

### A.0 API coverage matrix

**28 of the 41 endpoints** in the Postman collection are used. These 13 are not:

| Endpoint | What it unlocks | Frontend item |
|---|---|---|
| `POST /vendor/update-fcm-token` | Push notifications for new orders | C-01 |
| `GET /vendor/notifications` | Notification inbox | C-10 |
| `GET /vendor/notifications/unread-count` | Badge on the bell icon | C-10 |
| `PATCH /vendor/notifications/{id}/read` | Mark one as read | C-10 |
| `POST /vendor/notifications/read-all` | Mark all as read | C-10 |
| `PATCH /vendor/catalog/items/{id}/stock` | Stock management (onboarding already advertises it) | C-11 |
| `GET /vendor/onboarding-status` | Pending screen: live status and rejection reason | C-03 |
| `POST /vendor/documents` | Upload onboarding documents | C-12 |
| `GET /vendor/documents/{id}/file` | View uploaded documents | C-12 |
| `GET /vendor/session/validate` | Session check at startup | C-03 |
| `GET /vendor/pharmacy-requests` | Pharmacy stores: incoming requests | C-13 |
| `GET /vendor/pharmacy-requests/{id}` | Request details | C-13 |
| `GET /vendor/pharmacy-requests/{id}/prescription` | Prescription image | C-13 |

The catalog API also accepts fields the app never sends: `stock`, `unit_id`, `discount`/`discount_type`, `tax`/`tax_type`, `maximum_cart_quantity` and `organic` (see C-11). The profile API accepts `password`, `phone` and `email` for the owner, but the app never sends those either (see C-14).

### A.1 Missing endpoints and contract gaps

#### A-01 · P0 · Realtime contract is incomplete
- The README lists the Pusher private channels `private-merchant.{merchant_id}` and `private-order.{order_id}`. Private channels need a signed auth endpoint (usually `POST /broadcasting/auth`), and **that endpoint is not in the collection**.
- The app has no way to get the Pusher app key or cluster. They are not in any config response.
- **Needed:**
  1. A channel-auth endpoint that accepts the merchant's opaque bearer token.
  2. The Pusher key and cluster, either from a config endpoint (see A-14) or agreed as build-time config.
  3. A documented payload for each event: `ssm.order.status_changed`, `ssm.driver.assigned`, `ssm.dispatch.assignment_failed` and `ssm.notification.created`.
  4. Confirmation that a **new order** raises an event on `private-merchant.{id}`. Today only status changes are documented.
  5. The FCM payload format for "new order" and "order cancelled", including a data key the app can route on (for example `order_id`).

#### A-02 · P0 · No recovery path for `assignment_failed`
- When no driver accepts, the order ends in `assignment_failed`. The app counts this as a cancelled status ([order_status.dart:51-54](lib/features/orders/domain/entities/order_status.dart#L51-L54)), so the order disappears from the active queue while the food is ready on the counter.
- **Needed (product decision first):** one of the following:
  - `POST /vendor/orders/{id}/retry-dispatch`, or
  - an automatic re-dispatch policy with a documented end state, plus a defined outcome for the customer (refund or cancel) and for the merchant (compensation?).
- The order payload also needs a field saying **why** and **by whom** an order ended. See A-05.

#### A-03 · P0 · No account deletion
- The app lets users create accounts (registration), so Apple requires them to be able to delete the account from inside the app (guideline 5.1.1(v)). Google Play requires a deletion path as well.
- **Needed:** `DELETE /vendor/account` (or `POST /vendor/account/delete-request`) with confirmation semantics: password re-entry, a grace period, and the effect on open orders.

#### A-04 · P1 · Merchant earnings, payouts and withdrawals do not exist
- `dashboard-stats` returns only `today.gross_revenue`, the gross value of today's delivered orders. Nothing tells the merchant what they **earn** after commission and fees, what they are owed, or how they get paid.
- **Needed:**
  - `GET /vendor/earnings?from=&to=`: gross, commission, delivery share, net, and a per-day series for a chart.
  - `GET /vendor/wallet`: balance, pending amount, last payout.
  - `GET /vendor/payouts` (paged) and `POST /vendor/withdraw-requests` (amount, method).
  - `GET`/`PUT /vendor/payout-method`: bank or wallet details, with server-side validation and masking.
- If the "free during the first phase" policy (B-03) is real, these can launch in a minimal form. The server should still be the one to say commission is 0.

#### A-05 · P1 · The order payload is too thin for the merchant's job
The parsed fields are in [order_models.dart:26-61](lib/features/orders/data/models/order_models.dart#L26-L61). These are needed:

| Field | Why |
|---|---|
| `subtotal`, `discount_amount`, `coupon_discount`, `tax_amount`, `service_fee` | Today the details screen shows only the delivery fee and the total, so the lines don't add up to the total |
| `merchant_net` / `commission_amount` | The merchant needs to know what this order earns them |
| `payment_status` (`paid` / `unpaid`) plus a canonical `payment_method` enum | The app maps everything except `cash_on_delivery` to "Paid online" ([order_display.dart:65-69](lib/features/orders/presentation/utils/order_display.dart#L65-L69)) |
| `driver: {name, phone, vehicle, eta_minutes}` once `driver_assigned` | The merchant can't tell the driver who arrives at the counter which order is theirs |
| `cancellation: {by: customer\|merchant\|system\|admin, reason, at}` | The Cancelled tab can't explain anything |
| `scheduled_at` / `order_type` (delivery, takeaway, scheduled) | Prep planning |
| `accept_deadline_at` (if pending orders auto-expire) | Lets the app show a countdown on new orders |
| `customer_phone` (masked or proxy), if policy allows | Contacting the customer about a missing item |

#### A-06 · P1 · Order history can't be searched or filtered on the server
- `GET /vendor/completed-orders` accepts only `offset` and `limit`. The app therefore searches and filters by status **only over pages already loaded** ([orders_history_cubit.dart:141-146](lib/features/orders/presentation/cubit/orders_history/orders_history_cubit.dart#L141-L146)). Searching for an order on page 6 returns "No results".
- **Needed:** `?search=` (order id), `?status=delivered|cancelled`, and `?from=&to=` on `completed-orders`.
- **Confirm:** does `completed-orders` include `rejected`, `cancelled`, `assignment_failed` and `refunded`? The Cancelled tab relies on it.

#### A-07 · P1 · Order history export
- The **Export** button exists but shows "coming soon" ([order_history_screen.dart:104-108](lib/features/orders/presentation/pages/order_history_screen.dart#L104-L108)).
- **Needed:** `GET /vendor/orders/export?from=&to=&format=csv|pdf`, returning a signed URL or a file stream. The alternative is to remove the button for launch (B-06).

#### A-08 · P1 · Store profile can't be fully managed
`PATCH /vendor/profile` covers only text fields. These are missing:
- **Logo and cover photo update** (multipart). Registration uploads them, but nothing can change them afterwards.
- **Store location** (`latitude`/`longitude`, re-validated against the zone).
- **Delivery time** (`minimum_delivery_time`, `maximum_delivery_time`, `delivery_time_type`). It is set at registration and can never be edited.
- **Operational settings** that merchants expect: minimum order amount, default preparation time, and a temporary "busy" or pause mode with an automatic reopen time.
- **Store name and address translations** for both `ar` and `en`. See B-05.

#### A-09 · P1 · Product variations and add-ons
- The order lines already show `variation` and `add_ons` ([order_models.dart:85-88](lib/features/orders/data/models/order_models.dart#L85-L88)), but the catalog API has no way to **create** them (sizes, extras, required or optional groups, price deltas). For restaurants this is a core feature.
- **Needed:** CRUD for option groups and options on `/vendor/catalog/items/{id}`, or at least fields that accept them on create and update.

#### A-10 · P1 · Working-hours semantics are undefined
- **Confirm:** does the server close the store automatically outside working hours? Does the manual open/close toggle (`update-active-status`) override the schedule, and for how long?
- **Confirm:** an overnight range such as `22:00–02:00` is accepted (the Postman example implies yes). What happens when `opening_time == closing_time`?
- **Needed (P2):** split shifts (more than one range per day) and holiday or special-date closures, for example `POST /vendor/closures {date, reason}`.

#### A-11 · P2 · Reviews and ratings
- No endpoint exposes customer ratings or reviews of the store or its products.
- **Needed:** `GET /vendor/reviews` (paged, with average and distribution) and, optionally, `POST /vendor/reviews/{id}/reply`.

#### A-12 · P2 · Sales analytics
- `dashboard-stats` already returns an `all_time` section that the app ignores ([dashboard_stats_model.dart:17-27](lib/features/home/data/models/dashboard_stats_model.dart#L17-L27)).
- **Needed:** `GET /vendor/analytics?from=&to=&granularity=day|week` with orders, revenue and top products, so the dashboard can show a real chart.

#### A-13 · P2 · Rejection reasons
- The app hardcodes four reason codes: `item_unavailable`, `store_busy`, `store_closing` and `other` ([order_command.dart:6-10](lib/features/orders/domain/params/order_command.dart#L6-L10)).
- **Confirm** that the server validates exactly these codes. Alternatively, serve `GET /vendor/order-reject-reasons` (localized) so the reasons can change without an app release.
- **Confirm:** is `note` required when `reason=other`?

#### A-14 · P1 · App and business configuration endpoint
Several values the app hardcodes belong to the server:
- `GET /vendor/config` (public, or available after login) returning:
  - `currency_code`, `currency_symbol` and decimal places (B-01)
  - `timezone` and zone name (B-02)
  - commission or free-trial status and its text (B-03)
  - support phone, WhatsApp and e-mail; terms and privacy URLs (B-09)
  - `min_supported_app_version` (forced update)
  - Pusher key and cluster (A-01)
  - available zones and modules for registration (A-15)

#### A-15 · P2 · Zone and module discovery for registration
- `zone_id=7`, `module_id=1` and `tax=0` come from `.env` and constants ([app_env.dart:30-34](lib/config/env/app_env.dart#L30-L34), [auth_requests.dart:41](lib/features/auth/data/models/auth_requests.dart#L41)). A store outside Mansoura can't register: the server answers 403 "location outside zone".
- **Needed:** `GET /auth/vendor/zones` or `GET /auth/vendor/zone-by-location?lat=&lng=`, plus module selection when stores of more than one module type (food, pharmacy, grocery) are on-boarded.

#### A-16 · P1 · Error-code contract for 403
- Every 403 reaches the app as the same exception: "not approved", "outside zone", "invalid store category" and "account suspended" look identical ([dio_consumer.dart:231-233](lib/core/api/dio_consumer.dart#L231-L233)).
- **Needed:** stable `errors[].code` values for `merchant-not-approved`, `merchant-suspended`, `store-disabled-by-admin` and `zone-out-of-bounds`, documented so the app can route each one (see C-03).
- **Needed:** a stable code for `order-transition-invalid` that includes the **current** `ssm_status` in the 422 body, so the app can update the card in place (see C-05).

#### A-17 · P2 · FCM token lifecycle
- **Needed:** `POST /vendor/remove-fcm-token`, or a documented rule that `POST /vendor/logout` clears it. This stops a logged-out device from receiving another merchant's orders.

#### A-18 · P2 · Pharmacy requests are read-only
- The README says "There is no accept or quote endpoint for pharmacy requests yet." Pharmacy merchants can see a request but can't act on it. Product needs to decide whether pharmacy stores launch in phase 1.

---

## B. Design / UI Requirements

### B.1 Hardcoded and static content

| ID | Pri | What | Where | Required action |
|---|---|---|---|---|
| **B-01** | **P0** | Currency is **SAR / "ر.س"** everywhere, but the live zone is Mansoura, Egypt (EGP) | [lang/en.json:58](lang/en.json#L58), [stats_grid.dart:56](lib/features/home/presentation/widgets/stats_grid.dart#L56), [product_card.dart:83](lib/features/menu/presentation/widgets/product_card.dart#L83), [product_form_screen.dart:213](lib/features/menu/presentation/pages/product_form_screen.dart#L213), [order_display.dart:92](lib/features/orders/presentation/utils/order_display.dart#L92) | Confirm the currency. Rename the key from `currency_sar` to `currency` and drive it from A-14. |
| **B-02** | P1 | The working-hours note reads "Local time: **Nabra Governorate**". The place name is static and doesn't match the zone. | [lang/en.json:165](lang/en.json#L165), [hours_screen.dart:78-82](lib/features/hours/presentation/pages/hours_screen.dart#L78-L82) | Use the store's zone and timezone from the server, or drop the place name. The copy is also split on `-` at runtime, so it breaks if a translator changes the dash. |
| **B-03** | P1 | The "free, no fees or commission during the first phase" banner is a business promise in static copy, shown on the Login and Profile screens | [login_screen.dart:119](lib/features/auth/presentation/pages/login_screen.dart#L119), [profile_screen.dart:210](lib/features/profile/presentation/pages/profile_screen.dart#L210) | Get legal and business sign-off. Show it only when the server says the trial is active (A-14). |
| **B-04** | P1 | Onboarding promises things the app doesn't do: "New orders reach you **instantly**" and "update prices **and stock**" | [lang/en.json:249](lang/en.json#L249), [lang/en.json:251](lang/en.json#L251) | Either ship push (C-01) and stock (C-11), or rewrite the copy. |
| **B-05** | P1 | The store name and address are always sent with locale **`en`**, even when typed in Arabic | [register_screen.dart:37](lib/features/auth/presentation/pages/register_screen.dart#L37) | Design an Arabic and English name/address input, or at least tag the text with the UI language. Check with the customer-app team how missing translations are shown. |
| B-06 | P1 | The **Export** button only shows "coming soon" | [order_history_screen.dart:102-109](lib/features/orders/presentation/pages/order_history_screen.dart#L102-L109) | Hide it for launch or ship A-07. A visible dead button looks unfinished to store reviewers. |
| B-07 | P2 | The New Orders banner reads "Management only monitors and intervenes when necessary". It is internal-facing copy. | [orders_screen.dart:72-75](lib/features/orders/presentation/pages/orders_screen.dart#L72-L75) | Copy review. |
| B-08 | P2 | The map picker opens on a fixed coordinate (31.03, 31.385) | [location_picker_screen.dart:17](lib/features/auth/presentation/pages/location_picker_screen.dart#L17) | Acceptable while there is one zone. Center on the zone (A-15) later. |
| — | — | Unused strings: `map_picker_coming_soon`, the `category_restaurants`/`cafes`/`sweets`/`grocery` hardcoded categories, `store_description_label` | `lang/*.json` | Delete them (see C-17). |

**No mock data was found**: no fake charts, dummy reviews or placeholder product images. Product thumbnails fall back to a food icon, which looks wrong for pharmacy and grocery stores (P2).

### B.2 Missing screens and flows (design needed)

| ID | Pri | Screen / flow | Notes |
|---|---|---|---|
| **B-09** | **P0/P1** | **Account and legal:** Delete account (P0, A-03); Privacy policy and Terms links (P1); Contact support (P1) | Profile currently has only the form, theme, language and logout |
| **B-10** | **P0** | **New-order alert:** a loud repeating sound, a full-screen or heads-up notification, and a badge on the Home tab, all working while the app is in the background | Depends on C-01. Merchants keep the phone on a counter, so a silent snackbar is not enough. |
| B-11 | P1 | **Notifications inbox** with a bell and unread badge in the Home header | Endpoints already exist (A.0) |
| **B-12** | P1 | **Order-ended alerts:** "Order #1048 was cancelled by the customer, stop preparing" and "No driver found for #1048" with a next step | Depends on A-02 and A-05 |
| B-13 | P1 | **Pending-approval screen v2:** live status, rejection reason, document upload checklist, "Check again" button, Logout | Today it is static text plus "Back to login" ([pending_approval_screen.dart](lib/features/auth/presentation/pages/pending_approval_screen.dart)) |
| B-14 | P1 | **Earnings / wallet:** balance, payouts list, withdraw request, payout method | Depends on A-04 |
| B-15 | P1 | **Order details v2:** price breakdown (subtotal, discount, tax, fees, net), driver card, cancellation reason, payment status, countdown on new orders | Depends on A-05. Today the screen shows lines, delivery fee and total only ([order_details_screen.dart:160-177](lib/features/orders/presentation/pages/order_details_screen.dart#L160-L177)). |
| B-16 | P1 | **Product form v2:** stock quantity, unit, discount, max per cart, variations and add-ons, "remove image" | API fields exist for everything except variations (A-09) |
| B-17 | P1 | **Store settings:** logo and cover change, location, delivery time, minimum order, prep time, busy mode | Depends on A-08 |
| B-18 | P1 | **Change password** in Profile | The API supports it (C-14) |
| B-19 | P2 | **Menu by category:** category chips or sections, an "No products in this category" empty state, and an Active / Hidden filter | `?status=` already exists on the API |
| B-20 | P2 | **Dashboard chart and all-time KPIs** | Depends on A-12 |
| B-21 | P2 | **Reviews** screen | Depends on A-11 |
| B-22 | P2 | **History date-range filter** | Depends on A-06 |
| B-23 | P2 | **Force-update** and **maintenance** screens | Depends on A-14 |

### B.3 Missing or incomplete UI states

| ID | Pri | Screen | Gap |
|---|---|---|---|
| B-24 | P1 | Location picker | Location services off, or permission denied, does **nothing**: no message and no "Open settings" ([location_picker_screen.dart:48-66](lib/features/auth/presentation/pages/location_picker_screen.dart#L48-L66)) |
| B-25 | P1 | Store status toggle | If the profile fails to load, the toggle stays on "Loading…" for good, and there is no retry next to it ([store_status_bar.dart:48-63](lib/features/home/presentation/widgets/store_status_bar.dart#L48-L63)) |
| B-26 | P1 | Order history, Cancelled/Completed tab | A filtered tab with no matches on the loaded pages, but more pages on the server, shows only a "Load more" button and no empty message ([order_history_screen.dart:163-171](lib/features/orders/presentation/pages/order_history_screen.dart#L163-L171)) |
| B-27 | P1 | Product form, Working hours, Profile | **No unsaved-changes guard.** Back or a tab switch silently keeps or drops edits, and Hours has no "unsaved" indicator. No `PopScope` exists on these screens. |
| B-28 | P2 | Order details | If `order-details` returns no lines, the Items section shows only a divider and the total; there is no "Items unavailable" message |
| B-29 | P2 | Working hours | No validation that opening ≠ closing. There are two Save buttons (header and bottom); pick one. |
| B-30 | P2 | Global | No offline banner. Each screen shows its own "No internet connection" error instead. |
| B-31 | P2 | Deep-link errors | "Order not found" and "No route found for …" are **hardcoded English** ([app_routes.dart:165](lib/config/routes/app_routes.dart#L165), [app_routes.dart:244](lib/config/routes/app_routes.dart#L244)) |

### B.4 Design-system issues

| ID | Pri | Issue | Evidence |
|---|---|---|---|
| **B-32** | P1 | **The Cairo font is not bundled.** It is referenced 135 times (`fontFamily: 'Cairo'`), but the `fonts:` block in `pubspec.yaml` is commented out and there is no `assets/fonts/` folder. Every screen falls back to the system font, so the Arabic text doesn't match the designs. | [pubspec.yaml](pubspec.yaml) `fonts:` section |
| B-33 | P2 | Typography is defined inline in each widget (size, weight and family repeated) instead of through `TextTheme` or `text_styles.dart`, so a type-scale change touches about 130 places | e.g. [needs_attention_list.dart:41-46](lib/features/home/presentation/widgets/needs_attention_list.dart#L41-L46) |
| B-34 | P2 | Mixed sizing: `flutter_screenutil` is set up (`kDesignSize` 390×844) but feature widgets use fixed pixels. Pick one approach and check small devices (360 dp) and large text scale. | [app.dart:18](lib/app.dart#L18) |
| B-35 | P2 | `NSLocationAlwaysUsageDescription` is declared although the app only needs "when in use", and the permission strings are English-only. This can draw App Review questions. | [ios/Runner/Info.plist:11](ios/Runner/Info.plist#L11) |

---

## C. Frontend Technical Debt

### C.1 Broken journeys and logic

#### C-01 · P0 · No push notifications and no realtime
- `pubspec.yaml` has no `firebase_messaging` or Pusher client. The FCM token is never registered, and `zoneWiseTopic` from login is never used ([merchant_auth_result.dart:16](lib/features/auth/domain/entities/merchant_auth_result.dart#L16)).
- **Effect:** an order placed while the merchant is on another tab, or has the app in the background, is never noticed. With the API's auto-dispatch and any auto-expiry, this loses revenue.
- **Fix:**
  1. Add `firebase_messaging` and `flutter_local_notifications`, register the token after login (`update-fcm-token`), handle notification taps by routing to `/orders/:id`, and clear the token on logout.
  2. Add a Pusher channel client for in-app live updates (depends on A-01).
  3. On every event or push, re-read the data over REST, as the README requires.

#### C-02 · P0 · Order queues and dashboard never refresh on their own
- There is no polling, no `AppLifecycleState.resumed` handling and no event subscription anywhere in `lib/`. A grep for `WidgetsBindingObserver`, `AppLifecycle` and `Timer.periodic` finds only the OTP timer.
- Each data source refreshes only in these cases:
  - **Dashboard:** pull-to-refresh, or returning from the orders screens ([home_screen.dart:48-53](lib/features/home/presentation/pages/home_screen.dart#L48-L53))
  - **New and Active orders:** pull-to-refresh, or returning from details
  - **History tab:** pull-to-refresh only; accepting an order elsewhere doesn't update it
- **Fix:**
  - Short term (even before C-01): refresh the current-orders and dashboard data on app resume, and poll every 20–30 s while an orders screen or the Home tab is visible.
  - Long term: hold `CurrentOrdersCubit` at the `/home` scope (today each orders route creates its own) and feed it from realtime events.

#### C-03 · P0 · Pending or rejected merchant gets stuck after relaunch
1. Login saves the token **even for pending accounts** ([merchant_auth_repository_impl.dart:29-31](lib/features/auth/data/repos/merchant_auth_repository_impl.dart#L29-L31)).
2. On the next launch, Splash sees a token and goes **straight to Home** ([splash_cubit.dart:35-38](lib/features/launch/presentation/cubit/splash/splash_cubit.dart#L35-L38)).
3. Every operational call returns 403 `merchant-not-approved`. That is mapped to `UnauthorizedException`, but the global handler reacts only to **401** ([app_interceptors.dart:30-33](lib/core/api/app_interceptors.dart#L30-L33)). The merchant sees error cards on every tab and no explanation. (The comment in [app.dart:33](lib/app.dart#L33) says "401/403", which is wrong.)
4. "Back to login" on the pending screen doesn't clear the token, so the loop repeats ([pending_approval_screen.dart:50](lib/features/auth/presentation/pages/pending_approval_screen.dart#L50)).
- The same dead end happens if an admin **suspends** an approved merchant mid-session.
- **Fix:**
  - Store the approval status with the session. Make Splash call `GET /vendor/onboarding-status` (or `session/validate`) and route to Home or the pending screen accordingly.
  - Map 403 `merchant-not-approved` and `merchant-suspended` (A-16) to a dedicated failure and route it globally to the pending screen.
  - Give the pending screen Logout and "Check again" actions.

#### C-04 · P0 · Release signing uses the debug key
- `signingConfig = signingConfigs.getByName("debug")` in the `release` build type ([android/app/build.gradle.kts:48](android/app/build.gradle.kts#L48)). Play Console rejects debug-signed bundles.
- **Fix:** an upload keystore loaded from `key.properties`, which must be git-ignored.

#### C-05 · P1 · A rejected transition (422) leaves a stale card
- Only `ConflictFailure` (409) triggers a refresh ([current_orders_cubit.dart:115-128](lib/features/orders/presentation/cubit/current_orders/current_orders_cubit.dart#L115-L128), same pattern in [order_details_cubit.dart:111-122](lib/features/orders/presentation/cubit/order_details/order_details_cubit.dart#L111-L122)).
- A command on an order the customer cancelled returns `422 order-transition-invalid`. 422 is mapped to `ServerException` ([dio_consumer.dart:239-241](lib/core/api/dio_consumer.dart#L239-L241)), so the card stays with the merchant's "Ready for pickup" button still active.
- A 404 (order reassigned or deleted) behaves the same way.
- **Fix:** add a `TransitionRejectedFailure` (422 with `order-transition-invalid`) and treat it, and 404 on command routes, like 409: show a notice and refresh.

#### C-06 · P1 · `assignment_failed` and `cancelled` orders vanish without notice
- `isActive` excludes terminal statuses, so after a refresh the order silently leaves the Active list ([current_orders_state.dart:40-43](lib/features/orders/presentation/cubit/current_orders/current_orders_state.dart#L40-L43)).
- **Fix:** compare old and new lists on refresh. When an order the merchant was handling becomes terminal-not-delivered, show a notice and link to it (B-12).

#### C-07 · P1 · Raw exception text can reach users
- The catch-all in `DioConsumerImpl._request` wraps any non-Dio error as `ServerException(message: error.toString())` ([dio_consumer.dart:219-221](lib/core/api/dio_consumer.dart#L219-L221)). `guardFailure` passes `AppException` messages straight through, so a type error inside a request shows as text like `type 'Null' is not a subtype…`.
- Models also throw the **hardcoded English** message `'Unexpected response format.'`, which is shown to Arabic users. It appears in 13 places, for example [dashboard_stats_model.dart:31](lib/features/home/data/models/dashboard_stats_model.dart#L31), [day_schedule_model.dart:29](lib/features/hours/data/models/day_schedule_model.dart#L29) and [orders_remote_data_source.dart:44](lib/features/orders/data/datasources/orders_remote_data_source.dart#L44).
- **Fix:** keep raw text for logs only. Add a localized `Strings.unexpectedResponse`.

#### C-08 · P1 · Price parsing treats `,` as a decimal point
- `parsePrice("1,000")` returns `1.0` ([price_format.dart:12-13](lib/core/utils/price_format.dart#L12-L13)). A merchant who types a thousands separator saves a price 1000× too low, with no warning.
- **Fix:** reject inputs with more than one separator, or treat `,` followed by exactly three digits as grouping. Add a reproducing test.

#### C-09 · P1 · History search and filters work only on loaded pages
- Covered under A-06. Once the backend supports it, switch the cubit to server-side `search` and `status` and remove the local `filterOrders` path.

### C.2 Integration work (endpoints already exist)

| ID | Pri | Work | Endpoint(s) |
|---|---|---|---|
| C-10 | P1 | Notifications feature (data → domain → cubit → inbox screen and badge) | `/vendor/notifications*` |
| C-11 | P1 | Stock field on the product form and card, an "Out of stock" badge, and the remaining product fields (unit, discount, tax, max cart qty, organic) | `PATCH …/stock`, catalog create/update |
| C-12 | P1 | Onboarding status polling and document upload on the pending screen | `/vendor/onboarding-status`, `/vendor/documents` |
| C-13 | P2 | Pharmacy requests list and details, shown only for pharmacy stores (`module_type` from login) | `/vendor/pharmacy-requests*` |
| C-14 | P1 | Change password and owner phone/email in Profile | `PATCH /vendor/profile` (`password`, `password_confirmation`, `phone`, `email`) |
| C-15 | P2 | Menu `status=active\|inactive` filter | `GET /vendor/catalog/items?status=` |

### C.3 Code quality and architecture

| ID | Pri | Issue | Evidence / fix |
|---|---|---|---|
| C-16 | P2 | **Data access in the presentation layer:** `Geolocator` permission and position calls live inside `LocationPickerScreen`, with a silent `catch (e) {}` | [location_picker_screen.dart:45-71](lib/features/auth/presentation/pages/location_picker_screen.dart#L45-L71). Move them to a `LocationService` in `core/services` that returns typed failures (this also feeds B-24). |
| C-17 | P2 | **Dead template code (about 35 files):** 19 widgets in `core/widgets` with no importers (`tab_placeholder`, `custom_alert`, `diff_img`, `type_writer_effect`, `app_button`, `app_text_field`, `no_data_found`, `loading_view`, `app_shimmer`, `show_dialog`, `gaps`, …), `core/usecases/usecase.dart` (which contradicts the project's no-use-case rule), `core/general_cubit/*`, `base_classes/*` (except `base_one_response` and `pagination`), `random_password`, `convert_string_color`, `launch_url_method` (with a hardcoded `+20` WhatsApp prefix), the `media_query_values` helpers, and the unused `photoViewer` route with an untyped `Map` extra | Delete them in one cleanup PR |
| C-18 | P2 | **Unused dependencies:** `shimmer`, `loading_animation_widget`, `connectivity_plus` and `flutter_svg` (imported only by dead files) | Remove from `pubspec.yaml` to cut app size and attack surface |
| C-19 | P2 | Side effect in `build`: `MaterialApp.builder` re-registers `AppColors` in GetIt on every rebuild | [app.dart:91-93](lib/app.dart#L91-L93). Prefer `context.colors` everywhere and drop the global `colors` getter. |
| C-20 | P2 | Global `Strings.*.tr` forces every screen to `context.watch<LocaleCubit>()` just to rebuild labels | Move to `AppLocalizations.of(context)` or a generated l10n. Not urgent. |
| C-21 | P2 | `ValidatorType.password` still enforces "6+ characters" with stale copy ([validator.dart:84](lib/core/utils/validator.dart#L84)); the server requires the strong rule | Remove it or alias it to `strongPassword`, so a future change-password screen (C-14) can't pick the wrong one |
| C-22 | P2 | All 5 tabs are built at once (`IndexedStack`), so launching fires about 6 requests (dashboard, history ×2, menu, profile, hours) before the merchant sees anything | [main_scaffold.dart:70](lib/features/home/presentation/pages/main_scaffold.dart#L70). Load each tab on first visit. |
| C-23 | P2 | Payment label falls back to "Paid online" for any method that isn't `cash_on_delivery`, including unknown ones | [order_display.dart:65-69](lib/features/orders/presentation/utils/order_display.dart#L65-L69). Add an explicit `unknown` mapping once A-05 lands. |
| C-24 | P2 | `GoRouter(debugLogDiagnostics: true)` is not gated on `kDebugMode` | [app_routes.dart:76](lib/config/routes/app_routes.dart#L76) |
| C-25 | P2 | 3 analyzer infos (`curly_braces_in_flow_control_structures`) | [order_display.dart:40-47](lib/features/orders/presentation/utils/order_display.dart#L40-L47) |

### C.4 Configuration and release

| ID | Pri | Issue | Fix |
|---|---|---|---|
| C-26 | P1 | A single `.env` points at the **production** server (`ssm.husseintech.com`), so every developer build and test registration hits live data | Add `.env.staging` and `.env.production` and select one with `--dart-define=ENV_FILE` (the mechanism already exists in [app_env.dart:12-18](lib/config/env/app_env.dart#L12-L18)) |
| C-27 | P1 | Google Maps keys come from `local.properties` and Xcode build settings and fail silently (grey map) if missing | Add a CI check, and restrict the keys by package name, bundle id and SHA-1 in Google Cloud |
| C-28 | P2 | `version: 1.0.0+1` | Set the release versioning policy before the first store upload |
| — | — | `.env` is committed and bundled as an asset. It holds **no secrets** today. | Keep it that way: never put API secrets in `.env`, because the asset ships in plain text inside the APK/IPA |

### C.5 Test coverage

The 255 unit tests cover the domain, data and cubit layers well for home, hours, menu, orders, profile and launch. These gaps remain:

| ID | Pri | Gap |
|---|---|---|
| C-29 | P1 | **Auth cubits have no tests:** `LoginCubit` (including routing by approval status), `RegisterCubit` and `ForgotPasswordCubit`, plus `MerchantAuthRepositoryImpl` (token persistence for pending accounts, which is the bug behind C-03) |
| C-30 | P1 | No tests for `DioConsumerImpl` status-code mapping (401 / 403 / 409 / 422 / timeouts) or `AppInterceptors` logout behavior. Both are central to C-03 and C-05. |
| C-31 | P2 | No widget tests or `integration_test` for the critical path: login → accept → start preparing → ready for pickup |
| C-32 | P2 | No reproducing test for `parsePrice` with a thousands separator (C-08) |

---

## Appendix: Suggested sequencing

| Phase | Items |
|---|---|
| **Before submission** | C-04 · C-03 · C-02 (polling and resume) · B-01 · B-32 · A-03 + B-09 (delete account, privacy link) · B-06 (hide Export) · B-04 (fix onboarding copy) · C-05 · C-07 |
| **Launch week** | A-01 + C-01 + B-10 (push and new-order alarm) · A-02 + B-12 · C-06 · C-08 · B-24 · C-29 / C-30 |
| **First update** | A-05 + B-15 · A-06 · A-08 + B-17 · C-10 / C-11 / C-12 / C-14 · B-02 · B-03 · B-05 · B-27 |
| **Later** | A-04 + B-14 (earnings) · A-09 (variations) · A-11 / A-12 · C-16 to C-25 cleanup |
