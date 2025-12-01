# Database & Storage Schema

## 1. Storage Overview

JetStream uses **LocalStorage** for client-side data persistence. No server-side database is required for the web application.

### 1.1 Storage Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    BROWSER STORAGE                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                   LocalStorage                        │   │
│  │                  (5-10 MB limit)                     │   │
│  │                                                      │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Liked Songs │  │  Playlists  │  │  Settings   │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  │                                                      │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Recent    │  │    Queue    │  │  API Cache  │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  │                                                      │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Storage Keys

| Key | Description | Data Type |
|-----|-------------|-----------|
| `jetstream_liked_songs` | User's liked tracks | Track[] |
| `jetstream_playlists` | User-created playlists | Playlist[] |
| `jetstream_recently_played` | Play history | Track[] |
| `jetstream_settings` | App preferences | Settings |
| `jetstream_queue` | Current play queue | Track[] |
| `jetstream_api_cache` | Cached API responses | CacheEntry[] |

---

## 3. Data Schemas

### 3.1 Track Schema

```typescript
interface Track {
  // Primary Key
  id: string;              // Deezer track ID
  
  // Track Information
  title: string;           // Track title
  duration: number;        // Duration in seconds
  explicit: boolean;       // Explicit content flag
  
  // Artist Information
  artist: string;          // Artist name
  artistId: string;        // Deezer artist ID
  
  // Album Information
  albumTitle: string;      // Album name
  albumId: string;         // Deezer album ID
  coverImage: string;      // Album cover URL
  
  // Playback
  audioUrl: string;        // Preview URL (30 seconds)
  
  // Timestamps
  addedAt?: string;        // ISO date when added to library
  lastPlayedAt?: string;   // ISO date of last play
}
```

**Storage Size**: ~500 bytes per track

**Example**:
```json
{
  "id": "3135553",
  "title": "Harder Better Faster Stronger",
  "duration": 225,
  "explicit": false,
  "artist": "Daft Punk",
  "artistId": "27",
  "albumTitle": "Discovery",
  "albumId": "302127",
  "coverImage": "https://api.deezer.com/album/302127/image",
  "audioUrl": "https://cdns-preview-d.dzcdn.net/..."
}
```

---

### 3.2 Playlist Schema

```typescript
interface Playlist {
  // Primary Key
  id: string;              // Generated UUID
  
  // Playlist Information
  name: string;            // Playlist name
  description: string;     // User description
  
  // Tracks
  tracks: Track[];         // Array of tracks
  
  // Metadata
  coverImage?: string;     // Custom cover or first track's cover
  trackCount: number;      // Number of tracks
  
  // Timestamps
  createdAt: string;       // ISO date created
  updatedAt: string;       // ISO date last modified
}
```

**Storage Size**: ~500 bytes + (500 bytes × track count)

**Example**:
```json
{
  "id": "playlist_1699123456789",
  "name": "My Favorites",
  "description": "Best songs of 2024",
  "tracks": [
    { /* Track object */ },
    { /* Track object */ }
  ],
  "coverImage": null,
  "trackCount": 2,
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-20T15:45:00.000Z"
}
```

---

### 3.3 Settings Schema

```typescript
interface Settings {
  // Playback Settings
  playback: {
    autoPlay: boolean;           // Auto-play next track
    quality: AudioQuality;       // Audio quality level
    crossfade: number;           // Crossfade duration (0-12 seconds)
    gapless: boolean;            // Gapless playback
    volumeNormalization: boolean; // Normalize volume levels
    equalizerPreset: string;     // EQ preset name
  };
  
  // Notification Settings
  notifications: {
    push: boolean;               // Enable push notifications
  };
  
  // Privacy Settings
  privacy: {
    privateProfile: boolean;     // Hide profile from others
    explicitContent: boolean;    // Allow explicit content
  };
  
  // Audio Settings (persisted separately)
  volume: number;                // Last volume level (0-1)
}

type AudioQuality = 'low' | 'normal' | 'high' | 'very_high';
```

