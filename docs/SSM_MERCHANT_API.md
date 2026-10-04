# SSM Merchant API

For the engineer building the **Merchant (store / pharmacy) app**. This file is self-contained: you do not need the Customer or Driver documents.

| File | What it is |
|---|---|
| `SSM_MERCHANT_API.postman_collection.json` | 122 ready-to-run requests in 14 folders |
| `SSM_PRODUCTION.postman_environment.json` | production server (`https://ssm.husseintech.com/api/v1`), empty credentials |
| `SSM_LOCAL.postman_environment.json` | local Laravel with an approved fixture merchant |

**How to run it:** `00` (public lists) -> `01` (register a new PENDING merchant, see that it is blocked) -> an admin approves it in the SSM admin panel -> `02` -> `03` login with the approved merchant -> `04` orders (place an order with the Customer collection first) -> `05b`, `05c`, `05`, `06`, `07` -> `90` security -> `98` -> `99 Logout` (last, it revokes the token). Logins, store id, order ids, product id and notification ids are saved to the environment automatically. `03b` (password reset) and the legacy one-step pharmacy pricing are opt-in.

**Status of this collection:** last regenerated 2026-10-02. Every request was validated against the production route table (same path, same HTTP verb, same authentication: 0 mismatches).

## 1. Conventions

| Item | Value |
|---|---|
| Base URL | `https://ssm.husseintech.com/api/v1` (production) |
| Format | JSON, except registration, documents, product create/update and store media (multipart). Send `Accept: application/json`. |
| Language | `X-localization: ar` or `en` |
| Auth | `Authorization: Bearer <token>` (opaque token from login, stored server-side; **not** Passport) |
| Actor header | `vendorType: owner`; any other value -> 401 |
| Idempotency | order commands accept `Idempotency-Key: <uuid>` and optional `expected_version` |

### Authentication

- `POST /auth/vendor/login` `{ email, password, vendor_type: "owner" }` -> `{ token, zone_wise_topic, module_type }` (a pending account also gets `approval_status: "pending"`).
- Wrong credentials / missing or wrong `vendor_type`: **401**. Missing fields: **403**. One token per merchant: a new login invalidates the old token.
- `GET /vendor/session/validate` returns the merchant and store. `POST /vendor/logout` revokes the token. **Call `POST /vendor/remove-fcm-token` before logout** so the device stops receiving pushes.
- Password reset: `POST /auth/vendor/forgot-password` `{ email }` -> `POST /auth/vendor/verify-token` `{ email, reset_token }` -> `PUT /auth/vendor/reset-password`.
- Auth routes are throttled (about 10 per minute per IP, 429).

### Error shapes
`{"errors":[{"code":"...","message":"..."}]}` with the HTTP status; Laravel validation may also return `errors: { field: [...] }` (422). Important codes: `merchant-not-approved` (403), `order-conflict` (409, stale `expected_version`), `order-transition-invalid` / `order_transition_invalid` (422), `order_not_found` (404), `active_orders_exist` / `wallet_balance_not_settled` (409), `pharmacy_request_not_actionable` (422), `options_required` (422), `review_not_found` (404).

## 2. App start, registration and approval

1. `GET /vendor/config` (after login): support contacts, legal links, currency, timezone, `maintenance_mode`, `minimum_versions { android, ios }`, store URLs. Use it for the force-update and maintenance screens.
2. Registration screen data (no token): `GET /auth/vendor/zones` -> `{ data: [{ id, name, display_name }] }`; `GET /auth/vendor/store-categories` (pharmacy, grocery, restaurant ...; it decides which product categories the store can use).
3. `POST /auth/vendor/register` (**multipart**): `f_name`, `l_name`, `email`, `phone`, `password` (min 8, upper/lower case, digit, symbol), `latitude`, `longitude` (inside the zone), `minimum_delivery_time`, `maximum_delivery_time`, `delivery_time_type`, `zone_id`, `module_id`, `tax`, `translations` (JSON string: item 0 = store name, item 1 = address), files `logo` (required) and `cover_photo`. **200** `{ store_id, message }`.
4. The account is **PENDING**. `GET /vendor/onboarding-status` -> `{ approval_status, can_operate, store_id, rejection_reason, documents[] }`. Upload documents with `POST /vendor/documents` (multipart `document_type`, `file` up to 10 MB) and stream your own with `GET /vendor/documents/{id}/file`.
5. An admin approves the account in the SSM admin panel. Until then every operational route answers **403** `merchant-not-approved`. Poll `onboarding-status` until `can_operate` is true.

## 3. Store profile, media and working hours

- `GET /vendor/profile` -> merchant + `stores[]` (logo/cover URLs, `schedules[]`). `PATCH`/`PUT /vendor/profile` updates `f_name`, `l_name`, `phone`, `email`, optional confirmed `password`, `store_name`, `store_phone`, `store_email`, `store_address` (empty body -> 422).
- **Store media and delivery settings:** `POST /vendor/profile/media` (multipart, all optional): `store_name`, `description`, `latitude`, `longitude`, `minimum_order`, `delivery_time` (e.g. `20-30 min`), `logo` (5 MB), `cover_photo` (8 MB), `profile_image` (5 MB); jpg/png/webp.
- Open/close the store: `POST /vendor/update-active-status` `{ is_open: true|false }`.
- `GET /vendor/dashboard-stats` -> authoritative counters for the home screen (`today`, `current`, `all_time`, `currency`, `timezone`); do not sum paginated lists in the app. Money values are two-decimal strings.
- **Working hours:** `GET /vendor/working-hours`; `PUT /vendor/working-hours` replaces the whole week. Exactly 7 distinct days, `day` 0 = Sunday ... 6 = Saturday; open days need `opening_time` and `closing_time` (`HH:mm`). Overnight shifts are allowed (`22:00` -> `02:00` returns `closes_next_day: true`). Invalid input -> 422 and the old schedule is kept.

