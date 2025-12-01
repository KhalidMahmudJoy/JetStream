# 🎵 JetStream Mobile v2.0 - Flutter Implementation

## Overview

This is a complete rewrite of the JetStream mobile app using **Flutter** instead of Expo/React Native. Flutter provides better cross-platform support, superior performance, and a more robust development experience.

## Why Flutter Over Expo?

### Problems with Expo Version:
- ❌ SDK version conflicts (SDK 50 vs SDK 54)
- ❌ Node.js version incompatibility
- ❌ npm workspace conflicts
- ❌ Expo Go permission issues
- ❌ Java/Gradle version mismatches
- ❌ Limited native module support
- ❌ Complex debugging process

### Benefits of Flutter:
- ✅ Single codebase for Android, iOS, Web, Windows, macOS, Linux
- ✅ No version conflicts - stable SDK
- ✅ Better performance (compiled to native code)
- ✅ Rich widget library with Material Design 3
- ✅ Hot reload for fast development
- ✅ Easier state management
- ✅ Better animation framework
- ✅ Strong typing with Dart
- ✅ Excellent documentation

## Project Status

### ✅ Completed (v2.0.0)

1. **Project Structure**
   - Clean architecture with feature modules
   - Proper separation of concerns
   - Scalable directory organization

2. **Theme System**
   - Complete color palette matching JetStream brand
   - Typography system with Inter font family
   - Animation constants and utilities
   - Spacing and radius constants
   - Dark theme with Material Design 3

3. **Data Models**
   - Track model with Deezer API mapping
   - Album model
   - Artist model
   - Playlist model with CRUD support

4. **Services**
   - Deezer API service with full endpoints
   - Storage service with SharedPreferences
   - Liked songs management
   - Playlist management
   - Recently played tracking
   - Settings persistence

5. **Core Navigation**
   - Bottom navigation with 4 tabs
   - Home Screen (with mock data)
   - Search Screen (with search bar and filters)
   - Library Screen (with tabs)
   - Profile Screen (with stats and settings)

6. **Reusable Widgets**
   - AnimatedCard with entrance animations
   - NeonButton with variants
   - GlassCard with glassmorphism
   - GradientCard

### 🚧 In Progress

1. **API Integration**
   - Connect Deezer API to screens
   - Load real data
   - Implement search functionality
   - Error handling

2. **Music Player**
   - just_audio integration
   - Mini player widget
   - Full player screen
   - Playback controls

3. **State Management**
   - Provider/Riverpod setup
   - Player state
   - Library state
   - Search state

### 📋 Todo

1. **Enhanced UI Components**
   - MusicCard with swipe gestures
   - AlbumArt with loading states
   - GlassPlayer mini player
   - TrackList with virtualization

2. **Advanced Features**
   - Background playback
   - Lock screen controls
   - Queue management with drag-and-drop
   - Playback speed control
   - Equalizer
   - Lyrics display
   - Audio visualizer

3. **Performance**
   - Image caching optimization
   - Lazy loading
   - State optimization

4. **Testing**
   - Unit tests
   - Widget tests
   - Integration tests

## Quick Start

### Prerequisites
- Flutter SDK 3.0+ installed
- Android Studio with Flutter plugin
- VS Code with Flutter extension (optional)

### Setup

```bash
# Navigate to mobile-v2
cd mobile-v2

# Get dependencies
flutter pub get

# Run app
flutter run

# Or use the setup script
setup.bat
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# The output will be in:
# build/app/outputs/flutter-apk/app-release.apk
```

## Architecture

```
mobile-v2/
├── lib/
│   ├── main.dart                    # App entry point with navigation
│   │
│   ├── core/                        # Core utilities
│   │   └── theme/                   # Design system
│   │       ├── app_theme.dart       # Material theme configuration
│   │       ├── colors.dart          # Color palette
│   │       ├── typography.dart      # Text styles
│   │       ├── animations.dart      # Animation constants
│   │       └── spacing.dart         # Spacing & border radius
│   │
│   ├── features/                    # Feature modules (feature-first)
│   │   ├── home/
│   │   │   ├── screens/            # Home screen
│   │   │   ├── widgets/            # Home-specific widgets
│   │   │   └── providers/          # Home state management
│   │   ├── search/
│   │   ├── library/
│   │   ├── player/
│   │   ├── profile/
│   │   └── settings/
│   │
│   ├── shared/                      # Shared across features
│   │   ├── models/                 # Data models
│   │   │   ├── track.dart          # Track model with fromJson
│   │   │   ├── album.dart          # Album model
│   │   │   ├── artist.dart         # Artist model
│   │   │   └── playlist.dart       # Playlist model
│   │   └── widgets/                # Reusable widgets
│   │       ├── animated_card.dart  # Animated container
│   │       ├── neon_button.dart    # Custom button
│   │       └── ...                 # More widgets
│   │
│   └── services/                    # Business logic services
│       ├── deezer_service.dart     # Deezer API client
│       ├── storage_service.dart    # Local persistence
│       └── audio_service.dart      # Audio playback (todo)
│
├── assets/                          # Static assets
│   ├── images/
│   ├── icons/
│   ├── animations/
│   └── fonts/
│
├── pubspec.yaml                     # Dependencies and metadata
├── README.md                        # This file
├── SETUP_INSTRUCTIONS.md            # Detailed setup guide
└── setup.bat                        # Windows setup script
```

