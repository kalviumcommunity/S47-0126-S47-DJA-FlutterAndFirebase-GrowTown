# GrowTown – Flutter + Firebase Project Documentation

## 📱 Project Overview

**GrowTown** is a Flutter-based mobile loyalty management application designed to help local businesses manage customers and reward loyalty through a simple, mobile-first experience.

The app focuses on:

- Phone number–based authentication
- Customer management
- Loyalty points tracking
- Real-time data synchronization using Firebase

This repository includes the application code, system architecture documentation, and API documentation to ensure the project is easy to understand, maintain, and extend for future contributors.

---

## 📄 Documentation Links

> ⛳ **Note:** Links will be updated once final assets are uploaded.

- **API Documentation (Postman Collection):**
  🔗 *https://joint-operations-technologist-45324879-9451211.postman.co/workspace/note-app~ef982212-7a97-421a-8d6b-d2b179c63f9b/collection/47185198-e4477309-c25f-4d5f-9f7a-6f5a1decb4bc?action=share&creator=47185198*

- **Architecture Documentation:**
  📘 `docs/ARCHITECTURE.md`

- **High-Level Design (HLD):**
  🔗 *https://drive.google.com/file/d/16Tfvyd8QBYpPFGyaBHLluWmPcrj6tQP7/view*

---

## 🧩 Project Metadata

- **Project Name:** GrowTown
- **Version:** `1.0.0`
- **Tech Stack:** Flutter, Dart, Firebase
- **Authentication:** Firebase Phone Authentication
- **Backend Services:** Firebase Auth, Cloud Firestore, Cloud Storage
- **Last Updated:** `2026-01-23`

---

## 📸 Screenshots & Diagrams

- ✅ Screenshot of **Postman API Collection**
- ✅ Screenshot of **System Architecture / HLD Diagram**

```
/docs/screenshots/
 ┣ api-documentation.png
 ┗ architecture-diagram.png
```

---

## 🧪 API Documentation Summary

GrowTown uses Firebase SDKs directly from the Flutter application.
The API documentation provided via **Postman** represents **logical API operations** such as:

- Customer creation
- Fetching customer lists
- Updating loyalty points
- Dashboard summary retrieval

These documented endpoints help simulate and explain backend interactions even though Firebase is SDK-driven rather than REST-first.

---

## 🏗 Architecture Overview

The application follows a clean separation of concerns:

- **UI Layer:** Flutter screens and widgets
- **State Management:** Provider / Riverpod
- **Service Layer:** Firebase Auth, Firestore, Storage services
- **Data Models:** Structured Dart models for Firestore collections

For full details, refer to:
📘 **`ARCHITECTURE.md`**

---

## 🤝 Reflection

### How API Documentation Improves Collaboration & Onboarding

Clear API documentation allows new developers to:

- Quickly understand how data flows through the app
- Identify authentication and authorization requirements
- Test backend interactions independently using Postman
- Reduce dependency on verbal explanations or code walkthroughs

This significantly speeds up onboarding and minimizes confusion when multiple contributors work on the same codebase.

### How Versioning & Metadata Ensure Long-Term Consistency

Including metadata such as version numbers, authentication methods, base URLs, and last-updated dates helps:

- Track API changes over time
- Avoid breaking changes without awareness
- Maintain backward compatibility
- Ensure documentation stays aligned with the actual implementation

Versioned documentation makes GrowTown scalable and maintainable as features evolve.

---

# Flutter Environment Setup and Verification

## Overview

This document verifies the successful setup of the Flutter development environment. The goal of this task was to install Flutter, configure the required tools, run an Android emulator, and successfully launch a Flutter application.

This setup ensures the system is ready for Flutter mobile app development in upcoming sprints.

---

## Steps Followed

### 1. Flutter SDK Installation

- Downloaded the Flutter SDK from the official Flutter website.
- Extracted the SDK and added `flutter/bin` to the system PATH.
- Verified installation using the `flutter doctor` command.

### 2. IDE Setup

- Installed Android Studio.
- Configured Android SDK, Platform Tools, and AVD Manager.
- Installed Flutter and Dart plugins.

### 3. Emulator Configuration

- Created an Android Virtual Device (Pixel series).
- Started the emulator using AVD Manager.
- Verified device connection using `flutter devices`.

### 4. First Flutter App

- Created a new Flutter project using `flutter create`.
- Ran the default Flutter counter app using `flutter run`.
- Verified successful app launch on the emulator.

---

## Setup Verification Screenshots

### Flutter Doctor Output

![Flutter Doctor Output](screenshots/flutter-doctor.png)

### Flutter App Running on Emulator

![Flutter App Running](screenshots/flutter-app.png)

---

## Reflection

### Challenges Faced

During the setup, minor configuration steps such as installing Android SDK components and emulator images required attention. However, Flutter’s documentation and diagnostic tools like `flutter doctor` made troubleshooting straightforward.

