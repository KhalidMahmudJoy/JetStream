# JetStream Mobile v2.0 🎵

A beautiful, feature-rich music streaming app built with **Flutter** for Android and iOS.

## ✨ Features

### Core Features
- 🎵 **Music Player**: Play 30-second previews from Deezer API
- 🔍 **Search**: Search tracks, albums, and artists with filters
- 📚 **Library**: Manage liked songs, playlists, and recently played
- 🎨 **Beautiful UI**: Dark theme with neon accents and glassmorphism
- 🎬 **Smooth Animations**: Entrance animations, transitions, and gestures
- 📱 **Responsive**: Works perfectly on all screen sizes

### Advanced Features
- ⚡ **Background Playback**: Continue playing when app is in background
- 🔀 **Queue Management**: Drag-and-drop to reorder tracks
- 💚 **Like System**: Save your favorite tracks
- 📝 **Playlist Management**: Create, edit, delete playlists
- 🎚️ **Audio Controls**: Play, pause, skip, seek, volume, shuffle, repeat
- 📊 **Playback Speed**: Adjust speed from 0.25x to 2x
- 🌐 **Offline Support**: Cache tracks and album art
- 🎤 **Lyrics**: Display synchronized lyrics (coming soon)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio / Xcode
- Android device/emulator or iOS device/simulator

### Installation

1. **Clone the repository**
   ```bash
   cd mobile-v2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For Web (development)
   flutter run -d chrome
   ```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📁 Project Structure

```
mobile-v2/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── app.dart                  # App configuration
│   │
│   ├── core/                     # Core functionality
│   │   ├── theme/               # Theme configuration
│   │   │   ├── app_theme.dart
│   │   │   ├── colors.dart
│   │   │   ├── typography.dart
│   │   │   └── animations.dart
│   │   ├── router/              # Navigation
│   │   │   └── app_router.dart
│   │   ├── constants/           # App constants
│   │   └── utils/               # Utilities
│   │
│   ├── features/                # Feature modules
│   │   ├── home/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   ├── search/
│   │   ├── library/
│   │   ├── player/
│   │   ├── profile/
│   │   └── settings/
│   │
│   ├── shared/                  # Shared components
│   │   ├── widgets/            # Reusable widgets
│   │   │   ├── animated_card.dart
│   │   │   ├── neon_button.dart
│   │   │   ├── music_card.dart
│   │   │   ├── glass_player.dart
│   │   │   └── album_art.dart
│   │   └── models/             # Data models
│   │
│   └── services/                # Services
│       ├── deezer_service.dart
│       ├── audio_service.dart
│       ├── storage_service.dart
│       └── cache_service.dart
│
├── assets/                      # Assets
│   ├── images/
│   ├── icons/
│   ├── animations/
│   └── fonts/
│
├── pubspec.yaml                 # Dependencies
└── README.md
```

## 🎨 Design System

### Colors
- **Background**: `#0A0E27` (Deep Space Black)
- **Accent**: `#00D9FF` (Electric Blue)
- **Secondary**: `#1ED760` (Spotify Green)
- **Text**: `#FFFFFF` (White)

### Typography
- **Font Family**: Inter
- **Sizes**: 11px to 48px
- **Weights**: Light (300) to Bold (700)

### Animations
- **Duration**: 150ms (fast), 250ms (normal), 350ms (slow)
- **Easing**: Ease-in, ease-out, spring

## 🔧 Technologies Used

- **Flutter**: Cross-platform framework
- **Riverpod**: State management
- **GoRouter**: Navigation
- **just_audio**: Audio playback
- **audio_service**: Background playback
- **Dio**: HTTP client
- **Hive**: Local storage
- **flutter_animate**: Animations

## 📝 API

Using **Deezer Public API** (no API key required):
- Search: `https://api.deezer.com/search?q={query}`
- Track: `https://api.deezer.com/track/{id}`
- Album: `https://api.deezer.com/album/{id}`
- Artist: `https://api.deezer.com/artist/{id}`
- Chart: `https://api.deezer.com/chart`

## 🧪 Testing

```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## 📦 Deployment

### Android
1. Update `android/app/build.gradle` with signing config
2. Generate keystore: `keytool -genkey -v -keystore key.jks -keyalg RSA`
3. Build: `flutter build appbundle --release`
4. Upload to Google Play Console

### iOS
1. Configure signing in Xcode
2. Build: `flutter build ios --release`
3. Archive and upload to App Store Connect

## 🤝 Contributing

This is a university project. Contributions are welcome!

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Shahriar Khan**  
East West University - CSE412 Project

---

Made with ❤️ and Flutter
