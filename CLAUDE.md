# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Memphis Judo & Jiu-Jitsu mobile app built with Flutter and Firebase. The app provides class scheduling, instructor management, user profiles, and role-based access control for members, instructors, and administrators.

## Essential Commands

### Development
```bash
# Get dependencies
flutter pub get

# Run the app (iOS)
flutter run -d ios

# Run the app (Android)
flutter run -d android

# Analyze code
flutter analyze

# Run tests
flutter test

# Clean build artifacts
flutter clean

# Build for iOS
flutter build ios

# Build for Android
flutter build appbundle
flutter build apk
```

### iOS-Specific
```bash
# Update CocoaPods dependencies (from ios/ directory)
cd ios && pod install && cd ..

# Clean Pods and rebuild
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
```

## Architecture Overview

### State Management
- **No global state management library** (no Redux/BLoC/Riverpod/Provider)
- Screen-scoped `setState()` for local UI state
- `StreamBuilder` for Firestore real-time data
- `FutureBuilder` for one-time async operations
- Direct Firebase service calls from screens (tightly coupled by design)

### Navigation Flow
```
main.dart
  └─> App (MaterialApp)
      └─> SplashScreenPage (checks auth & version)
          ├─> LoginScreen (unauthenticated users)
          ├─> VerifyEmailScreen (unverified email)
          ├─> Onboarding flow (incomplete onboarding)
          │   ├─> UploadProfilePicScreen
          │   ├─> UploadContactInfoScreen
          │   └─> UploadGeneralDetailsScreen
          └─> HomeScreen (authenticated users)
              ├─> ScheduleScreen
              ├─> InstructorsScreen
              ├─> StylesScreen
              ├─> ProfileScreen
              ├─> ViewScheduleScreen (user's registered classes)
              ├─> AdminScreen (admin role only)
              └─> AboutScreen
```

### Firebase Architecture

**Authentication** (`lib/services/authentication.dart`):
- `UserAuth` class wraps Firebase Auth
- Supports Google Sign-In, email/password, and anonymous auth
- `UserData` model stores user profile data

**Firestore Collections**:
- `users/` - User profiles with roles (admin, instructor, member, subscriber, guardian)
- `schedules/bartlett/dates/` - Location-based class schedules
- `class-participants/` - User class registrations with check-in status
- `instructors/` - Instructor reference data
- `styles/` - Martial arts style reference data
- `versioning/` - App version control for forced updates

**Firebase Storage**:
- Profile pictures stored at `users/{uid}.jpg`
- Images compressed using `flutter_native_image` (80% quality, 50% size)

### Key Services

**`lib/services/authentication.dart`**:
- `UserAuth.signInWithGoogle()` - Google OAuth
- `UserAuth.signInWithEmail()` - Email/password login
- `UserAuth.createUserFromEmail()` - New user registration
- `UserAuth.getLoggedInUser()` - Current user state

**`lib/services/messaging.dart`**:
- `Messaging` static class for Firebase Cloud Messaging
- StreamController for push notification events
- Background message handler
- Topic subscription management

**`lib/services/validations.dart`**:
- Regex-based form validation
- Email, password, phone number, zip code validators

### Utilities (`lib/utils/`)

**`user-item.dart`**:
- `UserItem` wrapper combining Firebase Auth User + custom Roles
- Convenience getters: `isAdmin`, `isInstructor`, `isSubscriber`, `isGuardian`, `isAnonymous`

**`list-item.dart`**:
- `HeadingItem` - Schedule date headers
- `ScheduleItem` - Class schedule details with time formatting
- Both use `.fromMap()` factory constructors for Firestore data

**`user-information.dart`**:
- Simple data class for user contact information

### Custom Components (`lib/components/`)

**Buttons**:
- `GoogleSignInButton` - Branded OAuth button
- `RoundedButton` - Generic action button
- `BrandedTextButton` - Styled text button
- `AnimatedFloatingActionButton` - Custom animated FAB

**Input Fields**:
- `BrandedInputField` - Configurable text input with validation, formatting, icons, character counters

### Theming (`lib/theme/style.dart`)

**Colors**:
- Primary: `#00c497` (teal/green)
- AppBar: `#1a1a1c` (dark gray)
- Login gradient: `#1a256f` → `#373737`

**Fonts**:
- Custom: WorkSans (SemiBold, Bold, Medium), OpenSans
- Google Fonts: Anton for headings

## Code Conventions

### Linting (analysis_options.yaml)
- `prefer_single_quotes: true` - Use single quotes for strings
- `require_trailing_commas: true` - Add trailing commas to parameter lists
- `prefer_const_constructors: true` - Use const constructors where possible
- `avoid_print: false` - Print statements are allowed
- Ignored: `library_private_types_in_public_api`, `file_names`

### File Naming
- Kebab-case for file names (e.g., `splash-screen.dart`, `user-item.dart`)
- Class names are PascalCase (e.g., `SplashScreenPage`, `UserItem`)

### Common Patterns

**Firestore Queries**:
```dart
FirebaseFirestore.instance
  .collection('schedules/bartlett/dates')
  .where('date', isGreaterThanOrEqualTo: DateTime.now())
  .orderBy('date')
  .limit(600)
  .snapshots()
```

**StreamBuilder Usage**:
```dart
StreamBuilder<QuerySnapshot>(
  stream: firestoreStream,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    // Build UI from snapshot.data
  },
)
```

**Navigation**:
```dart
// Push new screen
Navigator.push(context, MaterialPageRoute(builder: (_) => NewScreen()));

// Replace current screen
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NewScreen()));
```

**Error Handling**:
- Firebase errors are caught and logged with `FirebaseAnalytics`
- User-facing errors shown via `ScaffoldMessenger.of(context).showSnackBar()`

## Role-Based Access

User roles are stored in `users/{uid}/roles` Firestore map:
- `admin` - Access to AdminScreen for user management
- `instructor` - Listed in instructor directory
- `member` - Basic member access
- `subscriber` - Active subscription status
- `guardian` - Parent/guardian account

Roles are checked at splash screen and throughout the app to control screen access and UI elements.

## Important Notes

- **No named routes** - Navigation uses direct `MaterialPageRoute` with constructors
- **Minimal abstraction** - Services are called directly from screens, no repository pattern
- **Real-time by default** - Most data fetching uses Firestore snapshots, not one-time reads
- **Version enforcement** - App checks `versioning/` collection on startup and blocks outdated versions
- **Location hardcoded** - Schedules are tied to "bartlett" location in Firestore paths
- **Image compression** - All uploaded images are compressed to 80% quality and 50% original size

## Firebase Configuration

Firebase is auto-initialized in `main.dart` using `firebase_options.dart` (generated by FlutterFire CLI). Platform-specific configuration is handled automatically for iOS and Android.

## Testing

Minimal test coverage currently exists. Tests are in `test/` directory. No integration or end-to-end test setup.