## 4. Orders

You drive: `pending_merchant` -> **accept** -> `accepted` -> **start-preparing** -> `preparing` -> **ready-for-pickup** -> `ready_for_pickup`. Dispatch is then **automatic** (`dispatching` -> the nearest eligible driver gets an offer, one at a time). You cannot pick drivers.

| Screen / action | Endpoint |
|---|---|
| New + active orders | `GET /vendor/current-orders` (new = `ssm_status: pending_merchant`) |
| History | `GET /vendor/completed-orders?offset=1&limit=10` (`offset` = page number) |
| Order summary / lines | `GET /vendor/order?order_id=`, `GET /vendor/order-details?order_id=` |
| **Invoice view** | `GET /vendor/orders/{id}/full` -> `order`, decoded `details` (item, variation, add-ons) and `invoice { subtotal, tax, delivery_charge, coupon_discount, merchant_earning, platform_commission, total }` |
| Accept / start preparing / ready | `POST /vendor/orders/{id}/accept`, `/start-preparing`, `/ready-for-pickup` |
| Reject | `POST /vendor/orders/{id}/reject` `{ reason, note? }` |
| **Retry dispatch** | `POST /vendor/orders/{id}/retry-dispatch`: only when `ssm_status = assignment_failed` (no driver accepted). Restarts automatic dispatch and returns `{ outcome, assignment_id, reason }`. Any other status -> 422 `order_transition_invalid`. |
| **Export** | `GET /vendor/orders/export?from=&to=&status=&search=` -> CSV file (`order_id, status, payment_status, payment_method, amount, created_at`) |

Send an `Idempotency-Key` on every command (reuse it when retrying after a timeout) and optionally `expected_version` (the last `ssm_status_version` you saw): stale -> **409** `order-conflict`; not allowed from the current status -> **422**; another store's order -> **404**.

## 5. Catalog (products)

1. `GET /vendor/catalog/metadata` -> allowed `categories` (scoped to your store category) and `units`.
2. `GET /vendor/catalog/items?search=&status=active|inactive&per_page=` (paginated), `GET /vendor/catalog/items/{id}`.
3. Create: `POST /vendor/catalog/items` (multipart). Required `name`, `description`, `category_id`, `price`; optional `unit_id`, `stock`, `discount` + `discount_type` (`percent` | `amount`), `tax` + `tax_type`, `maximum_cart_quantity`, `organic`, `image`, up to 6 `images[]`. **201** `{ item }`.
4. Update: `POST /vendor/catalog/items/{id}` (multipart, send only what changes; `remove_images[]` deletes gallery images).
5. Quick actions: `PATCH /vendor/catalog/items/{id}/stock` `{ stock }`, `PATCH /vendor/catalog/items/{id}/status` `{ status: true|false }`.
6. Options: `PUT /vendor/catalog/items/{id}/options` with any of `variations`, `add_ons`, `choice_options`, `attributes` (arrays). Empty body -> 422 `options_required`.
7. Delete: `DELETE /vendor/catalog/items/{id}`. A product that already appears in an order cannot be deleted (**409**): disable it instead.

Product discounts set here are shown to customers (discount badge, old price) and applied by the order.

## 6. Pharmacy requests (pharmacy stores only)

- `GET /vendor/pharmacy-requests` (paged), `GET /vendor/pharmacy-requests/{id}`, `GET /vendor/pharmacy-requests/{id}/prescription` (private image stream; only for requests sent to **your** store).
- **Recommended flow - quote and let the customer approve:** `POST /vendor/pharmacy-requests/{id}/quote` `{ medicine_amount, medicine_summary, pharmacy_note? }` -> `status: quoted`. You can re-quote while it is still `quoted`. The customer accepts (a COD order is created and appears in your orders as `pending_merchant`) or rejects.
- Reject the request: `POST /vendor/pharmacy-requests/{id}/reject` `{ reason }` (required).
- Only `submitted` / `quoted` requests can be quoted or rejected; otherwise **422** `pharmacy_request_not_actionable`.
- **Legacy one-step flow:** `POST /vendor/pharmacy-requests/{id}/price` (same body) prices the request and creates the COD order immediately without asking the customer. Kept for older app builds; new builds should use `/quote`.

## 7. Wallet, earnings, reviews and analytics

- `GET /vendor/wallet` -> `wallet { total_earning, total_withdrawn, pending_withdraw, collected_cash, available_balance }` + paginated `withdraw_requests`. `available_balance = total_earning - total_withdrawn - pending_withdraw - collected_cash`.
- `GET /vendor/earnings?from=&to=&per_page=` -> `summary { gross, merchant_earning, platform_commission }` + paginated transactions.
- `POST /vendor/withdraw-requests` `{ amount, withdrawal_method_id?, withdrawal_method_fields? }` -> **201** `{ id, status: pending }`; the amount is reserved in `pending_withdraw`. More than the available balance -> 422.
- `GET /vendor/reviews?per_page=` -> `summary { average, count }` + reviews (`store_rating`, `comment`, customer name, `merchant_reply`). Reply: `POST /vendor/reviews/{id}/reply` `{ reply }`.
- `GET /vendor/analytics?from=&to=` -> `orders { total, delivered, cancelled }`, `sales { total, average_order_value }`, `top_items[]`.

## 8. Notifications, push and realtime

