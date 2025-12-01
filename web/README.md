# JetStream Web App

A modern music streaming web application built with React, TypeScript, and Vite.

## 🚀 Quick Start (For New Users)

### Option 1: One-Click Setup (Windows)

1. **First Time Setup:**
   - Double-click `SETUP.bat`
   - Wait for installation to complete (2-5 minutes)

2. **Launch the App:**
   - Double-click `START.bat`
   - The app will automatically open in your browser at `http://localhost:3000`

### Option 2: Manual Setup (All Platforms)

**Prerequisites:**
- Node.js 18+ ([Download here](https://nodejs.org/))
- npm (comes with Node.js)

**Installation:**
```bash
# IMPORTANT: Navigate to the web folder first!
cd JetStream-main/web
# OR if you extracted to a different location:
cd "path/to/JetStream-main/web"

# Install dependencies
npm install

# Start development server
npm run dev
```

⚠️ **Common Mistake**: Make sure you're inside the `web` folder, NOT the root `JetStream-main` folder!

The app will be available at `http://localhost:3000`

## 📋 Features

- 🎵 Music streaming with Deezer API integration
- 🔍 Advanced search (tracks, albums, artists, playlists)
- 📱 Responsive design for all devices
- 🎨 Modern UI with smooth animations
- 💾 Local storage for favorites and playlists
- 🎧 Full-featured audio player with controls
- 📊 Real-time lyrics display
- 🌙 Dark theme optimized

## 🛠️ Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm run format` - Format code with Prettier

## 🏗️ Project Structure

```
web/
├── public/          # Static assets
├── src/
│   ├── components/  # Reusable components
│   ├── pages/       # Page components
│   ├── services/    # API services
│   ├── store/       # Redux store
│   ├── types/       # TypeScript types
│   └── utils/       # Utility functions
├── SETUP.bat        # Windows setup script
├── START.bat        # Windows start script
└── package.json     # Dependencies
```

## 🔧 Configuration

Create a `.env` file in the root directory:

```env
VITE_API_BASE_URL=https://api.deezer.com
VITE_CORS_PROXY=https://cors-anywhere.herokuapp.com
```

## 🌐 Browser Support

- Chrome (recommended)
- Firefox
- Safari
- Edge

## 📝 Development

### Tech Stack
- **Frontend:** React 18 + TypeScript
- **State Management:** Redux Toolkit
- **Routing:** React Router v6
- **Build Tool:** Vite
- **Styling:** CSS Modules
- **API:** Deezer Public API

### Code Quality
- ESLint for linting
- Prettier for code formatting
- TypeScript for type safety

## 🚨 Troubleshooting

**❌ Error: "Could not read package.json" or "ENOENT: no such file or directory"**

This means you're in the wrong folder! 

**Solution:**
```bash
# Check your current location
pwd   # On Mac/Linux
cd    # On Windows

# You should see something like: .../JetStream-main/web
# If you see: .../JetStream-main (without /web), then navigate:
cd web

# Now try again:
npm install
npm run dev
```

**Port 3000 already in use:**
```bash
# Kill the process using port 3000
npx kill-port 3000
# Then run npm run dev again
```

**Dependencies installation fails:**
```bash
# Clear npm cache
npm cache clean --force
# Delete node_modules and package-lock.json
rm -rf node_modules package-lock.json
# Reinstall
npm install
```

**Browser doesn't open automatically:**
- Manually open `http://localhost:3000` in your browser

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

- Developed as part of CSE412 Project
- East West University

## 🤝 Contributing

This is an academic project. For suggestions or issues, please contact the development team.

---

**Note:** This is a development version. For production deployment, run `npm run build` and deploy the `dist` folder to a web server.
