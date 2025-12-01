# Use Cases Documentation

## 1. Use Case Overview

### 1.1 Actor Definitions

| Actor | Description |
|-------|-------------|
| **User** | Primary end-user of the application |
| **System** | JetStream application |
| **Deezer API** | External music data provider |
| **Browser** | Web browser environment |

### 1.2 Use Case Categories

```
┌─────────────────────────────────────────────────────────────┐
│                    USE CASE CATEGORIES                       │
├─────────────────────────────────────────────────────────────┤
│  1. Music Playback      │  UC-001 to UC-010                 │
│  2. Search & Discovery  │  UC-011 to UC-020                 │
│  3. Library Management  │  UC-021 to UC-030                 │
│  4. Playlist Operations │  UC-031 to UC-040                 │
│  5. Settings & Config   │  UC-041 to UC-050                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Music Playback Use Cases

### UC-001: Play a Track

**Title**: Play a Track

**Actors**: User, System

**Preconditions**:
- User is on any page with playable content
- Audio system is initialized

**Main Flow**:
1. User clicks play button on a track
2. System loads track metadata
3. System fetches audio URL from Deezer
4. System initializes AudioContext (if not already)
5. System plays audio through Web Audio API
6. System updates player UI with track info
7. System adds track to Recently Played

**Alternative Flows**:
- 3a. Audio URL unavailable → Display error message
- 4a. AudioContext suspended → Resume on user interaction

**Postconditions**:
- Track is playing
- Player UI shows current track info
- Progress bar animates

```
┌────────┐          ┌──────────┐          ┌───────────┐
│  User  │          │  System  │          │ Deezer API│
└───┬────┘          └────┬─────┘          └─────┬─────┘
    │                    │                      │
    │ Click Play Button  │                      │
    │───────────────────>│                      │
    │                    │                      │
    │                    │ Fetch Audio URL      │
    │                    │─────────────────────>│
    │                    │                      │
    │                    │<─────────────────────│
    │                    │   Audio Stream URL   │
    │                    │                      │
    │                    │ Play Audio           │
    │                    │─────────┐            │
    │                    │         │            │
    │                    │<────────┘            │
    │ Update UI          │                      │
    │<───────────────────│                      │
    │                    │                      │
```

---

### UC-002: Pause/Resume Playback

**Title**: Pause and Resume Playback

**Actors**: User, System

**Preconditions**:
- A track is currently loaded

**Main Flow**:
1. User clicks pause button
2. System pauses audio playback
3. System updates play/pause button icon
4. User clicks play button
5. System resumes audio from paused position
6. System updates button icon

**Keyboard Shortcut**: `Space`

---

### UC-003: Skip to Next Track

**Title**: Skip to Next Track

**Actors**: User, System

**Preconditions**:
- Queue has more than one track

**Main Flow**:
1. User clicks next button
2. System checks queue for next track
3. System stops current track
4. System plays next track
5. System updates Now Playing info

**Alternative Flows**:
- 2a. Shuffle enabled → Pick random track from queue
- 2b. No more tracks → Stop playback (or repeat if enabled)

**Keyboard Shortcut**: `→` (Right Arrow)

---

### UC-004: Skip to Previous Track

**Title**: Skip to Previous Track

**Actors**: User, System

**Preconditions**:
- A track is playing or was playing

**Main Flow**:
1. User clicks previous button
2. System checks current playback position
3. If > 3 seconds: Restart current track
4. If < 3 seconds: Play previous track in queue
5. System updates Now Playing info

**Keyboard Shortcut**: `←` (Left Arrow)

---

### UC-005: Seek Within Track

**Title**: Seek to Position

**Actors**: User, System

**Preconditions**:
- A track is loaded

**Main Flow**:
1. User clicks/drags progress bar
2. System calculates target time
3. System seeks audio to target position
4. System updates progress display

---

### UC-006: Adjust Volume

**Title**: Adjust Volume Level

**Actors**: User, System

**Main Flow**:
1. User adjusts volume slider
2. System updates GainNode value
3. System stores volume preference
4. Volume icon updates based on level

**Keyboard Shortcuts**:
- `↑` (Up Arrow): Increase volume
- `↓` (Down Arrow): Decrease volume
- `M`: Mute/Unmute

---

### UC-007: Toggle Shuffle

**Title**: Enable/Disable Shuffle

**Actors**: User, System

**Main Flow**:
1. User clicks shuffle button
2. System toggles shuffle state
3. If enabled: Queue order randomized for selection
4. Button visual indicates state

**Keyboard Shortcut**: `S`

---

### UC-008: Toggle Repeat Mode

**Title**: Change Repeat Mode

**Actors**: User, System

**Repeat Modes**:
```
None → All → One → None
```

**Main Flow**:
1. User clicks repeat button
2. System cycles to next repeat mode
3. Button icon updates to show mode
4. Playback behavior changes accordingly

**Keyboard Shortcut**: `R`

---

## 3. Search & Discovery Use Cases

### UC-011: Search for Music

**Title**: Search for Tracks/Albums/Artists

**Actors**: User, System, Deezer API

**Preconditions**:
- User is on any page with search access

**Main Flow**:
1. User enters search query
2. System waits for debounce (300ms)
3. System sends search request to Deezer API
4. System receives and caches results
5. System displays results by category (Tracks/Albums/Artists)
6. User can browse and interact with results

**Sequence Diagram**:
```
User         System        Cache        Deezer API
 │              │             │              │
 │ Enter Query  │             │              │
 │─────────────>│             │              │
 │              │             │              │
 │              │ Check Cache │              │
 │              │────────────>│              │
 │              │             │              │
 │              │ Cache Miss  │              │
 │              │<────────────│              │
 │              │             │              │
 │              │ API Request │              │
 │              │─────────────────────────────>│
 │              │             │              │
 │              │             │ Results      │
 │              │<─────────────────────────────│
 │              │             │              │
 │              │ Store Cache │              │
 │              │────────────>│              │
 │              │             │              │
 │ Display      │             │              │
 │<─────────────│             │              │
