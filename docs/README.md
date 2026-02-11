````markdown
# Project Documentation - GrowTown

This folder contains implementation guides and reference docs for the GrowTown application.

## Recent changes (February 2026)

- Added `FIRESTORE_SCHEMA.md`: full Firestore data model with a Mermaid diagram, top-level collections, subcollection rationale, indexing recommendations, naming conventions, and sample documents.
- Documented recommended schema decisions: prefer `customers/{customerId}/interactions` subcollection for large per-customer datasets, use `users/{uid}/notifications` for per-user notifications, and store timestamps as `createdAt` / `updatedAt`.
- Added indexing guidance and sample document payloads to help with rules and query planning.
- Included a short "Next Steps" section recommending sample queries, security rules draft, and adding the Mermaid diagram to the root README for visualization.

## Docs index

- FIRESTORE_SCHEMA.md — Firestore data model and examples
- PERSISTENT_SESSIONS.md — Session persistence and auto-login behavior
- RESPONSIVE_IMPLEMENTATION.md — Responsive layout guidance
- ARCHITECTURE.md — Project architecture and directory layout

If you want a more detailed changelog or want these items broken into separate changelog entries, tell me how you'd like them formatted.
````