- Inbox: `GET /vendor/notifications?per_page=20&status=all|read|unread`, `GET /vendor/notifications/unread-count`, `PATCH /vendor/notifications/{id}/read`, `POST /vendor/notifications/read-all` (also for pending accounts).
- FCM: `POST /vendor/update-fcm-token` `{ fcm_token }` after login, `POST /vendor/remove-fcm-token` on logout. Pushes are minimal data messages; read REST after a push.
- Realtime: `POST /broadcasting/auth` with your bearer token; subscribe to `private-merchant.{merchant_id}` and `private-order.{order_id}`. Events: `.ssm.order.status_changed`, `.ssm.driver.assigned`, `.ssm.dispatch.assignment_failed` (offer a "retry dispatch" button), `.ssm.notification.created`. Refetch from REST after reconnecting.

## 9. Account deletion

`POST /vendor/account/delete-request` `{ reason? }` (or `DELETE /vendor/account`) -> **202** `{ status: pending }`; an admin completes it. Blocked with **409** while the store has active orders (`active_orders_exist`) or a wallet balance that is not settled (`wallet_balance_not_settled`).

## 10. Security guarantees (folder `90 Security Tests`)

Invalid/missing token or wrong `vendorType` -> 401. A pending account cannot use operational routes (403 `merchant-not-approved`). Another merchant's order, product, review, pharmacy request, prescription and notification are never reachable (404), even with spoofed `merchant_id` / `store_id` in the body; another merchant's document -> 403.

---

## Endpoint reference

Generated from the collection. **Auth** `token` = the app's own bearer token, `none` = public; another variable name means a second test account. **Expect** = the HTTP status(es) the request asserts. Request bodies are listed under each table.

### 00 Public setup data

No token. Lists used by the registration screens.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 1 | Zones | `GET /auth/vendor/zones` | none | 200 |
| 2 | Store categories (registration picker) | `GET /auth/vendor/store-categories` | none | 200 |

<details><summary>Notes, headers and bodies</summary>

**2. Store categories (registration picker)**

SSM store categories (pharmacy, grocery, restaurant ...). The chosen category decides which product categories the merchant can use in the catalog.

</details>

### 01 Registration & Onboarding (pending account)

Self-registration creates a PENDING account (vendor + store, both inactive). A pending merchant can log in and use onboarding routes only; every operational route returns HTTP 403 `merchant-not-approved` until an admin approves the account in the SSM admin panel.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 3 | Register merchant | `POST /auth/vendor/register` | none | 200 |
| 4 | Register with a weak password | `POST /auth/vendor/register` | none | 403 |
| 5 | Register with coordinates outside the zone | `POST /auth/vendor/register` | none | 403 |
| 6 | Login (pending account) | `POST /auth/vendor/login` | none | 200 |
| 7 | Login with the wrong password | `POST /auth/vendor/login` | none | 401 |
| 8 | Login without vendor_type | `POST /auth/vendor/login` | none | 401 |
| 9 | Onboarding status (pending) | `GET /vendor/onboarding-status` | `merchant_b_token` | 200 |
| 10 | Upload onboarding document | `POST /vendor/documents` | `merchant_b_token` | 201 |
| 11 | Upload document without a file (validation) | `POST /vendor/documents` | `merchant_b_token` | 422 |
| 12 | Onboarding status lists the document | `GET /vendor/onboarding-status` | `merchant_b_token` | 200 |
| 13 | Stream own document (private) | `GET /vendor/documents/{{merchant_doc_id}}/file` | `merchant_b_token` | 200 |
| 14 | Session validate (pending store is disabled) | `GET /vendor/session/validate` | `merchant_b_token` | 403 |
| 15 | Profile (pending store is disabled) | `GET /vendor/profile` | `merchant_b_token` | 403 |
| 16 | Operational: current orders blocked | `GET /vendor/current-orders` | `merchant_b_token` | 403 |
| 17 | Operational: store open/close blocked | `POST /vendor/update-active-status` | `merchant_b_token` | 403 |
| 18 | Operational: accept order blocked | `POST /vendor/orders/{{order_id}}/accept` | `merchant_b_token` | 403 |
| 19 | Operational: pharmacy requests blocked | `GET /vendor/pharmacy-requests` | `merchant_b_token` | 403 |

<details><summary>Notes, headers and bodies</summary>

**3. Register merchant**

Multipart form. `translations` is a JSON string: item 0 = store name, item 1 = store address (`locale`, `key`, `value`). Success is HTTP 200 with `store_id` (the response `type` is a legacy field). Fields `logo` (required) and `cover_photo` are image files.

```text
f_name = Pending
l_name = Merchant
email = {{merchant_b_email}}
phone = {{merchant_b_phone}}
password = {{merchant_b_password}}
latitude = 30.046238984913945
longitude = 31.37147956572359
minimum_delivery_time = 10
maximum_delivery_time = 30
delivery_time_type = min
module_id = {{module_id}}
tax = 0
translations = [{"locale":"en","key":"name","value":"Postman Test Store"},{"locale":"en","key":"address","value":"Cairo, Egypt"}]
logo = <file>
cover_photo = <file>
```

**4. Register with a weak password**

```text
f_name = Pending
l_name = Merchant
email = {{merchant_weak_email}}
phone = {{merchant_weak_phone}}
password = abc
latitude = 30.046238984913945
longitude = 31.37147956572359
minimum_delivery_time = 10
maximum_delivery_time = 30
delivery_time_type = min
module_id = {{module_id}}
tax = 0
translations = [{"locale":"en","key":"name","value":"Postman Test Store"},{"locale":"en","key":"address","value":"Cairo, Egypt"}]
logo = <file>
cover_photo = <file>
```

