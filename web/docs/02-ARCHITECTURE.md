# System Architecture

## 1. High-Level Architecture

### 1.1 Architecture Pattern
JetStream follows a **Component-Based Architecture** with **Flux Pattern** for state management.

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │   Pages     │  │ Components  │  │   Modals    │  │   Panels    │ │
│  │  HomePage   │  │  Layout     │  │  Playlist   │  │   Queue     │ │
│  │  SearchPage │  │  GlassPlayer│  │  Shortcuts  │  │   Lyrics    │ │
│  │  LibraryPage│  │  TrackList  │  │             │  │             │ │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘ │
│         │                │                │                │        │
│         └────────────────┴────────────────┴────────────────┘        │
│                                   │                                  │
├───────────────────────────────────┼──────────────────────────────────┤
│                        STATE MANAGEMENT LAYER                        │
│  ┌─────────────────────┐  ┌─────────────────────┐                   │
│  │   React Context     │  │    Redux Store      │                   │
│  │  ├─ PlayerContext   │  │  ├─ playerSlice     │                   │
│  │  └─ ThemeContext    │  │  └─ (future use)    │                   │
│  └──────────┬──────────┘  └──────────┬──────────┘                   │
│             │                        │                               │
│             └────────────────────────┘                               │
│                          │                                           │
├──────────────────────────┼───────────────────────────────────────────┤
│                     SERVICE LAYER                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │  Deezer     │  │  Storage    │  │  API Cache  │  │  Lyrics     │ │
│  │  Service    │  │  Service    │  │  Service    │  │  Service    │ │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘ │
│         │                │                │                │        │
├─────────┼────────────────┼────────────────┼────────────────┼────────┤
│         │           DATA LAYER            │                │        │
│         │    ┌─────────────────────┐      │                │        │
│         │    │   Local Storage     │      │                │        │
│         │    │  ├─ Liked Songs     │      │                │        │
│         │    │  ├─ Playlists       │      │                │        │
│         │    │  ├─ Recently Played │      │                │        │
│         │    │  └─ Settings        │      │                │        │
│         │    └─────────────────────┘      │                │        │
│         │                                 │                │        │
└─────────┼─────────────────────────────────┼────────────────┼────────┘
          │                                 │                │
          ▼                                 ▼                ▼
┌─────────────────┐              ┌─────────────────┐  ┌─────────────┐
│   Deezer API    │              │   CORS Proxy    │  │ Lyrics APIs │
│  api.deezer.com │              │ corsproxy.io    │  │ (multiple)  │
└─────────────────┘              └─────────────────┘  └─────────────┘
```

---

## 2. Component Architecture

### 2.1 Component Hierarchy
```
App
├── ThemeProvider
│   └── PlayerProvider
│       └── BrowserRouter
│           └── Layout
│               ├── Sidebar
│               │   └── Navigation Links
│               ├── Header
│               │   ├── Search Bar
│               │   ├── Action Buttons
│               │   └── User Profile
│               ├── Main Content (Routes)
│               │   ├── HomePage
│               │   ├── SearchPage
│               │   ├── LibraryPage
│               │   ├── SettingsPage
│               │   ├── HitsPage
│               │   ├── AlbumDetailPage
│               │   ├── ArtistDetailPage
│               │   └── ProfilePage
│               ├── GlassPlayer (Fixed Bottom)
│               │   ├── Track Info
│               │   ├── Playback Controls
│               │   ├── Progress Bar
│               │   ├── Volume Control
│               │   └── Extra Controls
│               ├── QueuePanel (Slide-in)
│               ├── LyricsPanel (Slide-in)
│               ├── AddToPlaylistModal
│               └── KeyboardShortcutsModal
```

### 2.2 Component Communication
```
┌────────────────────────────────────────────────────────────┐
│                    Component Communication                  │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  Props (Parent → Child)                                    │
│  ┌─────────┐  props   ┌─────────┐                         │
│  │ Parent  │ ───────► │ Child   │                         │
│  └─────────┘          └─────────┘                         │
│                                                            │
│  Callbacks (Child → Parent)                                │
│  ┌─────────┐ callback ┌─────────┐                         │
│  │ Parent  │ ◄─────── │ Child   │                         │
│  └─────────┘          └─────────┘                         │
│                                                            │
│  Context (Global State)                                    │
│  ┌─────────────────────────────┐                          │
│  │      PlayerContext          │                          │
│  │  ┌───────┐    ┌───────┐    │                          │
│  │  │Comp A │    │Comp B │    │  All components can      │
│  │  └───┬───┘    └───┬───┘    │  access shared state     │
│  │      │            │        │                          │
│  │      └────────────┘        │                          │
│  └─────────────────────────────┘                          │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 3. Data Flow Architecture

