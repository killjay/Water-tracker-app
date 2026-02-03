# Water Tracker

A Flutter mobile application for tracking daily water intake with Firebase backend integration.

## Features

- **Water Tracking**: Log water intake with custom cup sizes
- **Daily Goals**: Set and track daily water intake goals
- **Smart Reminders**: Intelligent notification system that adjusts based on your progress
- **History**: View past water intake entries with date navigation
- **Cloud Sync**: Automatic data synchronization across devices using Firebase
- **Offline Support**: Works offline with automatic sync when connection is restored
- **Analytics**: Track usage patterns with Firebase Analytics

## Setup Instructions

### Prerequisites

- Flutter SDK (3.10.1 or higher)
- Firebase account
- iOS development setup (for iOS builds)
- Android development setup (for Android builds)

### Firebase Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)

2. Add iOS app to Firebase:
   - Click "Add app" and select iOS
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/` directory

3. Add Android app to Firebase:
   - Click "Add app" and select Android
   - Download `google-services.json`
   - Place it in `android/app/` directory

4. Enable Firebase services:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Firebase Analytics
   - Cloud Messaging (optional, for push notifications)
   - Firebase Storage (optional)

5. Deploy Firestore security rules:
   - Copy the rules from `firestore.rules`
   - Deploy to Firebase Console > Firestore Database > Rules

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd "Water Tracker"
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Add `google-services.json` to `android/app/`

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── water_entry_model.dart
│   ├── goal_model.dart
│   └── daily_stats_model.dart
├── services/                 # Business logic services
│   ├── auth_service.dart
│   ├── water_service.dart
│   ├── notification_service.dart
│   ├── tuning_engine.dart
│   └── analytics_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   └── water_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   ├── home/
│   ├── history/
│   ├── settings/
│   └── goal/
├── widgets/                  # Reusable widgets
│   ├── progress_indicator.dart
│   └── water_cup_widget.dart
└── utils/                    # Utilities
    ├── constants.dart
    ├── theme.dart
    └── date_utils.dart
```

## Key Features Implementation

### DayKey Strategy
Water entries use a `dayKey` field (format: "YYYY-MM-DD") for efficient, timezone-independent date queries.

### Smart Tuning Engine
The notification system automatically adjusts reminder intervals based on:
- Current water consumption
- Hours remaining in the day
- Daily goal progress

### Offline Support
Firestore offline persistence is enabled, allowing the app to work without internet connection.

### Transactional Operations
Delete operations use Firestore transactions to ensure data consistency.

## Testing

Run tests with:
```bash
flutter test
```

## Building for Production

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

## Privacy Policy

View our privacy policy at: [https://your-username.github.io/water-tracker/privacy-policy.html](https://your-username.github.io/water-tracker/privacy-policy.html)

Or view the markdown version: [PRIVACY_POLICY.md](PRIVACY_POLICY.md)

## License

[Your License Here]