**5. Register with coordinates outside the zone**

```text
f_name = Pending
l_name = Merchant
email = {{merchant_far_email}}
phone = {{merchant_far_phone}}
password = {{merchant_far_password}}
latitude = 21.5400
longitude = 39.1700
minimum_delivery_time = 10
maximum_delivery_time = 30
delivery_time_type = min
module_id = {{module_id}}
tax = 0
translations = [{"locale":"en","key":"name","value":"Postman Test Store"},{"locale":"en","key":"address","value":"Cairo, Egypt"}]
logo = <file>
cover_photo = <file>
```

**6. Login (pending account)**

Body must include `vendor_type: "owner"`. A pending account still receives a token, together with `approval_status`.

```json
{
  "email": "{{merchant_b_email}}",
  "password": "{{merchant_b_password}}",
  "vendor_type": "owner"
}
```

**7. Login with the wrong password**

```json
{
  "email": "{{merchant_b_email}}",
  "password": "Wrong#Pass1",
  "vendor_type": "owner"
}
```

**8. Login without vendor_type**

```json
{
  "email": "{{merchant_b_email}}",
  "password": "{{merchant_b_password}}"
}
```

**10. Upload onboarding document**

```text
document_type = commercial_registration
file = <file>
```

**11. Upload document without a file (validation)**

```text
document_type = commercial_registration
```

**14. Session validate (pending store is disabled)**

Session validation needs an active store. A pending account gets HTTP 403 `Merchant store is administratively disabled.`; use `onboarding-status` to poll approval.

**17. Operational: store open/close blocked**

```json
{
  "is_open": true
}
```

**18. Operational: accept order blocked**

Headers: `Idempotency-Key: {{$guid}}`

</details>

### 02 Post-approval check (the registered account)

Run after an admin approved the account created in folder 01. The same token now reaches operational routes.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 20 | Onboarding status (approved) | `GET /vendor/onboarding-status` | `merchant_b_token` | 200 |
| 21 | Session validate (approved) | `GET /vendor/session/validate` | `merchant_b_token` | 200 |
| 22 | Current orders (approved, no orders yet) | `GET /vendor/current-orders` | `merchant_b_token` | 200 |

### 03 Session & Profile (approved merchant)

Login for an approved merchant returns `{ token, zone_wise_topic, module_type }`. Tokens are opaque and stored server-side; `POST /vendor/logout` revokes them.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 23 | Login (approved merchant) | `POST /auth/vendor/login` | none | 200 |
| 24 | Session validate | `GET /vendor/session/validate` | token | 200 |
| 25 | Profile and store | `GET /vendor/profile` | token | 200 |
| 26 | Merchant app config | `GET /vendor/config` | token | 200 |
| 27 | Onboarding status (approved) | `GET /vendor/onboarding-status` | token | 200 |
| 28 | Merchant dashboard stats | `GET /vendor/dashboard-stats` | token | 200 |
| 29 | Update merchant and store profile | `PATCH /vendor/profile` | token | 200 |
| 30 | Update profile (PUT alias) | `PUT /vendor/profile` | token | 200 |
| 31 | Update store media and delivery settings | `POST /vendor/profile/media` | token | 200 |
| 32 | Update store media with a non-image logo (validation) | `POST /vendor/profile/media` | token | 422 |
| 33 | Update profile (empty body) | `PATCH /vendor/profile` | token | 422 |
| 34 | Update password (confirmation mismatch) | `PATCH /vendor/profile` | token | 422 |
| 35 | Register FCM token | `POST /vendor/update-fcm-token` | token | 200 |
| 36 | Open the store | `POST /vendor/update-active-status` | token | 200 |
| 37 | Update store status with an invalid value | `POST /vendor/update-active-status` | token | 422 |

<details><summary>Notes, headers and bodies</summary>

**23. Login (approved merchant)**

```json
{
  "email": "{{merchant_email}}",
  "password": "{{merchant_password}}",
  "vendor_type": "owner"
}
```

**26. Merchant app config**

Support contacts, legal links, currency, timezone, maintenance flag, minimum app versions and store URLs for the merchant app. Call it on app start.

**28. Merchant dashboard stats**

The mobile merchant dashboard endpoint. Counts and revenue are scoped to the authenticated merchant store; the app must not calculate totals from paginated order lists.

**29. Update merchant and store profile**

```json
{
  "f_name": "Mobile",
  "l_name": "Merchant",
  "store_name": "SSM Mobile Test Store",
  "store_address": "Tahlia St, Riyadh"
}
```

**30. Update profile (PUT alias)**

```json
{
  "f_name": "Mobile",
  "l_name": "Merchant"
}
```

**31. Update store media and delivery settings**

Multipart. Every field is optional: `store_name`, `description`, `latitude`, `longitude`, `minimum_order`, `delivery_time` (e.g. `20-30 min`), `logo`, `cover_photo`, `profile_image` (jpg/png/webp; logo and profile up to 5 MB, cover up to 8 MB). Throttled (sensitive upload).

```text
delivery_time = 20-30 min
minimum_order = 25
logo = <file>
cover_photo = <file>
```

**32. Update store media with a non-image logo (validation)**

```text
logo = not-a-file
```

**33. Update profile (empty body)**

```json
{}
```

**34. Update password (confirmation mismatch)**

```json
{
  "password": "NewStrong#123",
  "password_confirmation": "Different#123"
}
```

**35. Register FCM token**

```json
{
  "fcm_token": "postman-merchant-fcm-token-not-real"
}
```

**36. Open the store**