**Default Settings**:
```json
{
  "playback": {
    "autoPlay": true,
    "quality": "high",
    "crossfade": 0,
    "gapless": true,
    "volumeNormalization": false,
    "equalizerPreset": "flat"
  },
  "notifications": {
    "push": true
  },
  "privacy": {
    "privateProfile": false,
    "explicitContent": true
  },
  "volume": 0.7
}
```

---

### 3.4 API Cache Schema

```typescript
interface CacheEntry {
  key: string;           // Cache key (URL or identifier)
  data: any;             // Cached response data
  timestamp: number;     // Unix timestamp when cached
  ttl: number;           // Time-to-live in milliseconds
}

interface APICache {
  entries: CacheEntry[];
  maxSize: number;       // Max entries before cleanup
}
```

**Cache TTL Values**:
| Data Type | TTL | Reason |
|-----------|-----|--------|
| Search results | 5 minutes | Changes frequently |
| Album details | 30 minutes | Relatively stable |
| Artist details | 30 minutes | Relatively stable |
| Chart data | 15 minutes | Updates regularly |

---

## 4. Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    ENTITY RELATIONSHIPS                      │
└─────────────────────────────────────────────────────────────┘

  ┌──────────┐         ┌──────────┐         ┌──────────┐
  │  Artist  │ 1    n  │   Album  │ 1    n  │  Track   │
  └────┬─────┘─────────└────┬─────┘─────────└────┬─────┘
       │                    │                    │
       │                    │                    │
       └────────────────────┴────────────────────┤
                                                 │
                    ┌────────────────────────────┤
                    │                            │
              ┌─────┴─────┐              ┌───────┴───────┐
              │  Playlist │ n          1 │ Liked Songs   │
              │  (user)   │──────────────│   (user)      │
              └───────────┘              └───────────────┘
                    │
                    │ n
              ┌─────┴─────┐
              │  Track    │
              │ Reference │
              └───────────┘
