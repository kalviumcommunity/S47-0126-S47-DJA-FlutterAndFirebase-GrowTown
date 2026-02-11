# GrowTown - Customer Management System

A modern, responsive Flutter application with Firebase Authentication featuring persistent user sessions and auto-login capabilities.

## 🚀 Features

### Core Functionality
- ✅ **Customer Management**: Add, view, and manage customer information
- ✅ **User Authentication**: Secure login and registration with Firebase Auth
- ✅ **Persistent Sessions**: Auto-login after app restart (no repeated logins!)
- ✅ **Responsive Design**: Optimized for mobile, tablet, and desktop
- ✅ **Real-time Updates**: Live authentication state synchronization

### User Experience
- 🔐 **Auto-Login**: Users stay logged in across app restarts
- 🎨 **Modern UI**: Clean, professional interface with smooth animations
- 📱 **Cross-Platform**: Works on Android, iOS, and Web
- ⚡ **Fast Navigation**: Seamless routing based on authentication state

## 📚 Documentation

### Implementation Guides
- **[Persistent Sessions Implementation](docs/PERSISTENT_SESSIONS.md)** - Complete guide to Firebase Auth persistent sessions, auto-login flow, and session management
- **[Responsive Design Implementation](docs/RESPONSIVE_IMPLEMENTATION.md)** - MediaQuery and LayoutBuilder usage across all screens
- **[Architecture Documentation](docs/ARCHITECTURE.md)** - Project structure and design patterns

## 🛠️ Technology Stack

- **Framework**: Flutter (Dart)
- **Authentication**: Firebase Authentication
- **Database**: Firebase Data Connect
- **State Management**: StreamBuilder with Firebase auth streams
- **UI Components**: Material Design 3

## 📱 Screens

1. **Splash Screen** - App branding and initial loading
2. **Login Screen** - Email/password authentication
3. **Create Account Screen** - New user registration
4. **Dashboard Screen** - Customer statistics and list view
5. **Profile Screen** - User account management
6. **Add Customer Screen** - Customer creation form

## 🔥 Firebase Integration

### Persistent Sessions
The app implements automatic session persistence using Firebase Authentication:

```dart
// AuthWrapper automatically handles login state
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.hasData) return DashboardScreen(); // Auto-login
    return LoginScreen();
  },
)
```

**Benefits:**
- No manual token storage required
- Automatic token refresh
- Real-time auth state updates
- Cross-platform session consistency

See [PERSISTENT_SESSIONS.md](docs/PERSISTENT_SESSIONS.md) for detailed implementation.

## 🎯 Getting Started

## 🗄️ Firestore Data Requirements

This section lists the entities the app stores in Cloud Firestore and their primary purposes. These requirements guide the database schema design and are written to minimize reads/writes and to scale to many users.

Data requirements:

- **Users**: Authenticated app users and public profile info (displayName, email, photoURL, role). Used for authentication, authorization, and user-specific data.
- **Profiles**: Extended user metadata (preferences, bio, settings) stored either in a `profiles` collection or as fields on `users/{uid}` depending on read patterns.
- **Customers**: Business customers managed by the app (name, contact, address, tags, createdBy). Core entity shown in `Dashboard` and `Add Customer` screens.
- **Products**: Catalog of products/services (`title`, `price`, `sku`, `stock`, `images`) referenced from interactions or orders.
- **Interactions / Orders**: Records of interactions, sales, or orders related to a customer. Can be a subcollection `customers/{customerId}/interactions` for independent growth and efficient querying.
- **Notifications**: Per-user notifications stored under `users/{uid}/notifications` to allow efficient reads and deletes per user.
- **AppConfig**: Global configuration (feature flags, pricing tiers) stored in a small `config` collection or single doc for live updates.
- **AuditLogs**: Append-only `logs` collection for admin auditing and background job outputs.

Field and behavior expectations:

- Use `createdAt` and `updatedAt` timestamps on major documents.
- Use lowerCamelCase for field names.
- Prefer subcollections for large, growing datasets (e.g., `interactions`, `notifications`).
- Reference related documents with `DocumentReference` where needed (`userRef`, `customerRef`, `productRef`) to avoid duplication.
- Index frequently queried fields (e.g., `createdBy`, `status`, `customerId`) via Firestore composite indexes when queries require it.

These requirements will be translated into a full Firestore schema in the next step.

