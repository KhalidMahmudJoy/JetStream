# API Reference

## 1. Services Overview

| Service | File | Purpose |
|---------|------|---------|
| **DeezerService** | `deezer.service.ts` | Music data API |
| **StorageService** | `storage.service.ts` | Local storage operations |
| **MusicService** | `music.service.ts` | Music utilities |
| **APICacheService** | `apiCache.service.ts` | API response caching |
| **YouTubeService** | `youtube.service.ts` | YouTube integration |

---

## 2. DeezerService

### 2.1 Configuration

```typescript
const CORS_PROXY = 'https://corsproxy.io/?';
const DEEZER_API = 'https://api.deezer.com';
```

### 2.2 Methods

#### `search(query: string, type?: string): Promise<any>`

Search for tracks, albums, or artists.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | Search query |
| type | string | No | 'track', 'album', 'artist' (default: 'track') |

**Returns**: Promise with search results array

**Example**:
```typescript
const tracks = await deezerService.search('Imagine Dragons', 'track');
const albums = await deezerService.search('Evolve', 'album');
```

---

#### `getAlbum(albumId: string): Promise<Album>`

Get album details with track list.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| albumId | string | Yes | Deezer album ID |

**Returns**:
```typescript
interface Album {
  id: string;
  title: string;
  cover: string;
  cover_medium: string;
  cover_big: string;
  artist: Artist;
  tracks: { data: Track[] };
  release_date: string;
  nb_tracks: number;
}
```

---

#### `getArtist(artistId: string): Promise<Artist>`

Get artist details.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| artistId | string | Yes | Deezer artist ID |

**Returns**:
```typescript
interface Artist {
  id: string;
  name: string;
  picture: string;
  picture_medium: string;
  picture_big: string;
  nb_album: number;
  nb_fan: number;
}
```

---

#### `getArtistTopTracks(artistId: string): Promise<Track[]>`

Get artist's top tracks.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| artistId | string | Yes | Deezer artist ID |

**Returns**: Array of track objects

---

#### `getArtistAlbums(artistId: string): Promise<Album[]>`

Get artist's albums/discography.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| artistId | string | Yes | Deezer artist ID |

**Returns**: Array of album objects

---

#### `getChart(): Promise<ChartData>`

Get current music charts.

**Returns**:
```typescript
interface ChartData {
  tracks: { data: Track[] };
  albums: { data: Album[] };
  artists: { data: Artist[] };
}
```

---

#### `getTrack(trackId: string): Promise<Track>`

Get individual track details.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| trackId | string | Yes | Deezer track ID |

**Returns**:
```typescript
interface Track {
  id: string;
  title: string;
  duration: number;
  preview: string;
  artist: { id: string; name: string };
  album: { id: string; title: string; cover_medium: string };
}
```

---

#### `getRelatedArtists(artistId: string): Promise<Artist[]>`

Get similar artists.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| artistId | string | Yes | Deezer artist ID |

**Returns**: Array of related artist objects

---

## 3. StorageService

### 3.1 Storage Keys

```typescript
const STORAGE_KEYS = {
  LIKED_SONGS: 'jetstream_liked_songs',
  PLAYLISTS: 'jetstream_playlists',
  RECENTLY_PLAYED: 'jetstream_recently_played',
  SETTINGS: 'jetstream_settings',
  QUEUE: 'jetstream_queue',
};
```

### 3.2 Methods

#### `getLikedSongs(): Track[]`

Get all liked songs from storage.

**Returns**: Array of liked track objects

---

#### `addLikedSong(track: Track): void`

Add a track to liked songs.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| track | Track | Yes | Track to like |

---

#### `removeLikedSong(trackId: string): void`

Remove a track from liked songs.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| trackId | string | Yes | ID of track to unlike |

---

#### `isLiked(trackId: string): boolean`

Check if a track is liked.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| trackId | string | Yes | Track ID to check |

**Returns**: Boolean indicating like status

---

#### `getPlaylists(): Playlist[]`

Get all user playlists.

**Returns**:
```typescript
interface Playlist {
  id: string;
  name: string;
  description: string;
  tracks: Track[];
  createdAt: string;
  updatedAt: string;
  coverImage?: string;
}
```

---

#### `createPlaylist(name: string, description?: string): Playlist`

Create a new playlist.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| name | string | Yes | Playlist name |
| description | string | No | Playlist description |

**Returns**: Newly created playlist object

---

#### `deletePlaylist(playlistId: string): void`

Delete a playlist.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| playlistId | string | Yes | Playlist ID to delete |

---

#### `addTrackToPlaylist(playlistId: string, track: Track): void`

Add a track to a playlist.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| playlistId | string | Yes | Target playlist ID |
| track | Track | Yes | Track to add |

---

#### `removeTrackFromPlaylist(playlistId: string, trackId: string): void`

Remove a track from a playlist.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| playlistId | string | Yes | Playlist ID |
| trackId | string | Yes | Track ID to remove |

---

#### `getRecentlyPlayed(): Track[]`

Get recently played tracks.

**Returns**: Array of recently played tracks (max 50)

---

#### `addToRecentlyPlayed(track: Track): void`