```

---

## 5. Data Operations

### 5.1 CRUD Operations

#### Create

```typescript
// Create Playlist
const createPlaylist = (name: string, description: string): Playlist => {
  const playlist: Playlist = {
    id: `playlist_${Date.now()}`,
    name,
    description,
    tracks: [],
    trackCount: 0,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  
  const playlists = getPlaylists();
  playlists.push(playlist);
  localStorage.setItem('jetstream_playlists', JSON.stringify(playlists));
  
  return playlist;
};
```

#### Read

```typescript
// Read Liked Songs
const getLikedSongs = (): Track[] => {
  const data = localStorage.getItem('jetstream_liked_songs');
  return data ? JSON.parse(data) : [];
};

// Read with Pagination
const getLikedSongsPaginated = (page: number, pageSize: number): Track[] => {
  const songs = getLikedSongs();
  const start = (page - 1) * pageSize;
  return songs.slice(start, start + pageSize);
};
```

#### Update

```typescript
// Update Playlist
const updatePlaylist = (playlistId: string, updates: Partial<Playlist>): void => {
  const playlists = getPlaylists();
  const index = playlists.findIndex(p => p.id === playlistId);
  
  if (index !== -1) {
    playlists[index] = {
      ...playlists[index],
      ...updates,
      updatedAt: new Date().toISOString()
    };
    localStorage.setItem('jetstream_playlists', JSON.stringify(playlists));
  }
};
```

#### Delete

```typescript
// Delete Playlist
const deletePlaylist = (playlistId: string): void => {
  const playlists = getPlaylists().filter(p => p.id !== playlistId);
  localStorage.setItem('jetstream_playlists', JSON.stringify(playlists));
};
```

---

### 5.2 Storage Queries

```typescript
// Search within liked songs
const searchLikedSongs = (query: string): Track[] => {
  const songs = getLikedSongs();
  const lowerQuery = query.toLowerCase();
  
  return songs.filter(track => 
    track.title.toLowerCase().includes(lowerQuery) ||
    track.artist.toLowerCase().includes(lowerQuery)
  );
};

// Sort playlists by date
const sortPlaylistsByDate = (order: 'asc' | 'desc'): Playlist[] => {
  const playlists = getPlaylists();
  return playlists.sort((a, b) => {
    const dateA = new Date(a.createdAt).getTime();
    const dateB = new Date(b.createdAt).getTime();
    return order === 'asc' ? dateA - dateB : dateB - dateA;
  });
};
```

---

## 6. Storage Limits & Optimization

### 6.1 Browser Limits

| Browser | LocalStorage Limit |
|---------|-------------------|
| Chrome | 5 MB |
| Firefox | 5 MB |
| Safari | 5 MB |
| Edge | 5 MB |

### 6.2 Capacity Estimates

| Data Type | Est. Size | Max Count |
|-----------|-----------|-----------|
| Liked Songs | 500 bytes/track | ~10,000 tracks |
| Playlists | Variable | ~100 playlists |
| Recently Played | 500 bytes/track | 50 tracks (capped) |
| Settings | ~1 KB | 1 |
| API Cache | ~2 KB/entry | ~100 entries |

### 6.3 Optimization Strategies

```typescript
// Limit recently played history
const MAX_RECENT_TRACKS = 50;

const addToRecentlyPlayed = (track: Track): void => {
  let recent = getRecentlyPlayed();
  
  // Remove if already exists
  recent = recent.filter(t => t.id !== track.id);
  
  // Add to front
  recent.unshift({
    ...track,
    lastPlayedAt: new Date().toISOString()
  });
  
  // Trim to max size
  if (recent.length > MAX_RECENT_TRACKS) {
    recent = recent.slice(0, MAX_RECENT_TRACKS);
  }
  
  localStorage.setItem('jetstream_recently_played', JSON.stringify(recent));
};
```

---

## 7. Data Integrity

### 7.1 Validation Functions

```typescript
// Validate Track object
const isValidTrack = (track: any): track is Track => {
  return (
    typeof track?.id === 'string' &&
    typeof track?.title === 'string' &&
    typeof track?.artist === 'string' &&
    typeof track?.audioUrl === 'string'
  );
};

// Validate Playlist object
const isValidPlaylist = (playlist: any): playlist is Playlist => {
  return (
    typeof playlist?.id === 'string' &&
    typeof playlist?.name === 'string' &&
    Array.isArray(playlist?.tracks)
  );
};
```

### 7.2 Data Migration

```typescript
// Version migration for settings changes
const SETTINGS_VERSION = 2;

const migrateSettings = (oldSettings: any): Settings => {
  if (!oldSettings.version || oldSettings.version < 2) {
    // Migrate from v1 to v2
    return {
      ...DEFAULT_SETTINGS,
      playback: {
        ...DEFAULT_SETTINGS.playback,
        autoPlay: oldSettings.autoPlay ?? true,
      }
    };
  }
  return oldSettings;
};
```

---

## 8. Backup & Restore

### 8.1 Export Data

```typescript
const exportUserData = (): string => {
  const data = {
    likedSongs: getLikedSongs(),
    playlists: getPlaylists(),
    settings: getSettings(),
    exportedAt: new Date().toISOString()
  };
  
  return JSON.stringify(data, null, 2);
};
```

### 8.2 Import Data

```typescript
const importUserData = (jsonData: string): boolean => {
  try {
    const data = JSON.parse(jsonData);
    
    if (data.likedSongs) {
      localStorage.setItem('jetstream_liked_songs', JSON.stringify(data.likedSongs));
    }
    if (data.playlists) {
      localStorage.setItem('jetstream_playlists', JSON.stringify(data.playlists));
    }
    if (data.settings) {
      localStorage.setItem('jetstream_settings', JSON.stringify(data.settings));
    }
    
    return true;
  } catch (error) {
    console.error('Import failed:', error);
    return false;
  }
};
```