```json
{
  "is_open": true
}
```

**37. Update store status with an invalid value**

```json
{
  "is_open": "maybe"
}
```

</details>

### 03b Password recovery (manual opt-in)

Requests are skipped unless explicitly enabled because they may send a real SMS/e-mail. Set `merchant_reset_token` after receiving the OTP.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 38 | Request password reset OTP *(opt-in: `run_merchant_password_recovery`)* | `POST /auth/vendor/forgot-password` | none | 200 |
| 39 | Verify password reset OTP | `POST /auth/vendor/verify-token` | none | 200 |
| 40 | Reset password | `PUT /auth/vendor/reset-password` | none | 200 |

<details><summary>Notes, headers and bodies</summary>

**38. Request password reset OTP**

```json
{
  "email": "{{merchant_email}}"
}
```

**39. Verify password reset OTP**

```json
{
  "email": "{{merchant_email}}",
  "reset_token": "{{merchant_reset_token}}"
}
```

**40. Reset password**

```json
{
  "email": "{{merchant_email}}",
  "reset_token": "{{merchant_reset_token}}",
  "password": "{{merchant_new_password}}",
  "confirm_password": "{{merchant_new_password}}"
}
```

</details>

### 04 Orders

Orders for the authenticated merchant's store only. Lifecycle: `pending_merchant` → accept → `accepted` → start-preparing → `preparing` → ready-for-pickup → `ready_for_pickup` (dispatch to Drivers then starts automatically: `dispatching`). "New orders" are `current-orders` with `ssm_status = pending_merchant`; "Active orders" are the other non-terminal ones; "History" is `completed-orders`. Mutations accept an `Idempotency-Key` header and an optional `expected_version` (stale version → 409).

#### 04 Orders / 04a Order reads

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 41 | Current orders (new + active) | `GET /vendor/current-orders` | token | 200 |
| 42 | Order (summary) | `GET /vendor/order?order_id={{order_id}}` | token | 200 |
| 43 | Order lines | `GET /vendor/order-details?order_id={{order_id}}` | token | 200 |

#### 04 Orders / 04b Lifecycle to ready_for_pickup

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 44 | Accept with a stale expected_version | `POST /vendor/orders/{{order_id}}/accept` | token | 409 |
| 45 | Start preparing before accepting (invalid transition) | `POST /vendor/orders/{{order_id}}/start-preparing` | token | 422 |
| 46 | Accept order | `POST /vendor/orders/{{order_id}}/accept` | token | 200 |
| 47 | Accept again with a new key (already accepted) | `POST /vendor/orders/{{order_id}}/accept` | token | 409 / 422 |
| 48 | Start preparing | `POST /vendor/orders/{{order_id}}/start-preparing` | token | 200 |
| 49 | Ready for pickup | `POST /vendor/orders/{{order_id}}/ready-for-pickup` | token | 200 |
| 50 | Order after ready (dispatching or assigned) | `GET /vendor/order?order_id={{order_id}}` | token | 200 |

<details><summary>Notes, headers and bodies</summary>

**44. Accept with a stale expected_version**

Headers: `Idempotency-Key: {{$guid}}`

```json
{
  "expected_version": 999
}
```

**45. Start preparing before accepting (invalid transition)**

Headers: `Idempotency-Key: {{$guid}}`

**46. Accept order**

Headers: `Idempotency-Key: {{$guid}}`

**47. Accept again with a new key (already accepted)**

Headers: `Idempotency-Key: {{$guid}}`

**48. Start preparing**

Headers: `Idempotency-Key: {{$guid}}`

**49. Ready for pickup**

Triggers automatic dispatch: the Order moves to `dispatching` and the nearest eligible Driver receives an offer.

Headers: `Idempotency-Key: {{$guid}}`

</details>

#### 04 Orders / 04c Reject and history

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 51 | Reject a second order | `POST /vendor/orders/{{order_reject_id}}/reject` | token | 200 |
| 52 | Reject without a reason (validation) | `POST /vendor/orders/{{order_id}}/reject` | token | 422 |
| 53 | Order history | `GET /vendor/completed-orders?offset=1&limit=10` | token | 200 |
| 54 | Order history with an invalid limit | `GET /vendor/completed-orders?limit=1000` | token | 422 |

<details><summary>Notes, headers and bodies</summary>

**51. Reject a second order**

Headers: `Idempotency-Key: {{$guid}}`

```json
{
  "reason": "Out of stock",
  "note": "Item unavailable today"
}
```

**52. Reject without a reason (validation)**

Headers: `Idempotency-Key: {{$guid}}`

```json
{}
```

</details>

#### 04 Orders / 04d Invoice, export & dispatch retry

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 55 | Full order (invoice view) | `GET /vendor/orders/{{order_id}}/full` | token | 200 |
| 56 | Full order of another store | `GET /vendor/orders/999999/full` | token | 404 |
| 57 | Export orders (CSV) | `GET /vendor/orders/export?from=2026-01-01&to=2026-12-31` | token | 200 |
| 58 | Export orders with an invalid range (validation) | `GET /vendor/orders/export?from=2026-12-31&to=2026-01-01` | token | 422 |
| 59 | Retry dispatch (only for assignment_failed) | `POST /vendor/orders/{{order_id}}/retry-dispatch` | token | 422 |

<details><summary>Notes, headers and bodies</summary>

**55. Full order (invoice view)**

Order row, decoded line items (`item_details`, `variation`, `add_ons`) and an invoice block: `subtotal`, `tax`, `delivery_charge`, `coupon_discount`, `merchant_earning`, `platform_commission`, `total`.

**57. Export orders (CSV)**

