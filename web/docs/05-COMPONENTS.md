# Component Documentation

## 1. Component Overview

### 1.1 Component Categories

| Category | Components | Purpose |
|----------|------------|---------|
| **Layout** | Layout, Sidebar, Header | App structure |
| **Player** | GlassPlayer, AudioVisualizer | Audio playback |
| **Panels** | QueuePanel, LyricsPanel | Side panels |
| **Modals** | AddToPlaylistModal, KeyboardShortcutsModal | Overlay dialogs |
| **Pages** | HomePage, SearchPage, LibraryPage, etc. | Route views |

---

## 2. Layout Components

### 2.1 Layout.tsx

**Purpose**: Main application layout wrapper containing sidebar, header, content area, and player.

**Props**:
```typescript
interface LayoutProps {
  children: React.ReactNode;
}
```

**State**:
```typescript
const [isSidebarOpen, setIsSidebarOpen] = useState(true);
const [isQueueOpen, setIsQueueOpen] = useState(false);
const [isLyricsOpen, setIsLyricsOpen] = useState(false);
const [isShortcutsOpen, setIsShortcutsOpen] = useState(false);
```

**Methods**:
| Method | Description |
|--------|-------------|
| `toggleSidebar()` | Toggle sidebar visibility |
| `toggleQueue()` | Open/close queue panel |
| `toggleLyrics()` | Open/close lyrics panel |
| `toggleShortcuts()` | Open/close shortcuts modal |

**Structure**:
```
Layout
├── Sidebar (collapsible)
├── Header (with search)
├── Main Content (children/routes)
├── GlassPlayer (fixed bottom)
├── QueuePanel (slide-in right)
├── LyricsPanel (slide-in right)
├── AddToPlaylistModal
└── KeyboardShortcutsModal
```

**Dependencies**:
- `usePlayer` (context)
- `useNavigate` (router)
- `GlassPlayer`, `QueuePanel`, `LyricsPanel` (components)

---

### 2.2 Sidebar Component (within Layout)

**Purpose**: Navigation menu with links to main pages.

**Navigation Items**:
```typescript
const navItems = [
  { icon: Home, label: 'Home', path: '/' },
  { icon: Search, label: 'Search', path: '/search' },
  { icon: Library, label: 'Library', path: '/library' },
  { icon: Flame, label: 'Top Hits', path: '/hits' },
  { icon: Settings, label: 'Settings', path: '/settings' },
];
```

**Features**:
- Collapsible design
- Active route highlighting
- Responsive behavior

---

### 2.3 Header Component (within Layout)

**Purpose**: Top navigation bar with search and action buttons.

**Elements**:
```
Header
├── Menu Toggle Button (mobile)
├── Search Input
├── Like Button (→ Library)
├── User Profile Button (→ Profile)
├── Keyboard Shortcuts Button
└── Queue Button
```

**Event Handlers**:
```typescript
handleSearch(query: string) → navigate to /search?q=query
handleLikeClick() → navigate to /library
handleProfileClick() → navigate to /profile
handleShortcutsClick() → open shortcuts modal
handleQueueClick() → open queue panel
```

---

## 3. Player Components

### 3.1 GlassPlayer.tsx

**Purpose**: Main audio player interface with playback controls, progress bar, and volume.

**Props**: None (uses context)

**Context Dependencies**:
```typescript
const {
  currentTrack,
  isPlaying,
  progress,
  volume,
  shuffle,
  repeat,
  playPause,
  skipNext,
  skipPrevious,
  seek,
  setVolume,
  toggleShuffle,
  toggleRepeat,
} = usePlayer();
```

**UI Sections**:
```
GlassPlayer
├── Track Info
│   ├── Album Art
│   ├── Title
│   └── Artist
├── Playback Controls
│   ├── Shuffle Button
│   ├── Previous Button
│   ├── Play/Pause Button
│   ├── Next Button
│   └── Repeat Button
├── Progress Section
│   ├── Current Time
│   ├── Progress Bar (seekable)
│   └── Duration
├── Volume Control
│   ├── Volume Icon
│   └── Volume Slider
└── Extra Controls
    ├── Like Button
    ├── Add to Playlist
    ├── Lyrics Button
    └── Queue Button
```

**Methods**:
| Method | Description |
|--------|-------------|
| `handleSeek(e)` | Handle progress bar click/drag |
| `handleVolumeChange(e)` | Handle volume slider |
| `formatTime(seconds)` | Format time as mm:ss |

**Styling**: Glass morphism effect with blur backdrop