See the full schema and visual diagram in [docs/FIRESTORE_SCHEMA.md](docs/FIRESTORE_SCHEMA.md).

### Prerequisites
- Flutter SDK (3.0 or higher)
- Firebase account with project setup
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/S47-0126-S47-DJA-FlutterAndFirebase-GrowTown.git
cd S47-0126-S47-DJA-FlutterAndFirebase-GrowTown/client
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
- Add `google-services.json` (Android) to `android/app/`
- Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`
- Ensure `firebase_options.dart` is configured

4. **Run the app**
```bash
flutter run
```

## 📦 Project Structure

```
client/
├── lib/
│   ├── screens/
│   │   ├── splash_screen.dart        # Initial loading screen
│   │   ├── auth_wrapper.dart         # Authentication state manager
│   │   ├── login_screen.dart         # User login
│   │   ├── create_account_screen.dart # Registration
│   │   ├── dashboard_screen.dart     # Main app screen
│   │   ├── profile_screen.dart       # User profile
│   │   └── add_customer_screen.dart  # Customer creation
│   ├── widgets/
│   │   └── customer_list.dart        # Customer list component
│   ├── models/                       # Data models
│   ├── firebase_options.dart         # Firebase configuration
│   └── main.dart                     # App entry point
├── docs/
│   ├── PERSISTENT_SESSIONS.md        # Session implementation guide
│   ├── RESPONSIVE_IMPLEMENTATION.md  # Responsive design guide
│   └── screenshots/                  # App screenshots
└── pubspec.yaml                      # Dependencies
```

## 🧪 Testing

### Auto-Login Test
1. Login to the app with valid credentials
2. Navigate to the Dashboard
3. Close the app completely (force stop)
4. Reopen the app
5. ✅ **Expected**: App opens directly to Dashboard (auto-login success!)

### Logout Test
1. Login to the app
2. Click Logout from Profile or Dashboard
3. Confirm logout
4. ✅ **Expected**: Redirected to Login Screen
5. Close and reopen app
6. ✅ **Expected**: Login Screen appears (session cleared)

See [PERSISTENT_SESSIONS.md](docs/PERSISTENT_SESSIONS.md) for complete test cases.

## 📸 Screenshots

| Login Screen | Dashboard | Profile |
|--------------|-----------|---------|
| ![Login](docs/screenshots/login_screen.png) | ![Dashboard](docs/screenshots/dashboard_before_restart.png) | ![Profile](docs/screenshots/profile_screen.png) |

| Auto-Login (After Restart) | Logout Confirmation |
|----------------------------|---------------------|
| ![Auto-Login](docs/screenshots/dashboard_after_restart.png) | ![Logout](docs/screenshots/logout_confirmation.png) |

> **Note**: Refer to [docs/screenshots/README.md](docs/screenshots/README.md) for screenshot capture guidelines.

## 🔑 Key Features Explained

### 1. Persistent Sessions
Firebase Authentication automatically manages user sessions:
- Secure token storage on device
- Automatic token refresh
- No manual SharedPreferences needed
- Cross-platform consistency

### 2. Responsive Design
All screens adapt to different screen sizes:
- **Mobile**: < 800px (drawer navigation, stacked layout)
- **Tablet**: 600-800px (constrained width, optimized layout)
- **Desktop**: ≥ 800px (sidebar, multi-column layout)

### 3. Real-time Auth State
`authStateChanges()` stream provides instant updates:
- Login detected → Navigate to Dashboard
- Logout detected → Navigate to Login
- No manual state management needed

## 🤝 Contributing

### Development Workflow
1. Create a feature branch
2. Make changes with clear commit messages
3. Test on multiple devices/sizes
4. Update documentation if needed
5. Submit pull request

### Code Standards
- Follow Flutter style guide
- Use meaningful variable names
- Add comments for complex logic
- Ensure responsive design for new screens
- Test authentication flows

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Akshit** - Feature implementation
- **Darshan** - UI/UX Design
- **Janhavi** - Backend Integration

## 🙏 Acknowledgments

- Firebase for authentication infrastructure
- Flutter team for excellent framework
- Material Design for UI components

## 📞 Support

For issues, questions, or contributions:
- Create an issue in the repository
- Check existing documentation in `/docs`
- Review test cases in PERSISTENT_SESSIONS.md

---

**Project Status**: ✅ Active Development  
**Last Updated**: February 2026  
**Flutter Version**: 3.x  
**Firebase SDK**: Latest stable