## Design System

### Color Palette

```dart
// Primary Background
backgroundPrimary: #0A0E27
backgroundSecondary: #141B34
backgroundTertiary: #1C2541

// Accent Colors
accentPrimary: #00D9FF (Electric Blue)
secondaryPrimary: #1ED760 (Spotify Green)

// Text Colors
textPrimary: #FFFFFF
textSecondary: #A0A9C0
textTertiary: #6B7280

// Semantic Colors
success: #10B981
warning: #F59E0B
error: #EF4444
```

### Typography

- **Font Family**: Inter (Light, Regular, Medium, SemiBold, Bold)
- **Sizes**: 11px to 48px (8 sizes)
- **Line Heights**: Tight (1.2), Normal (1.5), Relaxed (1.75)

### Animations

- **Fast**: 150ms
- **Normal**: 250ms
- **Slow**: 350ms
- **Curves**: easeIn, easeOut, easeInOut, spring

## Key Dependencies

| Package | Purpose |
|---------|---------|
| **flutter_animate** | Declarative animations |
| **provider** | State management |
| **go_router** | Navigation |
| **just_audio** | Audio playback |
| **audio_service** | Background audio |
| **dio** | HTTP client |
| **shared_preferences** | Local storage |
| **cached_network_image** | Image caching |
| **hive** | NoSQL database |
| **flutter_slidable** | Swipe actions |
| **shimmer** | Loading placeholders |
| **lottie** | Lottie animations |
| **glassmorphism** | Blur effects |

## API Integration

Using **Deezer Public API** (no API key required):

- Base URL: `https://api.deezer.com`
- CORS Proxy: `https://corsproxy.io/?` (for web)

### Available Endpoints:

```dart
// Search
GET /search?q={query}
GET /search/album?q={query}
GET /search/artist?q={query}

// Get by ID
GET /track/{id}
GET /album/{id}
GET /artist/{id}

// Charts
GET /chart/0/tracks
GET /chart/0/albums
GET /chart/0/artists

// Artist tracks
GET /artist/{id}/top
GET /album/{id}/tracks
```

## Development Workflow

### Hot Reload
Press `r` in the terminal while running to instantly see changes.

### Hot Restart
Press `R` to restart the app with code changes.

### Debug Mode
Use VS Code debugger with breakpoints for debugging.

### Performance
Run with `--profile` flag to analyze performance:
```bash
flutter run --profile
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/widget_test.dart
```

## Common Commands

```bash
# Clean build artifacts
flutter clean

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Check Flutter setup
flutter doctor -v
```

## Migration from Expo

### What's Different?

1. **Language**: Dart instead of TypeScript/JavaScript
2. **Components**: Flutter widgets instead of React components
3. **Styling**: Dart code instead of CSS/StyleSheet
4. **State**: Provider/Riverpod instead of Redux/Context
5. **Navigation**: go_router instead of React Navigation
6. **Audio**: just_audio instead of expo-av

### What's Better?

- No more npm/node version conflicts
- Faster compilation and hot reload
- Better performance (native code)
- Easier debugging
- More comprehensive widget library
- Better documentation
- Cross-platform support (6 platforms)

## Deployment

### Android

1. Update `android/app/build.gradle`:
   - Set `applicationId`
   - Set `versionCode` and `versionName`

2. Create signing key:
   ```bash
   keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```

3. Configure signing in `android/key.properties`

4. Build:
   ```bash
   flutter build appbundle --release
   ```

5. Upload to Google Play Console

### iOS

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing
3. Update bundle identifier
4. Build and archive
5. Upload to App Store Connect

## Contributing

This is a university project (CSE412). Contributions are welcome!

### Guidelines:
- Follow Flutter style guide
- Use meaningful commit messages
- Test your changes
- Update documentation

## License

MIT License - See LICENSE file

## Author

**Shahriar Khan**  
East West University  
CSE412 - Software Engineering Project

---

## Next Steps

1. **Run the app**: `flutter run`
2. **Connect API**: Implement Deezer API calls in screens
3. **Add player**: Integrate just_audio for playback
4. **Enhance UI**: Add more animated components
5. **Test**: Write tests for critical functionality
6. **Deploy**: Build and publish to stores

---

**Built with ❤️ using Flutter**
