# GrowTown – Flutter + Firebase Project Documentation

## 📱 Project Overview

**GrowTown** is a Flutter-based mobile loyalty management application designed to help local businesses manage customers and reward loyalty through a simple, mobile-first experience.

The app focuses on:

* Phone number–based authentication
* Customer management
* Loyalty points tracking
* Real-time data synchronization using Firebase

This repository includes the application code, system architecture documentation, and API documentation to ensure the project is easy to understand, maintain, and extend for future contributors.

---

## 📄 Documentation Links

> ⛳ **Note:** Links will be updated once final assets are uploaded.

* **API Documentation (Postman Collection):**
  🔗 *https://joint-operations-technologist-45324879-9451211.postman.co/workspace/note-app~ef982212-7a97-421a-8d6b-d2b179c63f9b/collection/47185198-e4477309-c25f-4d5f-9f7a-6f5a1decb4bc?action=share&creator=47185198*

* **Architecture Documentation:**
  📘 `docs/ARCHITECTURE.md`

* **High-Level Design (HLD):**
  🔗 *https://drive.google.com/file/d/16Tfvyd8QBYpPFGyaBHLluWmPcrj6tQP7/view*

---

## 🧩 Project Metadata

* **Project Name:** GrowTown
* **Version:** `1.0.0`
* **Tech Stack:** Flutter, Dart, Firebase
* **Authentication:** Firebase Phone Authentication
* **Backend Services:** Firebase Auth, Cloud Firestore, Cloud Storage
* **Last Updated:** `2026-01-23`

---

## 📸 Screenshots & Diagrams

* ✅ Screenshot of **Postman API Collection**
* ✅ Screenshot of **System Architecture / HLD Diagram**

```
/docs/screenshots/
 ┣ api-documentation.png
 ┗ architecture-diagram.png
```

---

## 🧪 API Documentation Summary

GrowTown uses Firebase SDKs directly from the Flutter application.
The API documentation provided via **Postman** represents **logical API operations** such as:

* Customer creation
* Fetching customer lists
* Updating loyalty points
* Dashboard summary retrieval

These documented endpoints help simulate and explain backend interactions even though Firebase is SDK-driven rather than REST-first.

---

## 🏗 Architecture Overview

The application follows a clean separation of concerns:

* **UI Layer:** Flutter screens and widgets
* **State Management:** Provider / Riverpod
* **Service Layer:** Firebase Auth, Firestore, Storage services
* **Data Models:** Structured Dart models for Firestore collections

For full details, refer to:
📘 **`ARCHITECTURE.md`**

---

## 🤝 Reflection

### How API Documentation Improves Collaboration & Onboarding

Clear API documentation allows new developers to:

* Quickly understand how data flows through the app
* Identify authentication and authorization requirements
* Test backend interactions independently using Postman
* Reduce dependency on verbal explanations or code walkthroughs

This significantly speeds up onboarding and minimizes confusion when multiple contributors work on the same codebase.

### How Versioning & Metadata Ensure Long-Term Consistency

Including metadata such as version numbers, authentication methods, base URLs, and last-updated dates helps:

* Track API changes over time
* Avoid breaking changes without awareness
* Maintain backward compatibility
* Ensure documentation stays aligned with the actual implementation

Versioned documentation makes GrowTown scalable and maintainable as features evolve.

---