### 3.1 Unidirectional Data Flow
```
┌─────────────────────────────────────────────────────────────┐
│                  UNIDIRECTIONAL DATA FLOW                    │
│                                                              │
│    ┌──────────┐      ┌──────────┐      ┌──────────┐        │
│    │  Action  │ ───► │  State   │ ───► │   View   │        │
│    │ (Event)  │      │ (Store)  │      │   (UI)   │        │
│    └──────────┘      └──────────┘      └────┬─────┘        │
│         ▲                                    │              │
│         │                                    │              │
│         └────────────────────────────────────┘              │
│                    User Interaction                         │
│                                                              │
└─────────────────────────────────────────────────────────────┘

Example: Playing a Track
1. User clicks play button (Action)
2. playTrack() is called in PlayerContext (State Update)
3. Audio element source is set, UI updates (View)
4. Progress bar animates, track info displays (View)
```

### 3.2 Audio Data Flow
```
┌─────────────────────────────────────────────────────────────┐
│                    AUDIO PROCESSING PIPELINE                 │
│                                                              │
│  Audio Source                                                │
│  (Deezer Preview URL)                                        │
│         │                                                    │
│         ▼                                                    │
│  ┌─────────────────┐                                        │
│  │  HTMLAudioElement│                                        │
│  │  (audioRef)      │                                        │
│  └────────┬────────┘                                        │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────┐                                        │
│  │  AudioContext   │                                        │
│  │  (Web Audio API)│                                        │
│  └────────┬────────┘                                        │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────┐                                        │
│  │MediaElementSource│                                        │
│  └────────┬────────┘                                        │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────────────────────────────────────┐       │
│  │           10-Band Equalizer                      │       │
│  │  32Hz → 64Hz → 125Hz → 250Hz → 500Hz →          │       │
│  │  1kHz → 2kHz → 4kHz → 8kHz → 16kHz              │       │
│  └────────────────────┬────────────────────────────┘       │
│                       │                                     │
│                       ▼                                     │
│  ┌─────────────────┐                                        │
│  │  AnalyserNode   │ ─────► Visualizer Component           │
│  └────────┬────────┘        (Frequency Data)               │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────┐                                        │
│  │   GainNode      │ ─────► Volume Control                  │
│  └────────┬────────┘                                        │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────┐                                        │
│  │  Destination    │ ─────► Speakers/Headphones             │
│  │  (Output)       │                                        │
│  └─────────────────┘                                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Module Architecture

### 4.1 Module Dependencies
```
┌─────────────────────────────────────────────────────────────┐
│                    MODULE DEPENDENCIES                       │
│                                                              │
│  ┌─────────────┐                                            │
│  │    main     │ Entry Point                                │
│  └──────┬──────┘                                            │
│         │                                                    │
│         ▼                                                    │
│  ┌─────────────┐                                            │
│  │     App     │ Root Component                             │
│  └──────┬──────┘                                            │
│         │                                                    │
│    ┌────┴────┐                                              │
│    │         │                                              │
│    ▼         ▼                                              │
│ ┌──────┐ ┌──────┐                                          │
│ │Theme │ │Player│ Context Providers                         │
│ │Ctx   │ │Ctx   │                                          │
│ └──┬───┘ └──┬───┘                                          │
│    │        │                                               │
│    └────┬───┘                                               │
│         │                                                    │
│         ▼                                                    │
│  ┌─────────────┐                                            │
│  │   Router    │                                            │
│  └──────┬──────┘                                            │
│         │                                                    │
│         ▼                                                    │
│  ┌─────────────┐      ┌─────────────┐                      │
│  │   Layout    │ ───► │   Pages     │                      │
│  └──────┬──────┘      └─────────────┘                      │
│         │                                                    │
│    ┌────┼────┬────┬────┐                                   │
│    ▼    ▼    ▼    ▼    ▼                                   │
│ ┌────┐┌────┐┌────┐┌────┐┌────┐                            │
│ │Side││Head││Play││Queu││Lyri│ Components                   │
│ │bar ││er  ││er  ││e   ││cs  │                             │
│ └────┘└────┘└────┘└────┘└────┘                            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Service Dependencies
```
┌─────────────────────────────────────────────────────────────┐
│                    SERVICE LAYER                             │
│                                                              │
│  ┌─────────────────┐      ┌─────────────────┐              │
│  │  deezerService  │ ───► │  apiCacheService │              │
│  │                 │      │  (caching layer) │              │
│  │  - search()     │      └─────────────────┘              │
│  │  - getChart()   │                                        │
│  │  - getAlbum()   │                                        │
│  │  - getArtist()  │                                        │
│  └─────────────────┘                                        │
│                                                              │
│  ┌─────────────────┐                                        │
│  │ storageService  │ ◄── Used by components directly       │
│  │                 │                                        │
│  │  - likeTrack()  │     Persistence Layer                  │
│  │  - getPlaylists()│    (localStorage)                     │
│  │  - createPlaylist()│                                     │
│  │  - getRecentlyPlayed()│                                  │
│  └─────────────────┘                                        │
│                                                              │
│  ┌─────────────────┐                                        │
│  │  lyricsService  │ ◄── Used by LyricsPanel               │
│  │                 │                                        │
│  │  - fetchLyrics()│     Multiple API fallbacks            │
│  └─────────────────┘                                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Design Patterns Used

### 5.1 Patterns Overview

| Pattern | Usage | Location |
|---------|-------|----------|
| **Singleton** | Service instances | deezerService, storageService |
| **Observer** | State subscriptions | React Context, useEffect |
| **Factory** | Component creation | React.createElement |
| **Provider** | Context providers | PlayerProvider, ThemeProvider |
| **Facade** | API abstraction | deezerService |
| **Strategy** | Equalizer presets | setEqualizerPreset() |
| **Command** | Keyboard shortcuts | useKeyboardShortcuts |

### 5.2 Pattern Examples

#### Singleton Pattern (Services)
```typescript
// deezer.service.ts
class DeezerService {
  private static instance: DeezerService;
  