Streams `text/csv` with columns `order_id, status, payment_status, payment_method, amount, created_at`. Optional filters: `from`, `to` (Y-m-d), `status` (ssm_status), `search` (order id).

**59. Retry dispatch (only for assignment_failed)**

Use when no driver accepted the order (`ssm_status = assignment_failed`): it restarts automatic dispatch and returns `{ outcome, assignment_id, reason }`. For any other status it answers `422 order_transition_invalid` (what this request checks).

</details>

### 05 Notifications

In-app inbox for the merchant (new orders and order events). Same shape as the other apps.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 60 | List notifications | `GET /vendor/notifications?per_page=20` | token | 200 |
| 61 | List unread only | `GET /vendor/notifications?status=unread&per_page=5` | token | 200 |
| 62 | Unread count | `GET /vendor/notifications/unread-count` | token | 200 |
| 63 | Mark one notification read | `PATCH /vendor/notifications/{{merchant_notification_id}}/read` | token | 200 |
| 64 | Mark all notifications read | `POST /vendor/notifications/read-all` | token | 200 |
| 65 | Unread count after read-all | `GET /vendor/notifications/unread-count` | token | 200 |

### 05b Catalog (products)

Products of the merchant's own store. `GET /vendor/catalog/metadata` returns the allowed product categories (scoped to the store category) and units. Create/update are multipart (`image`, up to 6 `images[]`, `remove_images[]`). A product that was used in an order cannot be deleted (409): disable it instead.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 66 | Catalog metadata (categories & units) | `GET /vendor/catalog/metadata` | token | 200 |
| 67 | List products | `GET /vendor/catalog/items?per_page=20&status=active` | token | 200 |
| 68 | Create product | `POST /vendor/catalog/items` | token | 201 |
| 69 | Create product without required fields (validation) | `POST /vendor/catalog/items` | token | 422 |
| 70 | Product details | `GET /vendor/catalog/items/{{catalog_item_id}}` | token | 200 |
| 71 | Update product (multipart, partial) | `POST /vendor/catalog/items/{{catalog_item_id}}` | token | 200 |
| 72 | Update stock | `PATCH /vendor/catalog/items/{{catalog_item_id}}/stock` | token | 200 |
| 73 | Update stock with a negative value (validation) | `PATCH /vendor/catalog/items/{{catalog_item_id}}/stock` | token | 422 |
| 74 | Disable product | `PATCH /vendor/catalog/items/{{catalog_item_id}}/status` | token | 200 |
| 75 | Enable product | `PATCH /vendor/catalog/items/{{catalog_item_id}}/status` | token | 200 |
| 76 | Update product options (variations & add-ons) | `PUT /vendor/catalog/items/{{catalog_item_id}}/options` | token | 200 |
| 77 | Update product options with an empty body | `PUT /vendor/catalog/items/{{catalog_item_id}}/options` | token | 422 |
| 78 | Product of another store | `GET /vendor/catalog/items/999999` | token | 404 |
| 79 | Delete product | `DELETE /vendor/catalog/items/{{catalog_item_id}}` | token | 200 / 409 |

<details><summary>Notes, headers and bodies</summary>

**67. List products**

Filters: `search`, `status` (active | inactive), `per_page` (1-100). Laravel pagination.

**68. Create product**

Required: `name`, `description`, `category_id` (from metadata), `price`. Optional: `unit_id`, `stock`, `discount` + `discount_type` (percent | amount), `tax` + `tax_type`, `maximum_cart_quantity`, `organic`, `image`, `images[]`.

```text
name = Postman Test Product
description = Created from the Postman collection.
category_id = {{catalog_category_id}}
price = 19.50
stock = 40
discount = 10
discount_type = percent
image = <file>
```

**69. Create product without required fields (validation)**

```text
name = x
```

**71. Update product (multipart, partial)**

POST (not PUT) because it is multipart. Send only the fields that change.

```text
price = 21.00
description = Updated from Postman.
```

**72. Update stock**

```json
{
  "stock": 25
}
```

**73. Update stock with a negative value (validation)**

```json
{
  "stock": -1
}
```

**74. Disable product**

```json
{
  "status": false
}
```

**75. Enable product**

```json
{
  "status": true
}
```

**76. Update product options (variations & add-ons)**

Replaces any of `variations`, `add_ons`, `choice_options`, `attributes` (arrays, stored as JSON). Send at least one of them.

```json
{
  "variations": [
    {
      "type": "Small",
      "price": 19.5,
      "stock": 10
    },
    {
      "type": "Large",
      "price": 27,
      "stock": 10
    }
  ],
  "choice_options": [
    {
      "name": "choice_1",
      "title": "Size",
      "options": [
        "Small",
        "Large"
      ]
    }
  ],
  "attributes": [
    1
  ],
  "add_ons": []
}
```

**77. Update product options with an empty body**

```json
{}
```

**79. Delete product**

409 when the product already appears in an order.

</details>

### 05c Working hours

Weekly schedule of the merchant store. `day` 0 = Sunday ... 6 = Saturday. Overnight shifts are allowed (e.g. 22:00 to 02:00) and are returned with `closes_next_day: true`.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 80 | Get working hours | `GET /vendor/working-hours` | token | 200 |
| 81 | Update working hours (all 7 days) | `PUT /vendor/working-hours` | token | 200 |
| 82 | Update working hours with 6 days (validation) | `PUT /vendor/working-hours` | token | 422 |

<details><summary>Notes, headers and bodies</summary>

**81. Update working hours (all 7 days)**

