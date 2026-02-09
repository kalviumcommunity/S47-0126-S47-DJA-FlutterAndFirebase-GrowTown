# Firestore Validation, Indexes, and Security Notes

This document validates the schema in `docs/FIRESTORE_SCHEMA.md`, lists recommended Firestore indexes, suggests query patterns, and provides security rules snippets and scaling guidance.

## Validation Summary

- Collections are logically separated: `users`, `customers`, `products`, `logs`, `config`.
- Growing datasets (notifications, interactions) are modeled as subcollections to avoid large arrays and to enable paginated reads.
- References use `DocumentReference` to avoid duplication of large objects while keeping read performance manageable.
- `createdAt`/`updatedAt` timestamps applied to primary documents for ordering and TTL/cleanup policies.

## Index Recommendations

1. `customers`
   - Single-field: `createdAt` (for recent customers)
   - Composite: `status` + `createdAt` (for "active" customers sorted by newest)
   - Composite: `createdBy` + `createdAt` (staff-specific recently-created customers)

2. `customers/{customerId}/interactions`
   - Order by `createdAt` descending for pagination (no composite index required for simple order)

3. `products`
   - Single-field: `sku` (if used for lookup)

4. Global `interactions` (if used)
   - Composite: `customerId` + `createdAt`
   - Composite: `createdBy` + `createdAt`

Firestore composite index creation example (from console or index config):
- For `customers` `status`+`createdAt`:
  - Collection: `customers`
  - Fields: `status` ASC, `createdAt` DESC

## Common Queries & Costs

- Read customer list (paged):
  - Query: `customers.orderBy('createdAt', 'desc').limit(20)` — reads proportional to page size.
- Get customer with recent interactions:
  - Read `customers/{id}` (1 read) then `customers/{id}/interactions` with `limit` (N reads).
- Search by phone or email:
  - Add single-field indexes on `phone` and `email` if frequent; use a small `searchKeywords` array for prefix search (avoid large arrays).

Cost minimization tips:
- Avoid fetching entire subcollections when only counts are needed — maintain a `counters` map or distributed counter field on the parent document updated by Cloud Functions.
- Paginate all lists and use `limit()`.
- Use `select()` (projections) to read only required fields when documents are large.

## Scaling Considerations

- 100k users: storing user profiles in `users/{uid}` is fine. Ensure rules restrict writes to user-owned docs.
- High write throughput (e.g., many interactions per second): partition writes across documents (subcollections per customer) and avoid hotspotting a single document for counters.
- Large analytics: export to BigQuery using scheduled exports or Cloud Functions for heavy aggregation workloads.
- Large arrays: avoid arrays that grow unbounded; use subcollections instead.

## Denormalization and When to Use It

- Denormalize small, frequently-read pieces of related data (e.g., customer `name` inside an interaction) to avoid extra reads when showing lists.
- Keep authoritative data (e.g., product price) in `products` and denormalize price snapshot into `interactions` at write-time if historic price is needed.

## Security Rules (examples)

Rules below are illustrative; adapt to your auth model and test thoroughly.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // users: user may read their own profile; admins can read all
    match /users/{userId} {
      allow read: if request.auth != null && (request.auth.uid == userId || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if false; // prefer soft-delete

      // notifications subcollection: owner-only
      match /notifications/{notifId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // customers: authenticated staff can create/read; only admins can delete
    match /customers/{customerId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';

      // interactions subcollection: any authenticated user can write interactions, but rule can restrict by createdBy
      match /interactions/{interactionId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null && request.resource.data.createdBy == request.auth.uid;
        allow update, delete: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      }
    }

    // logs: write-only by server/admin
    match /logs/{logId} {
      allow read: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      allow create: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      allow delete: if false;
    }

    // config: read by all authenticated; writes only by admin
    match /config/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

Notes:
- Avoid calling `get()` extensively in rules inside loops; keep rules efficient.
- Consider using custom claims for roles to avoid frequent reads of `users/{uid}` in rules (set via Admin SDK).

## Operational Recommendations

- Use Firestore `serverTimestamp()` in Cloud Functions or client writes for `createdAt`/`updatedAt`.
- Use Cloud Functions to:
  - Enforce additional integrity (e.g., maintain counters, denormalize small fields)
  - Populate `logs` and `notifications`
- Add monitoring on read/write operations and billing alerts.

## Next Steps

- Integrate schema into app code (data models and serializers).
- Implement Firestore rules in `firebase.rules` and test with the Firestore Rules Unit Testing library.
- Create PR: `feat: added Firestore schema design and database architecture diagram` with files in `docs/` and this validation.
