# JetStream Mobile v2 - Flutter Setup Instructions

## 🚀 Quick Start Guide

This Flutter app replaces the Expo React Native version with a more robust, cross-platform solution.

### Prerequisites

1. **Flutter SDK 3.0+** - [Install Flutter](https://docs.flutter.dev/get-started/install/windows)
2. **Android Studio** - For Android development
3. **Visual Studio Code** - With Flutter extension (optional but recommended)
4. **Git** - Already installed

### Step 1: Install Flutter Dependencies

Open PowerShell in the `mobile-v2` directory and run:

```powershell
flutter pub get
```

This will download all the packages specified in `pubspec.yaml`.

### Step 2: Verify Flutter Installation

```powershell
flutter doctor
```

Make sure you have:
- ✅ Flutter SDK installed
- ✅ Android toolchain (Android Studio, SDK, NDK)
- ✅ VS Code or Android Studio with Flutter plugins

### Step 3: Run the App

**For Android:**
```powershell
# List available devices
flutter devices

# Run on connected device/emulator
flutter run
```

**For Web (Development):**
```powershell
flutter run -d chrome
```

**For Windows Desktop:**
```powershell
flutter run -d windows
```

### Step 4: Build for Release

**Android APK:**
```powershell
flutter build apk --release
```

**Android App Bundle (for Play Store):**
```powershell
flutter build appbundle --release
```

Output will be in: `build/app/outputs/flutter-apk/app-release.apk`

## 📁 Project Structure

```
mobile-v2/
├── lib/
│   ├── main.dart                    # App entry point
│   │
│   ├── core/                        # Core functionality
│   │   └── theme/                   # Theme system
│   │       ├── app_theme.dart       # Main theme
│   │       ├── colors.dart          # Color palette
│   │       ├── typography.dart      # Text styles
│   │       ├── animations.dart      # Animation constants
│   │       └── spacing.dart         # Spacing & radius
│   │
│   ├── features/                    # Feature modules
│   │   ├── home/screens/           # Home screen
│   │   ├── search/screens/         # Search screen
│   │   ├── library/screens/        # Library screen
│   │   └── profile/screens/        # Profile screen
│   │
│   ├── shared/                      # Shared components
│   │   ├── models/                 # Data models
│   │   │   ├── track.dart
│   │   │   ├── album.dart
│   │   │   ├── artist.dart
│   │   │   └── playlist.dart
│   │   └── widgets/                # Reusable widgets
│   │       ├── animated_card.dart
│   │       └── neon_button.dart
│   │
│   └── services/                    # Services
│       ├── deezer_service.dart     # API integration
│       └── storage_service.dart    # Local storage
│
├── pubspec.yaml                     # Dependencies
└── README.md
```

## 🎨 Features

### Current (v2.0.0)
- ✅ Material Design 3
- ✅ Dark theme with neon accents
- ✅ Bottom navigation (Home, Search, Library, Profile)
- ✅ Animated UI components
- ✅ Type-safe models (Track, Album, Artist, Playlist)
- ✅ Deezer API service
- ✅ Local storage with SharedPreferences

### Next Steps
1. **Implement Deezer API calls in screens**
   - Load trending tracks on Home
   - Wire up search functionality
   - Display liked songs in Library

2. **Add Music Player**
   - Integrate `just_audio` package
   - Create mini player widget
   - Full player screen with gestures

3. **Add State Management**
   - Set up Provider/Riverpod
   - Player state
   - Library state

4. **Enhance UI**
   - Add more animated widgets (MusicCard, AlbumArt, GlassPlayer)
   - Implement loading states
   - Error handling UI

## 🔧 Common Issues & Solutions

### Issue: "Flutter not found"
**Solution:** Add Flutter to PATH
```powershell
$env:Path += ";C:\src\flutter\bin"
```

### Issue: "SDK version conflict"
**Solution:** Update Flutter
```powershell
flutter upgrade
```

### Issue: "Android licenses not accepted"
**Solution:**
```powershell
flutter doctor --android-licenses
```

### Issue: "No devices found"
**Solution:** 
- Start Android emulator from Android Studio
- Or enable USB debugging on physical device

## 📦 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_animate | ^4.5.0 | Animations |
| provider | ^6.1.1 | State management |
| go_router | ^13.0.0 | Navigation |
| just_audio | ^0.9.36 | Audio playback |
| dio | ^5.4.0 | HTTP client |
| shared_preferences | ^2.2.2 | Local storage |
| cached_network_image | ^3.3.1 | Image caching |

## 🎯 Development Workflow

1. **Hot Reload**: Press `r` in terminal during `flutter run`
2. **Hot Restart**: Press `R` in terminal
3. **Debug**: Use VS Code debugger with breakpoints
4. **Logs**: `flutter logs` to see device logs

## 🚀 Next Commands to Run

```powershell
# Navigate to mobile-v2
cd mobile-v2

# Get dependencies
flutter pub get

# Run app
flutter run

# If errors occur, clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📱 Testing

```powershell
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test
```

## 🎨 Customization

### Change Colors
Edit `lib/core/theme/colors.dart`

### Change Typography
Edit `lib/core/theme/typography.dart`

### Add New Screen
1. Create screen file in `lib/features/{feature}/screens/`
2. Add route in `main.dart`
3. Add navigation destination if needed

## 💡 Tips

- Use `const` constructors wherever possible for better performance
- Leverage Flutter DevTools for debugging
- Use `flutter analyze` to check for code issues
- Run `flutter build` commands with `--release` flag for optimized builds

## 📞 Support

- Flutter Docs: https://docs.flutter.dev
- JetStream Issues: (GitHub repo)
- Flutter Community: https://flutter.dev/community

---

**Ready to build!** 🎵

Run `flutter pub get` in the `mobile-v2` directory to get started.