```json
{
  "days": [
    {
      "day": 0,
      "is_open": true,
      "opening_time": "09:00",
      "closing_time": "23:00"
    },
    {
      "day": 1,
      "is_open": true,
      "opening_time": "09:00",
      "closing_time": "23:00"
    },
    {
      "day": 2,
      "is_open": true,
      "opening_time": "09:00",
      "closing_time": "23:00"
    },
    {
      "day": 3,
      "is_open": true,
      "opening_time": "09:00",
      "closing_time": "23:00"
    },
    {
      "day": 4,
      "is_open": true,
      "opening_time": "22:00",
      "closing_time": "02:00"
    },
    {
      "day": 5,
      "is_open": false,
      "opening_time": null,
      "closing_time": null
    },
    {
      "day": 6,
      "is_open": true,
      "opening_time": "09:00",
      "closing_time": "23:00"
    }
  ]
}
```

**82. Update working hours with 6 days (validation)**

```json
{
  "days": [
    {
      "day": 0,
      "is_open": false
    }
  ]
}
```

</details>

### 06 Pharmacy Requests

A merchant sees only requests addressed to its own store. Recommended flow: quote (`/quote`) and let the customer accept or reject; `/reject` declines the request. The legacy one-step `/price` (prices and creates the order immediately) is opt-in. The prescription is a private stream: the stored path is never returned.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 83 | List pharmacy requests | `GET /vendor/pharmacy-requests?limit=15` | token | 200 |
| 84 | Pharmacy request details | `GET /vendor/pharmacy-requests/{{pharmacy_request_id}}` | token | 200 |
| 85 | Prescription (private stream) | `GET /vendor/pharmacy-requests/{{pharmacy_request_id}}/prescription` | token | 200 |
| 86 | Unknown pharmacy request | `GET /vendor/pharmacy-requests/999999` | token | 404 |
| 87 | Send a price quote to the customer | `POST /vendor/pharmacy-requests/{{pharmacy_request_id}}/quote` | token | 200 / 422 |
| 88 | Quote without a summary (validation) | `POST /vendor/pharmacy-requests/{{pharmacy_request_id}}/quote` | token | 422 |
| 89 | Reject an unknown pharmacy request | `POST /vendor/pharmacy-requests/999999/reject` | token | 422 |
| 90 | Direct price and create COD order (legacy flow, opt-in) *(opt-in: `run_pharmacy_direct_price`)* | `POST /vendor/pharmacy-requests/{{pharmacy_request_id}}/price` | token | 200 / 201 / 422 |

<details><summary>Notes, headers and bodies</summary>

**87. Send a price quote to the customer**

Recommended flow. Moves a `submitted` (or re-prices a `quoted`) request to `quoted`. The customer then accepts (`POST /customer/pharmacy-requests/{id}/accept-quote`, which creates the COD order) or rejects it. 422 `pharmacy_request_not_actionable` when the request is already converted/rejected.

```json
{
  "medicine_amount": 185.5,
  "medicine_summary": "Panadol Extra 24 tablets x 1; Vitamin C x 1",
  "pharmacy_note": "Substitution only if the original is unavailable."
}
```

**88. Quote without a summary (validation)**

```json
{
  "medicine_amount": 10
}
```

**89. Reject an unknown pharmacy request**

Body: `reason` (required). Allowed only while the request is `submitted` or `quoted`.

```json
{
  "reason": "Out of stock"
}
```

**90. Direct price and create COD order (legacy flow, opt-in)**

Older one-step flow: prices the request AND immediately creates the COD order without asking the customer. Kept for backward compatibility; new app builds should use `/quote`. Skipped unless `run_pharmacy_direct_price` is set.

```json
{
  "medicine_amount": 185.5,
  "medicine_summary": "Panadol Extra 24 tablets x 1; Vitamin C x 1",
  "pharmacy_note": "Substitution only if the original is unavailable."
}
```

</details>

### 07 Wallet, Earnings, Reviews & Analytics

Approved merchants only. Money values are numbers in the store currency.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 91 | Wallet | `GET /vendor/wallet` | token | 200 |
| 92 | Earnings (date range) | `GET /vendor/earnings?from=2026-01-01&to=2026-12-31&per_page=20` | token | 200 |
| 93 | Earnings with an invalid range (validation) | `GET /vendor/earnings?from=2026-12-31&to=2026-01-01` | token | 422 |
| 94 | Withdraw more than the balance | `POST /vendor/withdraw-requests` | token | 422 |
| 95 | Withdraw without an amount (validation) | `POST /vendor/withdraw-requests` | token | 422 |
| 96 | Reviews | `GET /vendor/reviews?per_page=20` | token | 200 |
| 97 | Reply to a review | `POST /vendor/reviews/{{review_id}}/reply` | token | 200 |
| 98 | Reply to an unknown review | `POST /vendor/reviews/999999/reply` | token | 404 |
| 99 | Analytics | `GET /vendor/analytics?from=2026-01-01&to=2026-12-31` | token | 200 |

<details><summary>Notes, headers and bodies</summary>

**91. Wallet**

`available_balance = total_earning - total_withdrawn - pending_withdraw - collected_cash`, plus the paginated withdrawal requests.

**94. Withdraw more than the balance**

Body: `amount` (required, >= 1), optional `withdrawal_method_id` and `withdrawal_method_fields` (object). A valid request returns 201 `{ id, status: pending }` and reserves the amount in `pending_withdraw`.

```json
{
  "amount": 99999999
}
```

**95. Withdraw without an amount (validation)**

```json
{}
```

**96. Reviews**

Customer reviews of delivered orders (`store_rating` 1-5, optional `comment`, `merchant_reply`).