```

---

### UC-012: Browse Charts

**Title**: View Top Charts

**Actors**: User, System

**Main Flow**:
1. User navigates to Top Hits page
2. System fetches chart data
3. System displays top tracks
4. User can play individual tracks or entire chart

---

### UC-013: Explore Artist

**Title**: View Artist Details

**Actors**: User, System

**Main Flow**:
1. User clicks on artist name/image
2. System navigates to artist page
3. System fetches artist details
4. System displays:
   - Artist info and image
   - Top tracks
   - Albums/Discography
   - Related artists

---

### UC-014: Explore Album

**Title**: View Album Details

**Actors**: User, System

**Main Flow**:
1. User clicks on album
2. System navigates to album page
3. System fetches album details with tracks
4. System displays track listing
5. User can play album or individual tracks

---

## 4. Library Management Use Cases

### UC-021: Like a Track

**Title**: Add Track to Liked Songs

**Actors**: User, System

**Main Flow**:
1. User clicks heart icon on track
2. System adds track to liked songs storage
3. Heart icon fills to indicate liked state
4. Track appears in Library > Liked Songs

**Alternative Flow**:
- 2a. Track already liked → Remove from liked songs

---

### UC-022: View Liked Songs

**Title**: Browse Liked Songs

**Actors**: User, System

**Main Flow**:
1. User navigates to Library page
2. User selects "Liked Songs" tab
3. System loads liked songs from storage
4. System displays list with sort options
5. User can play, unlike, or add to playlist

---

### UC-023: View Recently Played

**Title**: Browse Play History

**Actors**: User, System

**Main Flow**:
1. User navigates to Library page
2. User selects "Recently Played" tab
3. System loads history from storage
4. System displays chronological list
5. User can replay tracks

---

## 5. Playlist Operations Use Cases

### UC-031: Create Playlist

**Title**: Create New Playlist

**Actors**: User, System

**Main Flow**:
1. User clicks "Create Playlist" button
2. System shows create dialog
3. User enters playlist name and description
4. User clicks Create
5. System generates unique ID
6. System saves playlist to storage
7. New playlist appears in Library

**Data Created**:
```typescript
{
  id: "playlist_" + timestamp,
  name: userInput,
  description: userInput,
  tracks: [],
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString()
}
```

---

### UC-032: Add Track to Playlist

**Title**: Add Track to Existing Playlist

**Actors**: User, System

**Main Flow**:
1. User clicks "Add to Playlist" on track
2. System shows playlist selection modal
3. System loads user's playlists
4. User selects target playlist
5. System adds track to playlist
6. System shows success feedback

**Alternative Flow**:
- 3a. No playlists exist → Prompt to create new
- 5a. Track already in playlist → Show duplicate warning

---

### UC-033: Remove Track from Playlist

**Title**: Remove Track from Playlist

**Actors**: User, System

**Main Flow**:
1. User views playlist details
2. User clicks remove button on track
3. System removes track from playlist
4. System updates storage
5. UI refreshes to show updated playlist

---

### UC-034: Delete Playlist

**Title**: Delete Entire Playlist

**Actors**: User, System

**Main Flow**:
1. User clicks delete button on playlist
2. System shows confirmation dialog
3. User confirms deletion
4. System removes playlist from storage
5. Playlist removed from Library view

---

### UC-035: Reorder Queue

**Title**: Drag to Reorder Queue

**Actors**: User, System

**Main Flow**:
1. User opens Queue panel
2. User drags a track to new position
3. System updates local queue state
4. System syncs to global queue
5. Visual order updates in real-time

---

## 6. Use Case Diagram

```
                        ┌─────────────────────────────────────┐
                        │           JetStream System          │
                        └─────────────────────────────────────┘
                                         │
           ┌─────────────────────────────┼─────────────────────────────┐
           │                             │                             │
    ┌──────┴──────┐              ┌───────┴───────┐             ┌───────┴───────┐
    │  Playback   │              │    Search     │             │    Library    │
    └──────┬──────┘              └───────┬───────┘             └───────┬───────┘
           │                             │                             │
    ┌──────┼──────┐              ┌───────┼───────┐             ┌───────┼───────┐
    │      │      │              │       │       │             │       │       │
  Play   Skip   Seek         Search  Browse   Explore        Like  Playlist History
    │      │      │              │    Charts  Artist          │       │       │
    │      │      │              │       │       │             │       │       │
    └──────┼──────┘              └───────┼───────┘             └───────┼───────┘
           │                             │                             │
           └─────────────────────────────┼─────────────────────────────┘
                                         │
                                    ┌────┴────┐
                                    │  User   │
                                    └─────────┘
