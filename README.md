# 🎵 JetStream Music Player - Version 2.0 (In Development)

**Modern Web-Based Music Streaming Application**

[![Version](https://img.shields.io/badge/version-2.0.0--dev-orange)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Node](https://img.shields.io/badge/node-%3E%3D18-brightgreen)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-18.2-61DAFB?logo=react)](https://reactjs.org/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [What's Implemented](#-whats-implemented)
- [Version Roadmap](#-version-roadmap)
- [Testing](#-testing)
- [Contributing](#-contributing)
- [Known Limitations](#-known-limitations)
- [Team](#-team)
- [License](#-license)

---

## 🌟 Overview

**JetStream** is a Progressive Web Application (PWA) that delivers a seamless music streaming experience with a stunning glassmorphism UI, advanced audio controls, and intelligent caching features.

**Version 2.0** is currently in development, adding mobile applications, backend infrastructure, user authentication, and real lyrics integration. See [V2_ROADMAP.md](V2_ROADMAP.md) for details.

### Why JetStream?

- 🎨 **Beautiful UI** - Modern glassmorphism design with smooth animations
- ⚡ **Fast & Responsive** - Optimized for all devices
- 🎵 **Rich Features** - Playlists, visualizer, lyrics, and more
- 🚀 **Easy Setup** - One-click installation for testers
- 📱 **PWA Ready** - Install on desktop or mobile
- 🆓 **Free & Open Source** - MIT Licensed

---

## ✨ Features

### 🎵 Music & Audio

- **Search Engine** - Search millions of songs via Deezer API
- **Audio Playback** - High-quality streaming (30-second previews)
- **Visualizer** - Real-time audio frequency visualization
- **Lyrics Display** - Demo lyrics panel (real lyrics coming in V2)
- **Queue Management** - Add songs to queue and reorder

### 🎛️ Playback Controls

- **Full Controls** - Play, pause, skip forward/backward
- **Volume Control** - Smooth volume slider with mute
- **Progress Bar** - Seekable timeline with timestamps
- **Repeat Modes** - None, repeat one, repeat all
- **Shuffle** - Randomize playback order

### 📝 Playlists

- **Create Playlists** - Unlimited custom playlists
- **Manage Songs** - Add, remove, reorder tracks
- **Edit Playlists** - Rename and customize
- **Persistent Storage** - Saved in browser localStorage

### 🎨 User Interface

- **Glassmorphism Design** - Translucent glass-effect components
- **Dark Theme** - Beautiful gradients optimized for viewing
- **Responsive Layout** - Works on mobile, tablet, and desktop
- **Smooth Animations** - Fluid transitions and hover effects
- **Interactive Cards** - Dynamic song and album displays

### ⚡ Performance

- **API Caching** - 24-hour cache for faster searches
- **Offline Indicator** - Shows connection status
- **PWA Support** - Installable on any device
- **Optimized Assets** - Fast loading times
- **Lazy Loading** - Components load on demand

---

## 🚀 Quick Start

### For Testers (Windows - Easy Method)

**3 Simple Steps:**

1. **Install Node.js**
   - Download from [nodejs.org](https://nodejs.org/)
   - Choose LTS version
   - Install with default settings

2. **Run Setup** (First time only)
   - Double-click **`setup.bat`**
   - Wait 2-5 minutes for dependencies

3. **Start Application**
   - Double-click **`start.bat`**
   - Browser opens automatically at `http://localhost:5173`

**That's it!** 🎉

💡 **Need help?** See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions and troubleshooting.

### For Developers (Manual Setup)

```bash
# Clone repository
git clone https://github.com/ShahriarKhan016/Project-JetStream-Final.git
cd "Project JetStream"

# Install dependencies
cd web
npm install

# Start development server
npm run dev

# Open http://localhost:5173 in browser
```

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: React 18.2
- **Language**: TypeScript 5.3
- **Build Tool**: Vite 5.4
- **State Management**: Redux Toolkit 2.5
- **Routing**: React Router v6
- **Styling**: CSS Modules

### APIs & Services
- **Music API**: Deezer Public API
- **Audio Engine**: HTML5 Audio + Web Audio API
- **Caching**: localStorage with TTL

### Tools & DevOps
- **Package Manager**: npm
- **Version Control**: Git
- **Code Quality**: TypeScript, ESLint

---

## 📁 Project Structure

```
JetStream/
├── web/                          # Web application
│   ├── src/
│   │   ├── components/          # React components
│   │   │   ├── GlassPlayer.tsx
│   │   │   ├── AudioVisualizer.tsx
│   │   │   ├── LyricsPanel.tsx
│   │   │   └── ...
│   │   ├── pages/               # Page components
│   │   │   ├── Home.tsx
│   │   │   ├── Search.tsx
│   │   │   ├── Library.tsx
│   │   │   └── Settings.tsx
│   │   ├── services/            # API services
│   │   │   ├── deezer.service.ts
│   │   │   ├── lyrics.service.ts
│   │   │   └── apiCache.service.ts
│   │   ├── store/               # Redux store
│   │   ├── router/              # Routing config
│   │   └── main.tsx             # Entry point
│   ├── public/
│   │   ├── manifest.json        # PWA manifest
│   │   └── sw.js                # Service worker
│   └── package.json
├── shared/                       # Shared types & theme
├── docs/                         # Documentation
├── setup.bat                     # Windows setup script
├── start.bat                     # Windows start script
├── README.md                     # This file
├── SETUP_GUIDE.md                # Installation guide
├── CONTRIBUTING.md               # Contribution guidelines
├── CHANGELOG.md                  # Version history
└── LICENSE                       # MIT License
```

---

## ✅ What's Implemented

### ✨ Fully Working (Version 1.0)

- ✅ Music search and discovery
- ✅ Audio playback (30s previews)
- ✅ Playlist creation and management
- ✅ Audio frequency visualizer
- ✅ Lyrics panel (demo mode)
- ✅ Responsive UI (all screen sizes)
- ✅ API response caching
- ✅ PWA capabilities
- ✅ Settings and preferences
- ✅ Offline indicator
- ✅ Keyboard shortcuts
- ✅ Volume control
- ✅ Progress tracking
- ✅ Repeat and shuffle modes

### ⚠️ Known Limitations (V1)

1. **Audio Playback**
   - Limited to 30-second previews (Deezer API restriction)
   - Full-length songs require backend (coming in V2)

2. **Lyrics**
   - Shows demo text for all songs
   - CORS restrictions prevent direct API calls
   - Backend proxy needed for real lyrics (V2)

3. **Data Storage**
   - Playlists stored in browser localStorage only
   - No cloud synchronization
   - Clearing browser data loses playlists

4. **Authentication**
   - No user accounts in V1
   - No cross-device sync
   - Coming in V2 with backend

5. **Service Worker**
   - Disabled in V1 to simplify testing
   - Will be enabled in production builds

---

## 🗺️ Version Roadmap

### Version 1.0 - Current Release ✅
*Released: November 2025*

**Focus**: Web application with core features
- Complete music player interface
- Playlist management
- Audio visualization
- PWA setup
- Caching system
- Responsive design

### Version 2.0 - Planned (Q1-Q2 2026) 🚀

**Mobile Applications**
- React Native iOS app
- React Native Android app
- Native audio playback
- Push notifications
- Offline song downloads

**Backend & Authentication**
- Node.js/Express API server
- PostgreSQL database
- JWT-based authentication
- User profiles and accounts
- Cloud-synced playlists
- Social features (follow, share)

**Enhanced Features**
- Real lyrics with API proxy
- Lyrics highlighting/karaoke mode
- Full-length song playback
- AI-powered recommendations
- Crossfade between songs
- Equalizer controls
- Sleep timer
- Podcast support

### Version 3.0 - Future (2026+) 🌟

- Desktop applications (Electron)
- AI music discovery
- Social music sharing
- Collaborative playlists
- Live radio stations
- Concert information
- Artist pages with bios

---

## 🧪 Testing

### Manual Testing Checklist

**Basic Functionality**
- [ ] Home page loads without errors
- [ ] Search returns relevant results
- [ ] Songs play audio correctly
- [ ] Play/pause button works
- [ ] Skip forward/backward works
- [ ] Volume control adjusts audio
- [ ] Progress bar seeks correctly
- [ ] Repeat modes cycle properly
- [ ] Shuffle randomizes playback

**Playlists**
- [ ] Can create new playlist
- [ ] Can add songs to playlist
- [ ] Can remove songs from playlist
- [ ] Can delete entire playlist
- [ ] Can rename playlist
- [ ] Playlists persist after browser refresh

**User Interface**
- [ ] Responsive on mobile (400px width)
- [ ] Responsive on tablet (768px width)
- [ ] Responsive on desktop (1920px width)
- [ ] All buttons have hover effects
- [ ] No broken images or icons
- [ ] Smooth animations throughout
- [ ] No layout shifts

**Performance**
- [ ] Initial page load < 3 seconds
- [ ] Search results appear < 1 second
- [ ] Audio starts playing < 2 seconds
- [ ] No lag when scrolling
- [ ] No memory leaks after 30min use

### Browser Compatibility

Tested and working on:
- ✅ Chrome 120+ (Recommended)
- ✅ Firefox 121+
- ✅ Edge 120+
- ✅ Safari 17+

### Reporting Bugs

Found a bug? Please report it!

**Include:**
1. What you were doing
2. What happened (with screenshots)
3. What you expected
4. Browser and OS version
5. Console errors (F12 → Console)

**Report via:**
- GitHub Issues (preferred)
- Email to development team

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Contribution Guide

1. Fork the repository
2. Create feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test thoroughly
5. Commit: `git commit -m "Add: your feature"`
6. Push: `git push origin feature/your-feature`
7. Create Pull Request

### Development Workflow

```bash
# Setup development environment
cd web
npm install
npm run dev

# Make changes
# Test locally
# Commit and push
```

---

## 👥 Team

**Development Team**
- [Your Name] - Lead Developer
- [Teammate 1] - Frontend Developer
- [Teammate 2] - UI/UX Designer
- [Teammate 3] - QA Tester

**Course Information**
- **Course**: CSE412 - Software Engineering
- **Semester**: 10th Semester
- **Institution**: EWU University
- **Year**: 2025

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**TL;DR**: You can use, modify, and distribute this project freely. Just include the original license.

---

## 💬 Support

Need help? We're here!

- 📖 **Documentation**: Check [SETUP_GUIDE.md](SETUP_GUIDE.md)
- 🐛 **Bug Reports**: Create a GitHub Issue
- 💡 **Feature Requests**: Create a GitHub Issue with `enhancement` label
- 📧 **Email**: Contact the development team
- 💬 **Discussion**: GitHub Discussions tab

---

## 🙏 Acknowledgments

- **Deezer API** - Music catalog and streaming
- **React Team** - Amazing framework
- **Vite Team** - Lightning-fast build tool
- **Open Source Community** - Various libraries used
- **Our Users** - Thank you for testing and feedback!

---

## 📚 Additional Resources

- [Setup Guide](SETUP_GUIDE.md) - Detailed installation instructions
- [Contributing Guide](CONTRIBUTING.md) - How to contribute
- [Changelog](CHANGELOG.md) - Version history
- [Deployment Guide](DEPLOYMENT.md) - Pushing to GitHub
- [API Documentation](docs/API.md) - API reference

---

<div align="center">

**Made with ❤️ by the JetStream Team**

🎵 **Enjoy JetStream Music Player!** 🎵

[⬆️ Back to Top](#-jetstream-music-player---version-10)

</div>