**97. Reply to a review**

```json
{
  "reply": "Thank you for your order!"
}
```

**98. Reply to an unknown review**

```json
{
  "reply": "x"
}
```

</details>

### 90 Security Tests

Negative tests. `merchant_b_token` belongs to a second merchant (folder 01/02) whose store owns no orders.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 100 | Invalid token | `GET /vendor/session/validate` | invalid token | 401 |
| 101 | No token | `GET /vendor/current-orders` | none | 401 |
| 102 | Invalid vendorType header | `GET /vendor/session/validate` | token | 401 |
| 103 | Register a second merchant that stays pending | `POST /auth/vendor/register` | none | 200 |
| 104 | Login the pending merchant | `POST /auth/vendor/login` | none | 200 |
| 105 | Pending account cannot read orders | `GET /vendor/current-orders` | `merchant_pending_token` | 403 |
| 106 | Pending account cannot accept orders | `POST /vendor/orders/{{order_id}}/accept` | `merchant_pending_token` | 403 |
| 107 | Foreign order summary | `GET /vendor/order?order_id={{order_id}}` | `merchant_b_token` | 404 |
| 108 | Foreign order lines | `GET /vendor/order-details?order_id={{order_id}}` | `merchant_b_token` | 404 |
| 109 | Foreign order accept | `POST /vendor/orders/{{order_id}}/accept` | `merchant_b_token` | 403 / 404 |
| 110 | Foreign order accept with a spoofed merchant_id/store_id in the body | `POST /vendor/orders/{{order_id}}/accept` | `merchant_b_token` | 403 / 404 |
| 111 | Foreign order reject | `POST /vendor/orders/{{order_id}}/reject` | `merchant_b_token` | 403 / 404 |
| 112 | Foreign pharmacy request | `GET /vendor/pharmacy-requests/{{pharmacy_request_id}}` | `merchant_b_token` | 404 |
| 113 | Foreign prescription | `GET /vendor/pharmacy-requests/{{pharmacy_request_id}}/prescription` | `merchant_b_token` | 404 |
| 114 | Foreign store: open/close with a spoofed store_id acts on the caller's own store only | `POST /vendor/update-active-status` | `merchant_b_token` | 200 |
| 115 | Foreign document download | `GET /vendor/documents/{{merchant_doc_id}}/file` | token | 403 / 404 |
| 116 | Foreign notification (real id owned by another merchant) | `PATCH /vendor/notifications/{{merchant_notification_id}}/read` | `merchant_b_token` | 404 |
| 117 | Unknown notification id | `PATCH /vendor/notifications/00000000-0000-0000-0000-000000000000/read` | token | 404 |

<details><summary>Notes, headers and bodies</summary>

**103. Register a second merchant that stays pending**

```text
f_name = Pending
l_name = Merchant
email = {{merchant_c_email}}
phone = {{merchant_c_phone}}
password = {{merchant_c_password}}
latitude = 30.046238984913945
longitude = 31.37147956572359
minimum_delivery_time = 10
maximum_delivery_time = 30
delivery_time_type = min
module_id = {{module_id}}
tax = 0
translations = [{"locale":"en","key":"name","value":"Postman Test Store"},{"locale":"en","key":"address","value":"Cairo, Egypt"}]
logo = <file>
cover_photo = <file>
```

**104. Login the pending merchant**

```json
{
  "email": "{{merchant_c_email}}",
  "password": "{{merchant_c_password}}",
  "vendor_type": "owner"
}
```

**106. Pending account cannot accept orders**

Headers: `Idempotency-Key: {{$guid}}`

**109. Foreign order accept**

Headers: `Idempotency-Key: {{$guid}}`

**110. Foreign order accept with a spoofed merchant_id/store_id in the body**

Identity comes from the token only; body identifiers are ignored.

Headers: `Idempotency-Key: {{$guid}}`

```json
{
  "merchant_id": "{{merchant_id}}",
  "vendor_id": "{{merchant_id}}",
  "store_id": "{{store_id}}"
}
```

**111. Foreign order reject**

Headers: `Idempotency-Key: {{$guid}}`

```json
{
  "reason": "spoof"
}
```

**114. Foreign store: open/close with a spoofed store_id acts on the caller's own store only**

```json
{
  "is_open": false,
  "store_id": "{{store_id}}",
  "merchant_id": "{{merchant_id}}"
}
```

**115. Foreign document download**

Uses the approved merchant token against the pending merchant's document id.

</details>

### 98 Account deletion (merchant B)

Uses the second test merchant so the main account keeps working. Blocked with 409 while the store has active orders (`active_orders_exist`) or an unsettled wallet (`wallet_balance_not_settled`). `DELETE /vendor/account` is an alias.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 118 | Request account deletion | `POST /vendor/account/delete-request` | `merchant_b_token` | 202 / 409 |
| 119 | Request account deletion (DELETE alias) | `DELETE /vendor/account` | `merchant_b_token` | 202 / 409 |

<details><summary>Notes, headers and bodies</summary>

**118. Request account deletion**

```json
{
  "reason": "Postman test"
}
```

</details>

### 99 Logout

Revokes the current token. It is the last folder on purpose: it invalidates `merchant_token`.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 120 | Remove FCM token (call on logout) | `POST /vendor/remove-fcm-token` | token | 200 |
| 121 | Logout | `POST /vendor/logout` | token | 200 |
| 122 | Session validate after logout | `GET /vendor/session/validate` | token | 401 |

<details><summary>Notes, headers and bodies</summary>

**120. Remove FCM token (call on logout)**

Stops push notifications to this device. Call it before `/vendor/logout`.

</details>