Add track to recently played history.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| track | Track | Yes | Track to add |

---

#### `getSettings(): Settings`

Get application settings.

**Returns**:
```typescript
interface Settings {
  playback: {
    autoPlay: boolean;
    quality: 'low' | 'normal' | 'high' | 'very_high';
    crossfade: number;
    gapless: boolean;
    volumeNormalization: boolean;
    equalizerPreset: string;
  };
  notifications: {
    push: boolean;
  };
  privacy: {
    privateProfile: boolean;
    explicitContent: boolean;
  };
}
```

---

#### `saveSettings(settings: Settings): void`

Save application settings.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| settings | Settings | Yes | Settings object |

---

## 4. APICacheService

### 4.1 Purpose

Caches API responses to reduce network requests and improve performance.

### 4.2 Methods

#### `get(key: string): any | null`

Get cached data.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| key | string | Yes | Cache key |

**Returns**: Cached data or null if expired/missing

---

#### `set(key: string, data: any, ttl?: number): void`

Set cache data.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| key | string | Yes | Cache key |
| data | any | Yes | Data to cache |
| ttl | number | No | Time-to-live in ms (default: 5 min) |

---

#### `clear(): void`

Clear all cached data.

---

#### `getSize(): number`

Get cache size in bytes.

**Returns**: Approximate cache size

---

## 5. PlayerContext API

### 5.1 Context Interface

```typescript
interface PlayerContextType {
  // State
  currentTrack: Track | null;
  isPlaying: boolean;
  progress: number;
  duration: number;
  volume: number;
  shuffle: boolean;
  repeat: 'none' | 'all' | 'one';
  queue: Track[];
  analyserNode: AnalyserNode | null;
  
  // Actions
  playTrack: (track: Track) => void;
  playPause: () => void;
  skipNext: () => void;
  skipPrevious: () => void;
  seek: (time: number) => void;
  setVolume: (volume: number) => void;
  toggleShuffle: () => void;
  toggleRepeat: () => void;
  addToQueue: (track: Track) => void;
  removeFromQueue: (trackId: string) => void;
  clearQueue: () => void;
  setQueue: (tracks: Track[]) => void;
  setEqualizer: (band: number, gain: number) => void;
  setEqualizerPreset: (preset: string) => void;
}
```

### 5.2 Usage

```typescript
import { usePlayer } from '../contexts/PlayerContext';

function MyComponent() {
  const {
    currentTrack,
    isPlaying,
    playPause,
    skipNext,
    // ... other methods
  } = usePlayer();
  
  return (
    <button onClick={playPause}>
      {isPlaying ? 'Pause' : 'Play'}
    </button>
  );
}
```

---

## 6. Custom Hooks

### 6.1 useKeyboardShortcuts

```typescript
interface Shortcut {
  key: string;
  ctrl?: boolean;
  shift?: boolean;
  alt?: boolean;
  action: () => void;
}

function useKeyboardShortcuts(shortcuts: Shortcut[]): void;
```

**Usage**:
```typescript
useKeyboardShortcuts([
  { key: 'Space', action: playPause },
  { key: 'ArrowRight', action: skipNext },
  { key: 'm', action: toggleMute },
]);
```

---

### 6.2 useLocalStorage

```typescript
function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T) => void];
```

**Usage**:
```typescript
const [settings, setSettings] = useLocalStorage('settings', defaultSettings);
```

---

### 6.3 useDebounce

```typescript
function useDebounce<T>(value: T, delay: number): T;
```

**Usage**:
```typescript
const [query, setQuery] = useState('');
const debouncedQuery = useDebounce(query, 300);

useEffect(() => {
  if (debouncedQuery) {
    performSearch(debouncedQuery);
  }
}, [debouncedQuery]);
```

---

## 7. Error Handling

### 7.1 API Error Response

```typescript
interface APIError {
  code: number;
  message: string;
  type: string;
}
```

### 7.2 Error Handling Pattern

```typescript
try {
  const data = await deezerService.search(query);
  setResults(data);
} catch (error) {
  if (error instanceof Error) {
    setError(error.message);
  } else {
    setError('An unexpected error occurred');
  }
} finally {
  setLoading(false);
}
```

---

## 8. TypeScript Interfaces

### 8.1 Track Interface

```typescript
interface Track {
  id: string;
  title: string;
  artist: string;
  artistId?: string;
  albumTitle: string;
  albumId?: string;
  coverImage: string;
  duration: number;
  audioUrl: string;
  explicit?: boolean;
}
```

### 8.2 Album Interface

```typescript
interface Album {
  id: string;
  title: string;
  artist: string;
  artistId: string;
  coverImage: string;
  releaseDate: string;
  trackCount: number;
  tracks?: Track[];
}
```

### 8.3 Artist Interface

```typescript
interface Artist {
  id: string;
  name: string;
  image: string;
  fanCount?: number;
  albumCount?: number;
}
```

### 8.4 Playlist Interface

```typescript
interface Playlist {
  id: string;
  name: string;
  description: string;
  tracks: Track[];
  coverImage?: string;
  createdAt: string;
  updatedAt: string;
}
```