### Learning Outcome

This environment setup provides a solid foundation for Flutter development. With the SDK, emulator, and IDE properly configured, I can now focus on building, testing, and deploying Flutter applications efficiently in future sprints.

# Widget Tree & Reactive UI Demo (Flutter)

## Overview

This project demonstrates Flutter’s **Widget Tree architecture** and **Reactive UI model** using the default counter application generated by `flutter create`.

The goal of this task is to understand how Flutter builds user interfaces using nested widgets and how the UI automatically updates when the application state changes.

---

## Tech Stack

- Flutter
- Dart
- Material Design

---

## Understanding the Widget Tree

In Flutter, **everything is a widget**. Widgets are arranged in a hierarchical structure known as the **Widget Tree**. This tree defines how the UI is structured and rendered on the screen.

Below is the widget hierarchy of the default Flutter counter app:

MaterialApp
┗ Scaffold
┣ AppBar
┣ Body
│ ┗ Center
│ ┗ Column
│ ┣ Text (static label)
│ ┗ Text (counter value)
┗ FloatingActionButton

Each widget has a single responsibility, and together they form the complete UI.

---

## Flutter’s Reactive UI Model

Flutter follows a **reactive programming model**, meaning the UI automatically updates whenever the state changes.

In this application:

- `_counter` is a state variable
- `setState()` is used to update the counter
- Flutter rebuilds only the widgets that depend on `_counter`

### Code Snippet Demonstrating State Update

```dart
void _incrementCounter() {
  setState(() {
    _counter++;
  });
}
```

When `setState()` is called, Flutter efficiently rebuilds the necessary widgets without redrawing the entire screen.

---

## State Change Demonstration

### Initial State

- Counter value is `0`
- UI shows the initial count

### After Interaction

- User presses the `+` Floating Action Button
- Counter value increments
- UI updates instantly

This behavior highlights Flutter’s reactive UI nature.

---

## Screenshots

![Flutter App Initial State](screenshots/InitialState.png)
![Flutter App State After Button Is Clicked](screenshots/StateAfterButtonIsClicked.png)

- Initial state of the app (counter = 0)
- Updated state after pressing the button

---

## Reflection

### How does the widget tree help Flutter manage complex UIs?

The widget tree breaks the UI into smaller, reusable components, making complex layouts easier to build, maintain, and scale.

### Why is Flutter’s reactive model more efficient?

Flutter updates only the widgets affected by state changes instead of refreshing the entire screen, resulting in better performance and smoother user interactions.

---

## Conclusion

This demo successfully explains Flutter’s widget tree structure and reactive UI behavior using a simple, real-world example provided by the default counter app.

# 📘 Using Hot Reload, Debug Console, and Flutter DevTools Effectively

## Project Description

This project demonstrates the effective use of Flutter’s core development tools — **Hot Reload**, **Debug Console**, and **Flutter DevTools** — using the default Flutter counter application. The goal of this exercise is to understand how Flutter enables fast UI iteration, real-time debugging, and performance inspection during development.

---

## 🔥 Hot Reload Demonstration

Hot Reload was used to instantly reflect UI changes without restarting the application or losing state. While the app was running, minor UI changes such as updating text labels and modifying widget properties were made inside `main.dart`. Upon saving the file, the changes appeared immediately on the emulator, demonstrating how Hot Reload accelerates UI experimentation and feedback loops.

---

## 🐞 Debug Console Usage

The Debug Console was used to track application behavior during runtime. Inside the counter increment function, `debugPrint()` statements were added to log the updated counter value each time the button was pressed. These logs appeared instantly in the debug console, helping verify application logic and track state changes in real time.

---

## 🛠️ Flutter DevTools Exploration

Flutter DevTools was launched while the application was running in debug mode. The **Widget Inspector** was used to visually explore the widget tree, confirming how widgets are nested and rendered. The **Performance** tab was also viewed to understand frame rendering behavior. This demonstrates how DevTools helps diagnose UI structure and performance characteristics efficiently.

---

## 📸 Screenshots

 ![](screenshots/hot_reload_ui_update-initial.png)
 ![](screenshots/hot_reload_ui_update-final.png)
 ![](screenshots/debug_console_logs.png)
 ![](screenshots/flutter_devtools_widget_inspector.png)

* Hot Reload UI update
* Debug Console logs
* Flutter DevTools (Widget Inspector)

---

## 🧠 Reflection

Hot Reload significantly improves development productivity by eliminating the need for full app restarts when making UI changes. The Debug Console provides immediate insight into application behavior, making it easier to identify issues early. Flutter DevTools offers a powerful visual and analytical interface for understanding widget composition and performance. Together, these tools enable faster debugging, better collaboration in teams, and more maintainable Flutter applications.
