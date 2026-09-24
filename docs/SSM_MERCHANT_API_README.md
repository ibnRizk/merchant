# SSM Merchant API — Postman Collection

Postman collection for the **Merchant (store owner) mobile app**: 88 requests covering all 39 merchant endpoints on the server. Every endpoint in the collection exists on the server, and every merchant endpoint on the server is in the collection (checked against `php artisan route:list` on 2026-09-25).

| File | Purpose |
|---|---|
| `SSM_MERCHANT_API.postman_collection.json` | The requests, grouped in numbered folders |
| `SSM_LOCAL.postman_environment.json` | Optional, **local development only** (see [Environments](#environments)) |
| `../SSM_MERCHANT_API_GUIDE.md` | Longer contract document. It is older than this README and **does not cover products** (section 8 says catalog is not part of the API; that is no longer true) |

---

## Quick start (against the live server)

1. In Postman choose **Import** and select `SSM_MERCHANT_API.postman_collection.json`.
2. Set the environment selector to **No Environment**. The collection's own variables already point at the server:
   - `base_url` = `https://ssm.husseintech.com/api/v1`
   - `zone_id` = `7` (Mansoura)
   - `module_id` = `1`
3. Run the folders **in order** (next section). Tokens and IDs are saved automatically after each request, so you don't need to copy anything by hand.

## Run order

| Step | Folder | What happens |
|---|---|---|
| 1 | `01 Registration & Onboarding` | Lists the merchant categories (saves the first as `store_category_id`), then registers a new merchant and store in that category. The account starts as **pending**, so operational routes return 403. Uploads an onboarding document. |
| 2 | *(admin panel)* | An admin approves the merchant at `https://ssm.husseintech.com/ssm-admin`. **There is no API to approve.** |
| 3 | `02 Post-approval check` | Same token, and now `can_operate: true`. |
| 4 | `03 Session & Profile` | Logs in as the approved merchant (saves `merchant_token`), then reads and updates the profile and opens the store. |
| 5 | `04 Orders` | Needs at least **two orders in `pending_merchant`** for this store. Customers place these from the customer app. `Current orders` saves `order_id` and `order_reject_id`. |
| 6 | `05 Notifications`, `06 Pharmacy Requests` | Read-only. The pharmacy folder only returns data for pharmacy stores. |
| 7 | `05 Catalog & Products` | Run `Catalog metadata` first, then `Create product`. This folder is placed after `90` in the file; run it before `99 Logout`. |
| 8 | `90 Security Tests` | Negative tests that are expected to fail: foreign orders, spoofed IDs, bad tokens. |
| 9 | `99 Logout` | Revokes the token. |

`03b Password recovery` is **opt-in**. It can send a real e-mail, and it needs `merchant_reset_token` (from the e-mail) and `merchant_new_password`, which you fill in by hand.

## Environments

- **Server testing:** use *No Environment*. Collection variables are used.
- **Local Laravel (`php artisan serve`):** select `SSM Local`. It overrides `base_url` to `http://127.0.0.1:8000/api/v1` and `zone_id` to `1`.

> ⚠️ Do **not** use `SSM Local` against the live server. Its `zone_id=1` is the demo zone, which has been **disabled** on the server. Registering with it fails, and orders in it are never dispatched. Use zone `7`.

## Variables saved automatically

| Variable | Saved by |
|---|---|
| `store_category_id` | `List merchant categories (registration screen)` — first active category, empty if none |
| `merchant_email`, `merchant_password`, `merchant_b_*` | `Register merchant` (random, unique per run) |
| `merchant_b_token` | `Login (pending account)` |
| `merchant_doc_id` | `Upload onboarding document` |
| `merchant_token` | `Login (approved merchant)` — the main token for every later request |
| `merchant_id` | `Session validate` |
| `store_id` | `Profile and store` |
| `order_id`, `order_reject_id` | `Current orders (new + active)` |
| `order_version` | `Order (summary)`, `Accept order`, `Start preparing` |
| `merchant_notification_id` | `List notifications` |
| `pharmacy_request_id` | `List pharmacy requests` |
| `catalog_category_id`, `catalog_unit_id` | `Catalog metadata (run first)` |
| `merchant_item_id` | `Create product` |

---

## Conventions

| Item | Value |
|---|---|
| Headers on every request | `Accept: application/json`, `vendorType: owner`, `X-localization: ar` or `en` |
| Auth | `Authorization: Bearer {{merchant_token}}`. This is an opaque token from login, not Passport. A new login replaces the old token, which then returns 401. |
| Body | JSON. **Multipart** for: register, document upload, product create/update. |
| Order commands | Send `Idempotency-Key: <uuid>`. When retrying after a timeout, reuse the **same** key. Optionally send `expected_version` (the last `ssm_status_version` you saw). |
| Throttling | `/auth/vendor/*` allows 10 requests per minute per IP (429). |
| Error body | `{"errors":[{"code":"...","message":"..."}]}`. Laravel validation errors return 422 with field errors. |

### Status codes you will see

| Code | Meaning |
|---|---|
| 401 | Missing or invalid token, or `vendorType` is not `owner` |
| 403 | Account not approved yet: `{"errors":[{"code":"merchant-not-approved","approval_status":"pending"}]}`. Some legacy validation errors (login/register) also return 403. |
| 404 | Not found, **or it belongs to another merchant**. The API never reveals other merchants' data. |
| 409 | Stale `expected_version` (`order-conflict`), or deleting a product that is used in orders |
| 422 | Validation error, or an order transition that isn't allowed (`order-transition-invalid`) |

---

## Endpoints

"Approved" means the route returns 403 `merchant-not-approved` until an admin approves the account.

### Auth and registration (no token)

| Method | Path | Notes |
|---|---|---|
| GET | `/auth/vendor/store-categories` | Merchant categories for the registration screen (see below) |
| POST | `/auth/vendor/register` | **multipart**, see below. 200 `{store_id, message}` |
| POST | `/auth/vendor/login` | `{email, password, vendor_type: "owner"}` → `{token, zone_wise_topic, module_type}`, plus `approval_status: "pending"` for pending accounts |
| POST | `/auth/vendor/forgot-password` | Sends the reset OTP by e-mail |
| POST | `/auth/vendor/verify-token` | Checks the reset OTP |
| PUT | `/auth/vendor/reset-password` | Sets the new password |

**Register fields:**
- Merchant: `f_name`, `l_name`, `email`, `phone`, `password`. The password needs at least 8 characters with uppercase and lowercase letters, a digit and a symbol.
- Store location: `latitude` and `longitude`, which **must be inside `zone_id`**; otherwise the API returns 403.
- Delivery time: `minimum_delivery_time`, `maximum_delivery_time`, `delivery_time_type`.
- Other: `zone_id`, `module_id`, `tax`.
- `store_category_id`: the merchant's category, from `GET /auth/vendor/store-categories`. **Optional for now** (older app builds don't send it); an unknown or inactive id returns 403 with error code `store_category_id`.
- `translations`: a JSON string. Item 0 is the store name and item 1 is the address:
  ```json
  [{"locale":"en","key":"name","value":"My Store"},{"locale":"en","key":"address","value":"Street, City"}]
  ```
- Files: `logo` (required) and `cover_photo`.

### Merchant categories

The admin manages the list in the admin panel under **Business → Merchant categories** (Arabic and English names, order, active flag). The merchant picks one at registration.

`GET /auth/vendor/store-categories` needs **no token** (the merchant has no account yet). It returns only active categories, in display order. `name` follows the `X-localization` header; `name_ar` and `name_en` are always included:

```json
{ "categories": [ { "id": 1, "name": "مطعم", "name_ar": "مطعم", "name_en": "Restaurant" } ] }
```

The chosen category comes back in the profile as `stores[0].category` (same shape), or `null` for stores without one.

### Onboarding (token, works while pending)

| Method | Path | Notes |
|---|---|---|
| GET | `/vendor/onboarding-status` | `{merchant_id, approval_status, can_operate, account_status, store_id, store_name, store_open, rejection_reason, documents[]}`. Poll this until `can_operate` is true. |
| POST | `/vendor/documents` | multipart `document_type` + `file` (jpg/png/webp/pdf, 10 MB max) → 201 |
| GET | `/vendor/documents/{id}/file` | Streams **your own** document. Another merchant's document returns 403. |

### Session and profile (token)

| Method | Path | Notes |
|---|---|---|
| GET | `/vendor/session/validate` | Merchant and store. Returns 403 while the store is still disabled (pending). |
| GET | `/vendor/profile` | Merchant and `stores[]` (name, phone, address, status, logo/cover URLs, `category`, schedules) |
| PATCH / PUT | `/vendor/profile` | `f_name`, `l_name`, `phone`, `email`, `password` + `password_confirmation`, `store_name`, `store_phone`, `store_email`, `store_address`. An empty body returns 422. |
| POST | `/vendor/update-fcm-token` | `{fcm_token}` |
| POST | `/vendor/update-active-status` | **Approved.** `{is_open: true|false}` opens or closes your store and returns `{message, active}`. Any `store_id` in the body is ignored. |
| POST | `/vendor/logout` | Revokes the token |

### Orders (approved)

The merchant drives the order up to "ready for pickup":

```
pending_merchant ─accept→ accepted ─start-preparing→ preparing ─ready-for-pickup→ ready_for_pickup
          └─reject→ (rejected)
```

After that, **dispatch is automatic**. The order moves through `dispatching` → `driver_assigned` → `driver_accepted` → `picked_up` → `out_for_delivery` → `delivered`, all driven by the driver app. The merchant cannot choose or change the driver. If no driver accepts, the order ends in `assignment_failed`.

| Method | Path | Notes |
|---|---|---|
| GET | `/vendor/current-orders` | Array, not paged. New orders have `ssm_status: "pending_merchant"`; the rest are active orders. |
| GET | `/vendor/completed-orders?offset=1&limit=10` | `offset` is the **page number** (starts at 1). `limit` is 1–100, otherwise 422. Returns `{total_size, limit, offset, orders[]}` |
| GET | `/vendor/order?order_id=` | Order summary |
| GET | `/vendor/order-details?order_id=` | Order lines |
| POST | `/vendor/orders/{id}/accept` | |
| POST | `/vendor/orders/{id}/reject` | `{reason, note}`. `reason` is required. |
| POST | `/vendor/orders/{id}/start-preparing` | |
| POST | `/vendor/orders/{id}/ready-for-pickup` | Starts automatic dispatch |

Command response: `{"message":"Order status updated successfully.","order":{...,"ssm_status","ssm_status_version"}}`. The customer's e-mail is never included in `delivery_address`.

### Products / catalog (approved)

| Method | Path | Notes |
|---|---|---|
| GET | `/vendor/catalog/metadata` | `{categories[], units[]}`. Categories are the active ones for your store's module. **Call this first**, because product create needs a valid `category_id`. |
| GET | `/vendor/catalog/items` | `?search=&status=active|inactive&per_page=20` (1–100). Laravel pagination: `data`, `current_page`, `last_page`, `total`… |
| POST | `/vendor/catalog/items` | **multipart** → 201 `{message, item}`. The product is live immediately (`status=1`, approved). |
| GET | `/vendor/catalog/items/{id}` | Includes `category` and `unit` |
| POST | `/vendor/catalog/items/{id}` | **Update. This is POST, not PUT**, so multipart image upload works. Send only the fields you want to change. |
| PATCH | `/vendor/catalog/items/{id}/status` | `{status: true|false}` shows or hides the product |
| PATCH | `/vendor/catalog/items/{id}/stock` | `{stock: 0..999999999}` |
| DELETE | `/vendor/catalog/items/{id}` | **409** if the product was used in any order. Disable it with `/status` instead. |

**Product fields:**

| Field | Create | Rule |
|---|---|---|
| `name` | required | string, max 191 |
| `description` | required | string, max 2000 |
| `category_id` | required | from `metadata.categories` |
| `price` | required | 0.01 or more |
| `unit_id` | optional | from `metadata.units` |
| `stock` | optional | integer ≥ 0 |
| `discount`, `discount_type` | optional | `percent` or `amount` |
| `tax`, `tax_type` | optional | `percent` or `amount` |
| `maximum_cart_quantity` | optional | integer ≥ 1 |
| `organic` | optional | boolean |
| `image` | optional | jpg/png/webp, 5 MB max |

Another merchant's product ID returns 404.

### Notifications (token, also works while pending)

| Method | Path | Notes |
|---|---|---|
| GET | `/vendor/notifications?per_page=20&status=all|read|unread` | Paged (`data`, `links`, `meta`). Each item: `{id, type, title, body, entity, is_read, read_at, created_at, occurred_at}` |
| GET | `/vendor/notifications/unread-count` | |
| PATCH | `/vendor/notifications/{id}/read` | Another merchant's notification ID returns 404 |
| POST | `/vendor/notifications/read-all` | |

### Pharmacy requests (approved, read-only, pharmacy stores only)

| Method | Path | Notes |
|---|---|---|
| GET | `/vendor/pharmacy-requests?limit=15` | `{total_size, limit, offset, pharmacy_requests[]}` |
| GET | `/vendor/pharmacy-requests/{id}` | Includes `has_prescription` and `attachment_meta` |
| GET | `/vendor/pharmacy-requests/{id}/prescription` | Private image stream. Only for requests sent to **your** store. |

There is no accept or quote endpoint for pharmacy requests yet.

---

## Realtime and push

- Subscribe to Pusher private channels `private-merchant.{merchant_id}` and `private-order.{order_id}`. Events:
  - `ssm.order.status_changed`
  - `ssm.driver.assigned`
  - `ssm.dispatch.assignment_failed`
  - `ssm.notification.created`
- FCM messages only **wake the app**. Always re-read the data over REST after one arrives.

## Troubleshooting

| Symptom | Cause |
|---|---|
| Every request goes to `127.0.0.1` | The `SSM Local` environment is selected. Switch to *No Environment*. |
| Register returns 403 with code `store_category_id` | The id isn't an active category. Run `List merchant categories` first, or leave the field empty. |
| Register returns 403 about location | `latitude`/`longitude` are outside `zone_id`. For zone 7, use the collection's `zone_latitude`/`zone_longitude`. |
| Every order request returns 403 `merchant-not-approved` | The admin hasn't approved the merchant yet |
| `Current orders` is empty and `order_id` isn't saved | There are no customer orders for this store yet |
| `Create product` returns 422 on `category_id` | `Catalog metadata` wasn't run, or the store's module has no active categories |
| 401 after it was working | A login from another device replaced the token. Log in again. |
