# Contacts App

A modern Flutter contacts management application with offline-first architecture, Firebase sync, and direct calling functionality.

## Features

### Core Functionality
- **CRUD Operations**: Create, read, update, and delete contacts
- **Offline-First**: SQLite local database with automatic Firebase synchronization
- **Direct Calling**: Make phone calls directly from the app (like Truecaller)
- **Favorites**: Mark contacts as favorites for quick access
- **Search**: Real-time search by name, phone, or email
- **Pagination**: Efficient loading of contacts (20 per page)

### Data Management
- **Dual Storage**: Firebase Firestore for cloud storage + SQLite for offline access
- **Auto-Sync**: Automatic synchronization between local and cloud databases
- **Sync Indicator**: Visual badge showing unsynced contacts count
- **Restore Capability**: Restore all contacts to Firebase if collection is deleted
- **Duplicate Prevention**: Validates and prevents duplicate contacts by name or phone

### User Interface
- **Material Design 3**: Modern, intuitive UI with Material 3 components
- **Theme Support**: Light, dark, and system default themes with persistent storage
- **Bottom Navigation**: Easy navigation between Contacts and Favorites
- **Responsive Design**: Adapts to various screen sizes and orientations
- **Empty States**: Helpful messages when no contacts are found

### Validation
- **Name**: Minimum 2 characters, letters and spaces only
- **Phone**: 10-15 digits with optional + prefix
- **Email**: Valid email format (optional field)

### Architecture
- **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
- **BLoC Pattern**: State management using flutter_bloc
- **Dependency Injection**: get_it for service locator pattern
- **Repository Pattern**: Abstract data sources for testability

## Installation

### Prerequisites
- Flutter SDK (^3.10.3)
- Dart SDK
- Firebase account
- iOS Simulator or Android Emulator

### Setup Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd contacts_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure FlutterFire
flutterfire configure --project=contacts-app --platforms=android,ios
```

4. **Setup Firestore Database**
- Go to [Firebase Console](https://console.firebase.google.com)
- Select your project
- Navigate to **Firestore Database** from the left menu
- Click **Create Database**
- Choose **Start in test mode** (for development)
- Select a location and click **Enable**

5. **Configure Firestore Rules**

In Firebase Console, go to **Firestore Database > Rules** and set:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /contacts/{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Note**: These are public rules for development. For production, implement proper authentication and security rules.

6. **Run the app**
```bash
# For iOS
flutter run -d "iPhone 16 Pro"

# For Android
flutter run -d <device-id>
```

## Project Structure

```
lib/
├── core/
│   ├── database/
│   │   └── sqlite_database.dart
│   ├── theme/
│   │   └── theme_cubit.dart
│   └── service_locator.dart
├── features/
│   └── contacts/
│       ├── data/
│       │   ├── models/
│       │   │   └── contact_model.dart
│       │   ├── repository/
│       │   │   └── contact_repository_impl.dart
│       │   └── services/
│       │       ├── firebase_contact_service.dart
│       │       └── local_database_service.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── contact_entity.dart
│       │   ├── repository/
│       │   │   └── contact_repository.dart
│       │   └── usecases/
│       │       ├── add_contact_usecase.dart
│       │       ├── delete_contact_usecase.dart
│       │       ├── get_all_contacts_usecase.dart
│       │       ├── sync_contacts_usecase.dart
│       │       └── update_contact_usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── contact_bloc.dart
│           │   ├── contact_event.dart
│           │   └── contact_state.dart
│           ├── view/
│           │   ├── add_edit_contact_screen.dart
│           │   ├── contact_details_screen.dart
│           │   ├── contacts_view.dart
│           │   ├── favorites_view.dart
│           │   └── home_screen.dart
│           └── widgets/
│               ├── contact_card_widget.dart
│               ├── contact_list_widget.dart
│               └── empty_state_widget.dart
└── main.dart
```

## Dependencies

- **firebase_core**: ^3.8.1
- **cloud_firestore**: ^5.5.1
- **sqflite**: ^2.4.1
- **flutter_bloc**: ^8.1.6
- **get_it**: ^8.0.2
- **flutter_phone_direct_caller**: ^2.2.1
- **shared_preferences**: ^2.3.3

## Usage

### Adding Contacts
1. Tap the + button on the Contacts tab
2. Fill in name, phone, and optional email
3. Tap the checkmark to save

### Calling Contacts
- Tap the call icon on any contact card
- Or open contact details and tap the "Call" button

### Managing Favorites
- Tap the heart icon to add/remove from favorites
- View all favorites in the Favorites tab

### Syncing Data
- Sync icon appears when there are unsynced contacts
- Tap the sync icon to sync with Firebase
- Badge shows count of unsynced contacts

### Bulk Operations
- Use the menu (⋮) to add 50 test contacts
- Use "Restore to Firebase" if cloud data is lost

### Changing Theme
- Tap the brightness icon in the app bar
- Choose Light, Dark, or System Default
- Theme preference is saved automatically

## License

This project is a Flutter learning application.