```

---

## 7. Activity Diagrams

### 7.1 Play Track Activity

```
     ┌─────────┐
     │  Start  │
     └────┬────┘
          │
          ▼
    ┌───────────┐
    │Click Play │
    └─────┬─────┘
          │
          ▼
    ┌───────────┐
    │ Load Track│
    │  Metadata │
    └─────┬─────┘
          │
          ▼
    ┌───────────────┐
    │ AudioContext  │──No──┐
    │  Suspended?   │      │
    └───────┬───────┘      │
            │Yes           │
            ▼              │
    ┌───────────────┐      │
    │ Resume Context│      │
    └───────┬───────┘      │
            │              │
            └──────┬───────┘
                   │
                   ▼
    ┌─────────────────────┐
    │ Connect Audio Graph │
    │ source → EQ → gain  │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │   Start Playback    │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │   Update UI State   │
    └──────────┬──────────┘
               │
               ▼
         ┌─────────┐
         │   End   │
         └─────────┘
```

### 7.2 Search Activity

```
     ┌─────────┐
     │  Start  │
     └────┬────┘
          │
          ▼
    ┌───────────┐
    │Enter Query│
    └─────┬─────┘
          │
          ▼
    ┌───────────┐
    │  Debounce │
    │  (300ms)  │
    └─────┬─────┘
          │
          ▼
    ┌─────────────┐
    │ Check Cache │──Hit──┐
    └───────┬─────┘       │
            │Miss         │
            ▼             │
    ┌─────────────┐       │
    │ API Request │       │
    └───────┬─────┘       │
            │             │
            ▼             │
    ┌─────────────┐       │
    │ Store Cache │       │
    └───────┬─────┘       │
            │             │
            └──────┬──────┘
                   │
                   ▼
    ┌─────────────────────┐
    │  Display Results    │
    └──────────┬──────────┘
               │
               ▼
         ┌─────────┐
         │   End   │
         └─────────┘
```

---

## 8. State Diagrams

### 8.1 Player States

```
                    ┌────────────┐
                    │   IDLE     │
                    │  (no track)│
                    └──────┬─────┘
                           │ loadTrack()
                           ▼
                    ┌────────────┐
         ┌─────────│  LOADING   │
         │         └──────┬─────┘
         │                │ loaded
         │                ▼
         │         ┌────────────┐
    error│  ┌─────>│  PLAYING   │<────┐
         │  │      └──────┬─────┘     │
         │  │             │pause()    │play()
         │  │             ▼           │
         │  │      ┌────────────┐     │
         │  │      │   PAUSED   │─────┘
         │  │      └──────┬─────┘
         │  │             │
         │  │    ended    │
         │  └─────────────┘
         │
         ▼
    ┌────────────┐
    │   ERROR    │
    └────────────┘
```

### 8.2 Repeat Mode States

```
    ┌──────────┐   toggle()   ┌──────────┐   toggle()   ┌──────────┐
    │   NONE   │────────────>│   ALL    │────────────>│   ONE    │
    └────┬─────┘             └──────────┘             └────┬─────┘
         │                                                  │
         │                   toggle()                       │
         └──────────────────────────────────────────────────┘
```
