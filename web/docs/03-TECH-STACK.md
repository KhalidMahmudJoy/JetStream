# Technology Stack

## 1. Frontend Technologies

### 1.1 Core Framework

| Technology | Version | Purpose |
|------------|---------|---------|
| **React** | 18.2.0 | UI Component Library |
| **TypeScript** | 5.3.3 | Static Type Checking |
| **Vite** | 5.4.21 | Build Tool & Dev Server |

### 1.2 State Management

| Technology | Version | Purpose |
|------------|---------|---------|
| **React Context** | Built-in | Global State (Player, Theme) |
| **Redux Toolkit** | 2.3.0 | Future State Management |
| **useState/useReducer** | Built-in | Local Component State |

### 1.3 Routing

| Technology | Version | Purpose |
|------------|---------|---------|
| **React Router DOM** | 6.27.0 | Client-side Routing |

### 1.4 Styling

| Technology | Version | Purpose |
|------------|---------|---------|
| **CSS Modules** | Built-in | Scoped Component Styles |
| **CSS Variables** | Native | Theme Management |
| **Framer Motion** | 11.11.17 | Animations & Transitions |

### 1.5 UI Components

| Technology | Version | Purpose |
|------------|---------|---------|
| **Lucide React** | 0.454.0 | Icon Library |
| **Framer Motion** | 11.11.17 | Drag & Drop, Animations |

---

## 2. Audio Technologies

### 2.1 Web Audio API

```typescript
// Audio Processing Stack
const audioStack = {
  // Core Audio
  HTMLAudioElement: 'Audio playback',
  AudioContext: 'Audio processing context',
  MediaElementSourceNode: 'Connect HTML audio to Web Audio',
  
  // Processing Nodes
  BiquadFilterNode: 'Equalizer bands (10x)',
  AnalyserNode: 'Audio visualization data',
  GainNode: 'Volume control',
  
  // Output
  AudioDestinationNode: 'Speaker output'
};
```

### 2.2 Audio Features

| Feature | Technology | Description |
|---------|------------|-------------|
| Playback | HTMLAudioElement | Basic audio playback |
| Equalizer | BiquadFilterNode | 10-band parametric EQ |
| Visualization | AnalyserNode | FFT frequency data |
| Volume | GainNode | Amplitude control |

---

## 3. External APIs

### 3.1 Deezer API

| Endpoint | Purpose | Rate Limit |
|----------|---------|------------|
| `/search` | Search tracks, albums, artists | 50 req/5sec |
| `/chart` | Get trending content | 50 req/5sec |
| `/album/{id}` | Get album details | 50 req/5sec |
| `/artist/{id}` | Get artist details | 50 req/5sec |
| `/track/{id}` | Get track details | 50 req/5sec |

### 3.2 CORS Proxy

```typescript
// API Configuration
const CORS_PROXIES = [
  'https://corsproxy.io/?',
  'https://api.allorigins.win/raw?url=',
  'https://cors-anywhere.herokuapp.com/'
];

const DEEZER_BASE_URL = 'https://api.deezer.com';
```

### 3.3 Lyrics APIs (Fallback Chain)

```typescript
const LYRICS_SOURCES = [
  { name: 'lyrics.ovh', priority: 1 },
  { name: 'lrclib.net', priority: 2 },
  { name: 'chartlyrics.com', priority: 3 }
];
```

---

## 4. Development Tools

### 4.1 Build & Bundling

| Tool | Version | Purpose |
|------|---------|---------|
| **Vite** | 5.4.21 | Build tool, HMR, bundling |
| **esbuild** | Bundled | Fast JavaScript bundler |
| **Rollup** | Bundled | Production builds |

### 4.2 Type Checking

| Tool | Version | Purpose |
|------|---------|---------|
| **TypeScript** | 5.3.3 | Static type analysis |
| **@types/react** | 18.3.12 | React type definitions |
| **@types/react-dom** | 18.3.1 | ReactDOM type definitions |

### 4.3 Code Quality

| Tool | Purpose |
|------|---------|
| **ESLint** | JavaScript/TypeScript linting |
| **Prettier** | Code formatting |
| **TypeScript strict mode** | Strict type checking |

---

## 5. Browser APIs Used

### 5.1 Storage APIs

```typescript
// Local Storage Usage
const storageKeys = {
  LIKED_SONGS: 'jetstream_liked_songs',
  PLAYLISTS: 'jetstream_playlists',
  RECENTLY_PLAYED: 'jetstream_recently_played',
  SETTINGS: 'jetstream_settings',
  THEME: 'jetstream_theme',
  API_CACHE: 'jetstream_api_cache_*'
};
```

### 5.2 Media APIs

| API | Usage |
|-----|-------|
| **HTMLMediaElement** | Audio playback control |
| **Web Audio API** | Advanced audio processing |
| **MediaSession API** | OS media controls (future) |

### 5.3 Other Browser APIs

| API | Usage |
|-----|-------|
| **Fetch API** | HTTP requests |
| **URL API** | URL manipulation |
| **History API** | Client-side routing |
| **Clipboard API** | Copy functionality |
| **ResizeObserver** | Responsive components |

---

## 6. Package Dependencies

### 6.1 Production Dependencies

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.27.0",
    "framer-motion": "^11.11.17",
    "lucide-react": "^0.454.0",
    "@reduxjs/toolkit": "^2.3.0",
    "react-redux": "^9.1.2"
  }
}
```

### 6.2 Development Dependencies

```json
{
  "devDependencies": {
    "@types/react": "^18.3.12",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.3",
    "typescript": "^5.3.3",
    "vite": "^5.4.21"
  }
}
```

---

## 7. File Structure

### 7.1 Source Code Organization

```
src/
├── components/          # Reusable UI components
│   ├── Layout.tsx       # Main layout wrapper
│   ├── GlassPlayer.tsx  # Audio player component
│   ├── QueuePanel.tsx   # Queue management
│   ├── LyricsPanel.tsx  # Lyrics display
│   └── *.module.css     # Component styles
│
├── contexts/            # React Context providers
│   ├── PlayerContext.tsx # Audio player state
│   └── ThemeContext.tsx  # Theme management
│
├── hooks/               # Custom React hooks
│   ├── useKeyboardShortcuts.ts
│   └── useLocalStorage.ts
│
├── pages/               # Route page components
│   ├── HomePage.tsx
│   ├── SearchPage.tsx
│   ├── LibraryPage.tsx
│   └── *.module.css
│
├── services/            # API & utility services
│   ├── deezer.service.ts
│   ├── storage.service.ts
│   ├── apiCache.service.ts
│   └── lyrics.service.ts
│
├── store/               # Redux store (future)
│   └── slices/
│
├── styles/              # Global styles
│   ├── index.css
│   └── theme-light.css
│
├── App.tsx              # Root component
└── main.tsx             # Entry point
```

---

## 8. Environment Configuration

### 8.1 TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

### 8.2 Vite Configuration

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    minify: 'esbuild'
  }
});
```

---

## 9. Browser Compatibility

### 9.1 Supported Browsers

| Browser | Minimum Version | Notes |
|---------|-----------------|-------|
| Chrome | 90+ | Full support |
| Firefox | 88+ | Full support |
| Safari | 14+ | Full support |
| Edge | 90+ | Full support |
| Opera | 76+ | Full support |

### 9.2 Required Features

| Feature | Browser Support |
|---------|-----------------|
| ES2020 | All modern browsers |
| CSS Grid | All modern browsers |
| CSS Flexbox | All modern browsers |
| Web Audio API | All modern browsers |
| LocalStorage | All modern browsers |
| Fetch API | All modern browsers |
