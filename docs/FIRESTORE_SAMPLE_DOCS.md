# Firestore Sample Documents for GrowTown

This file contains concrete example documents for the collections defined in `docs/FIRESTORE_SCHEMA.md`.

---

## `users/{uid}`

Fields (types):
- `displayName`: string
- `email`: string
- `photoURL`: string | null
- `role`: string ("admin" | "staff")
- `createdAt`: timestamp
- `updatedAt`: timestamp

Example:
```json
{
  "displayName": "Alice Patel",
  "email": "alice@example.com",
  "photoURL": null,
  "role": "admin",
  "createdAt": "2026-02-09T10:00:00Z",
  "updatedAt": "2026-02-09T10:00:00Z"
}
```

---

## `customers/{customerId}`

Fields (types):
- `name`: string
- `email`: string | null
- `phone`: string
- `address`: map { street, city, state, postalCode, country } | null
- `tags`: array<string>
- `points`: number
- `status`: string ("active" | "inactive")
- `createdBy`: DocumentReference (`users/{uid}`)
- `createdAt`: timestamp
- `updatedAt`: timestamp

Example:
```json
{
  "name": "Ravi Sharma",
  "email": "ravi@example.com",
  "phone": "+919876543210",
  "address": {
    "street": "12 MG Road",
    "city": "Mumbai",
    "state": "MH",
    "postalCode": "400001",
    "country": "IN"
  },
  "tags": ["wholesale","priority"],
  "points": 120,
  "status": "active",
  "createdBy": "users/aliceUid",
  "createdAt": "2026-02-08T09:00:00Z",
  "updatedAt": "2026-02-08T09:00:00Z"
}
```

---

## `customers/{customerId}/interactions/{interactionId}`

Fields (types):
- `type`: string ("visit" | "purchase" | "call" | "note")
- `notes`: string | null
- `amount`: number | null
- `products`: array<map { productRef: DocumentReference, qty: number, price: number }> | []
- `createdBy`: DocumentReference (`users/{uid}`)
- `createdAt`: timestamp

Example:
```json
{
  "type": "purchase",
  "notes": "Bought 2 widget packs",
  "amount": 590,
  "products": [
    { "productRef": "products/prod1", "qty": 2, "price": 295 }
  ],
  "createdBy": "users/aliceUid",
  "createdAt": "2026-02-08T09:05:00Z"
}
```

Alternate option (global interactions collection):
```json
{
  "customerId": "customers/abc123",
  "type": "purchase",
  "amount": 590,
  "createdBy": "users/aliceUid",
  "createdAt": "2026-02-08T09:05:00Z"
}
```

---

## `users/{uid}/notifications/{notifId}`

Fields (types):
- `title`: string
- `body`: string
- `read`: boolean
- `data`: map | null
- `createdAt`: timestamp

Example:
```json
{
  "title": "New order received",
  "body": "Order #123 created for Ravi Sharma",
  "read": false,
  "data": { "orderId": "orders/123" },
  "createdAt": "2026-02-09T11:00:00Z"
}
```

---

## `products/{productId}`

Fields (types):
- `title`: string
- `description`: string
- `price`: number
- `sku`: string
- `stock`: number
- `images`: array<string>
- `createdAt`, `updatedAt`: timestamp

Example:
```json
{
  "title": "Widget Pack A",
  "description": "Set of 10 widgets",
  "price": 295,
  "sku": "WIDGET-A-10",
  "stock": 120,
  "images": ["/images/widgets/a1.png"],
  "createdAt": "2026-01-20T08:00:00Z",
  "updatedAt": "2026-02-01T09:00:00Z"
}
```

---

## `config/app` (single document)

Example:
```json
{
  "featureFlags": { "loyalty": true, "bulkImport": false },
  "supportEmail": "support@growtown.example.com",
  "createdAt": "2026-01-01T00:00:00Z"
}
```

---

## `logs/{logId}`

Fields (types):
- `type`: string
- `message`: string
- `meta`: map | null
- `createdAt`: timestamp

Example:
```json
{
  "type": "import",
  "message": "Imported 123 customers",
  "meta": { "file": "customers.csv", "rows": 123 },
  "createdAt": "2026-02-09T12:00:00Z"
}
```

---

## Query & Index Suggestions

- Query recent customers: `customers` ordered by `createdAt` (index on `createdAt`).
- Query active customers: where `status == "active"` and ordered by `createdAt` (composite index: `status, createdAt`).
- Query interactions for a customer: read `customers/{customerId}/interactions` with `limit` and `orderBy(createdAt, desc)` (no composite index needed).
- Global interactions queries (if using global `interactions`): index on `customerId`, `createdAt`, and any combination used in filtering.

## Security & Rules (notes)

- Enforce that `users/{uid}` `uid` equals `request.auth.uid` for writes to a user's own profile.
- Allow `customers` read/write only to authenticated users with `role` in their `users` doc; restrict deletions to admins.
- `users/{uid}/notifications` should allow writes by server (Cloud Functions) and reads by the owning user only.

---

End of sample documents.