  private constructor() {}
  
  static getInstance(): DeezerService {
    if (!DeezerService.instance) {
      DeezerService.instance = new DeezerService();
    }
    return DeezerService.instance;
  }
}

export const deezerService = new DeezerService();
```

#### Provider Pattern (Context)
```typescript
// PlayerContext.tsx
export function PlayerProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState(initialState);
  
  const value = {
    ...state,
    playTrack,
    playPause,
    // ... other methods
  };
  
  return (
    <PlayerContext.Provider value={value}>
      {children}
    </PlayerContext.Provider>
  );
}
```

#### Strategy Pattern (Equalizer)
```typescript
// Equalizer presets
const presets = {
  'off': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  'bass-boost': [6, 5, 4, 2, 0, 0, 0, 0, 0, 0],
  'rock': [5, 4, 3, 2, -1, -1, 0, 2, 3, 4],
  // ... more presets
};

const setEqualizerPreset = (preset: string) => {
  const gains = presets[preset] || presets['off'];
  gains.forEach((gain, index) => {
    equalizerNodes[index].gain.value = gain;
  });
};
```

---

## 6. Security Architecture

### 6.1 Security Measures
```
┌─────────────────────────────────────────────────────────────┐
│                    SECURITY MEASURES                         │
│                                                              │
│  1. No Authentication Required                               │
│     └─ No sensitive user data stored                        │
│                                                              │
│  2. Local Storage Only                                       │
│     └─ Data stays on user's device                          │
│     └─ No server-side data exposure                         │
│                                                              │
│  3. CORS Proxy                                               │
│     └─ API requests proxied through corsproxy.io            │
│     └─ No API keys exposed in client code                   │
│                                                              │
│  4. Input Sanitization                                       │
│     └─ Search queries sanitized                             │
│     └─ XSS prevention in displayed content                  │
│                                                              │
│  5. HTTPS Only                                               │
│     └─ All external requests use HTTPS                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. Performance Architecture

### 7.1 Performance Optimizations
```
┌─────────────────────────────────────────────────────────────┐
│                 PERFORMANCE OPTIMIZATIONS                    │
│                                                              │
│  1. Code Splitting                                           │
│     └─ Lazy loading of routes                               │
│     └─ Dynamic imports for heavy components                 │
│                                                              │
│  2. Caching Strategy                                         │
│     └─ API responses cached in localStorage                 │
│     └─ 10-minute cache TTL for API data                     │
│     └─ Image preloading for albums                          │
│                                                              │
│  3. Memoization                                              │
│     └─ useCallback for event handlers                       │
│     └─ useMemo for expensive computations                   │
│     └─ React.memo for pure components                       │
│                                                              │
│  4. Virtual Scrolling                                        │
│     └─ Large lists rendered virtually                       │
│                                                              │
│  5. Asset Optimization                                       │
│     └─ Vite bundling and minification                       │
│     └─ Tree shaking for unused code                         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```