---

### 3.2 AudioVisualizer.tsx

**Purpose**: Display audio frequency visualization bars.

**Props**:
```typescript
interface AudioVisualizerProps {
  isPlaying: boolean;
}
```

**Context Dependencies**:
```typescript
const { analyserNode } = usePlayer();
```

**Implementation**:
```typescript
// Uses requestAnimationFrame for smooth animation
useEffect(() => {
  if (!analyserNode || !isPlaying) return;
  
  const dataArray = new Uint8Array(analyserNode.frequencyBinCount);
  
  const animate = () => {
    analyserNode.getByteFrequencyData(dataArray);
    // Update bar heights based on frequency data
    animationRef.current = requestAnimationFrame(animate);
  };
  
  animate();
  return () => cancelAnimationFrame(animationRef.current);
}, [analyserNode, isPlaying]);
```

---

## 4. Panel Components

### 4.1 QueuePanel.tsx

**Purpose**: Side panel showing upcoming tracks with drag-and-drop reordering.

**Props**:
```typescript
interface QueuePanelProps {
  isOpen: boolean;
  onClose: () => void;
}
```

**Context Dependencies**:
```typescript
const { queue, currentTrack, playTrack, clearQueue, setQueue } = usePlayer();
```

**Features**:
- Now Playing section
- Draggable track list (Framer Motion Reorder)
- Clear queue functionality
- Play individual track from queue

**Drag and Drop Implementation**:
```typescript
<Reorder.Group
  axis="y"
  values={localQueue}
  onReorder={handleReorder}
>
  {localQueue.map((track) => (
    <Reorder.Item key={track.id} value={track}>
      {/* Track item content */}
    </Reorder.Item>
  ))}
</Reorder.Group>
```

---

### 4.2 LyricsPanel.tsx

**Purpose**: Side panel displaying lyrics for current track.

**Props**:
```typescript
interface LyricsPanelProps {
  isOpen: boolean;
  onClose: () => void;
}
```

**State**:
```typescript
const [lyrics, setLyrics] = useState<string>('');
const [loading, setLoading] = useState(false);
const [error, setError] = useState<string | null>(null);
```

**Lifecycle**:
```typescript
useEffect(() => {
  if (isOpen && currentTrack) {
    fetchLyrics(currentTrack.title, currentTrack.artist);
  }
}, [isOpen, currentTrack]);
```

---

## 5. Modal Components

### 5.1 AddToPlaylistModal.tsx

**Purpose**: Modal for adding tracks to existing or new playlists.

**Props**:
```typescript
interface AddToPlaylistModalProps {
  isOpen: boolean;
  track: Track | null;
  onClose: () => void;
}
```

**State**:
```typescript
const [playlists, setPlaylists] = useState<Playlist[]>([]);
const [isCreatingNew, setIsCreatingNew] = useState(false);
const [newPlaylistName, setNewPlaylistName] = useState('');
const [newPlaylistDescription, setNewPlaylistDescription] = useState('');
```

**Methods**:
| Method | Description |
|--------|-------------|
| `loadPlaylists()` | Fetch playlists from storage |
| `handleAddToPlaylist(id)` | Add track to existing playlist |
| `handleCreateAndAdd()` | Create new playlist and add track |

---

### 5.2 KeyboardShortcutsModal.tsx

**Purpose**: Display all available keyboard shortcuts.

**Props**:
```typescript
interface KeyboardShortcutsModalProps {
  isOpen: boolean;
  onClose: () => void;
}
```

**Shortcut Categories**:
- Playback Controls (Space, Arrow keys, M)
- Player Features (S, R, L, Q)
- Navigation (/, Escape, ?)

---

## 6. Page Components

### 6.1 HomePage.tsx

**Purpose**: Landing page with featured content.

**Sections**:
```
HomePage
├── Welcome Banner
├── Continue Listening (recently played)
├── Trending Albums
├── Popular Artists
└── Made For You (recommendations)
```

**API Calls**:
```typescript
useEffect(() => {
  fetchTrendingAlbums();
  fetchPopularArtists();
  loadRecentlyPlayed();
}, []);
```

---

### 6.2 SearchPage.tsx

**Purpose**: Search interface for tracks, albums, and artists.

**State**:
```typescript
const [query, setQuery] = useState('');
const [activeTab, setActiveTab] = useState<'tracks' | 'albums' | 'artists'>('tracks');
const [results, setResults] = useState({
  tracks: [],
  albums: [],
  artists: []
});
const [loading, setLoading] = useState(false);
```

**Search Logic**:
```typescript
const handleSearch = async (searchQuery: string) => {
  if (!searchQuery.trim()) return;
  
  setLoading(true);
  const [tracks, albums, artists] = await Promise.all([
    deezerService.search(searchQuery, 'track'),
    deezerService.search(searchQuery, 'album'),
    deezerService.search(searchQuery, 'artist')
  ]);
  
  setResults({ tracks, albums, artists });
  setLoading(false);
};
```

---

### 6.3 LibraryPage.tsx

**Purpose**: User's music library with liked songs, playlists, and history.

**Tabs**:
```typescript
const tabs = [
  { id: 'liked', label: 'Liked Songs', icon: Heart },
  { id: 'playlists', label: 'Playlists', icon: ListMusic },
  { id: 'recent', label: 'Recently Played', icon: Clock },
];
```

**Features**:
- Tab navigation
- Create/delete playlists
- Sort options
- Track actions (play, unlike, remove)

---

### 6.4 SettingsPage.tsx

**Purpose**: Application settings and preferences.

**Setting Categories**:
```
Settings
├── Playback
│   ├── AutoPlay
│   ├── Audio Quality
│   ├── Crossfade
│   ├── Gapless Playback
│   ├── Volume Normalization
│   └── Equalizer Preset
├── Notifications
│   └── Push Notifications
├── Privacy
│   ├── Private Profile
│   └── Explicit Content
├── Storage
│   ├── Cache Size Display
│   ├── Clear API Cache
│   └── Clear All Data
└── About
    ├── Version
    └── Reset Settings
```

---

### 6.5 AlbumDetailPage.tsx

**Purpose**: Display album details and track list.

**URL**: `/album/:id`

**Data Fetching**:
```typescript
useEffect(() => {
  const fetchAlbum = async () => {
    const albumData = await deezerService.getAlbum(id);
    setAlbum(albumData);
  };
  fetchAlbum();
}, [id]);
```

**Features**:
- Album art and info
- Track listing with duration
- Play all / shuffle options
- Add to library

---

### 6.6 ArtistDetailPage.tsx

**Purpose**: Display artist details, top tracks, and albums.

**URL**: `/artist/:id`

**Sections**:
- Artist header with image
- Top tracks
- Discography (albums)
- Related artists

---

### 6.7 HitsPage.tsx

**Purpose**: Display global chart/trending tracks.

**Data Source**: Deezer Charts API

**Features**:
- Numbered track list
- Play entire chart
- Individual track actions

---

### 6.8 ProfilePage.tsx

**Purpose**: User profile view (local stats).

**Stats Displayed**:
- Total liked songs
- Total playlists
- Recently played count
- Listening history

---

## 7. Component Lifecycle Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    COMPONENT LIFECYCLE                       │
│                                                              │
│  1. MOUNT                                                    │
│     ├── constructor/initial state                           │
│     ├── render                                              │
│     └── useEffect (componentDidMount)                       │
│         └── API calls, subscriptions                        │
│                                                              │
│  2. UPDATE                                                   │
│     ├── props/state change                                  │
│     ├── render                                              │
│     └── useEffect (componentDidUpdate)                      │
│         └── Handle changes                                  │
│                                                              │
│  3. UNMOUNT                                                  │
│     └── useEffect cleanup                                   │
│         └── Cancel subscriptions, clear timers              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. Component Best Practices

### 8.1 Naming Conventions

```typescript
// Component files: PascalCase
GlassPlayer.tsx
QueuePanel.tsx

// Style files: PascalCase.module.css
GlassPlayer.module.css
QueuePanel.module.css

// Hooks: camelCase with 'use' prefix
useKeyboardShortcuts.ts
useLocalStorage.ts

// Event handlers: handle + Action
handlePlayPause()
handleSeek()
handleVolumeChange()
```

### 8.2 State Management Rules

1. **Local state**: UI-only state (modals, forms)
2. **Context**: Shared across many components (player, theme)
3. **Props**: Parent-to-child data passing
4. **Callbacks**: Child-to-parent communication

### 8.3 Performance Guidelines

```typescript
// Use useCallback for handlers passed to children
const handleClick = useCallback(() => {
  // handler logic
}, [dependencies]);

// Use useMemo for expensive computations
const sortedTracks = useMemo(() => {
  return [...tracks].sort(sortFunction);
}, [tracks, sortFunction]);

// Use React.memo for pure components
export default React.memo(TrackItem);
```
