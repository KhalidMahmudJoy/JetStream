# Testing Documentation

## 1. Testing Strategy

### 1.1 Testing Pyramid

```
                    ┌─────────────┐
                    │    E2E      │  ← Few, slow, high confidence
                    │   Tests     │
                  ┌─┴─────────────┴─┐
                  │  Integration    │  ← Medium coverage
                  │     Tests       │
                ┌─┴─────────────────┴─┐
                │      Unit Tests      │  ← Many, fast, focused
                └──────────────────────┘
```

### 1.2 Test Distribution Goals

| Test Type | Coverage Target | Execution Time |
|-----------|-----------------|----------------|
| Unit Tests | 80% | < 30 seconds |
| Integration Tests | 60% | < 2 minutes |
| E2E Tests | Critical paths | < 5 minutes |

---

## 2. Unit Testing

### 2.1 Testing Framework

- **Test Runner**: Vitest
- **Assertions**: Vitest built-in
- **Mocking**: vi.mock(), vi.fn()
- **DOM Testing**: @testing-library/react

### 2.2 Test File Structure

```
src/
├── components/
│   ├── GlassPlayer.tsx
│   └── __tests__/
│       └── GlassPlayer.test.tsx
├── services/
│   ├── storage.service.ts
│   └── __tests__/
│       └── storage.service.test.ts
├── contexts/
│   ├── PlayerContext.tsx
│   └── __tests__/
│       └── PlayerContext.test.tsx
└── utils/
    ├── formatters.ts
    └── __tests__/
        └── formatters.test.ts
```

### 2.3 Unit Test Examples

#### Testing Utility Functions

```typescript
// src/utils/__tests__/formatters.test.ts
import { describe, it, expect } from 'vitest';
import { formatTime, formatDuration } from '../formatters';

describe('formatTime', () => {
  it('should format seconds to mm:ss', () => {
    expect(formatTime(0)).toBe('0:00');
    expect(formatTime(65)).toBe('1:05');
    expect(formatTime(3661)).toBe('61:01');
  });

  it('should handle negative values', () => {
    expect(formatTime(-1)).toBe('0:00');
  });

  it('should handle NaN', () => {
    expect(formatTime(NaN)).toBe('0:00');
  });
});

describe('formatDuration', () => {
  it('should format milliseconds to readable string', () => {
    expect(formatDuration(60000)).toBe('1 min');
    expect(formatDuration(3600000)).toBe('1 hr');
    expect(formatDuration(5400000)).toBe('1 hr 30 min');
  });
});
```

#### Testing Services

```typescript
// src/services/__tests__/storage.service.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { storageService } from '../storage.service';

describe('StorageService', () => {
  beforeEach(() => {
    localStorage.clear();
    vi.clearAllMocks();
  });

  describe('likedSongs', () => {
    it('should return empty array when no liked songs', () => {
      const songs = storageService.getLikedSongs();
      expect(songs).toEqual([]);
    });

    it('should add a track to liked songs', () => {
      const track = {
        id: '123',
        title: 'Test Track',
        artist: 'Test Artist',
        // ... other properties
      };

      storageService.addLikedSong(track);
      const songs = storageService.getLikedSongs();
      
      expect(songs).toHaveLength(1);
      expect(songs[0].id).toBe('123');
    });

    it('should not add duplicate tracks', () => {
      const track = { id: '123', title: 'Test', artist: 'Test' };
      
      storageService.addLikedSong(track);
      storageService.addLikedSong(track);
      
      const songs = storageService.getLikedSongs();
      expect(songs).toHaveLength(1);
    });

    it('should remove a track from liked songs', () => {
      const track = { id: '123', title: 'Test', artist: 'Test' };
      
      storageService.addLikedSong(track);
      storageService.removeLikedSong('123');
      
      const songs = storageService.getLikedSongs();
      expect(songs).toHaveLength(0);
    });
  });

  describe('playlists', () => {
    it('should create a new playlist', () => {
      const playlist = storageService.createPlaylist('My Playlist', 'Description');
      
      expect(playlist.name).toBe('My Playlist');
      expect(playlist.description).toBe('Description');
      expect(playlist.tracks).toEqual([]);
      expect(playlist.id).toMatch(/^playlist_\d+$/);
    });

    it('should add track to playlist', () => {
      const playlist = storageService.createPlaylist('Test', '');
      const track = { id: '123', title: 'Test', artist: 'Test' };
      
      storageService.addTrackToPlaylist(playlist.id, track);
      
      const playlists = storageService.getPlaylists();
      expect(playlists[0].tracks).toHaveLength(1);
    });
  });
});
```

#### Testing Components

```typescript
// src/components/__tests__/GlassPlayer.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { GlassPlayer } from '../GlassPlayer';
import { PlayerContext } from '../../contexts/PlayerContext';

const mockPlayerContext = {
  currentTrack: {
    id: '1',
    title: 'Test Song',
    artist: 'Test Artist',
    coverImage: 'test.jpg',
    duration: 180,
  },
  isPlaying: false,
  progress: 0,
  volume: 0.7,
  playPause: vi.fn(),
  skipNext: vi.fn(),
  skipPrevious: vi.fn(),
  seek: vi.fn(),
  setVolume: vi.fn(),
};

const renderWithContext = (component: React.ReactNode) => {
  return render(
    <PlayerContext.Provider value={mockPlayerContext}>
      {component}
    </PlayerContext.Provider>
  );
};

describe('GlassPlayer', () => {
  it('should display current track info', () => {
    renderWithContext(<GlassPlayer />);
    
    expect(screen.getByText('Test Song')).toBeInTheDocument();
    expect(screen.getByText('Test Artist')).toBeInTheDocument();
  });

  it('should show play button when paused', () => {
    renderWithContext(<GlassPlayer />);
    
    const playButton = screen.getByRole('button', { name: /play/i });
    expect(playButton).toBeInTheDocument();
  });

  it('should call playPause when play button clicked', () => {
    renderWithContext(<GlassPlayer />);
    
    const playButton = screen.getByRole('button', { name: /play/i });
    fireEvent.click(playButton);
    
    expect(mockPlayerContext.playPause).toHaveBeenCalled();
  });

  it('should call skipNext when next button clicked', () => {
    renderWithContext(<GlassPlayer />);
    
    const nextButton = screen.getByRole('button', { name: /next/i });
    fireEvent.click(nextButton);
    
    expect(mockPlayerContext.skipNext).toHaveBeenCalled();
  });
});
```

---

## 3. Integration Testing

### 3.1 Context Integration Tests

```typescript
// src/contexts/__tests__/PlayerContext.integration.test.tsx
import { describe, it, expect, beforeEach } from 'vitest';
import { render, screen, act } from '@testing-library/react';
import { PlayerProvider, usePlayer } from '../PlayerContext';

const TestComponent = () => {
  const { currentTrack, playTrack, isPlaying } = usePlayer();
  
  return (
    <div>
      <span data-testid="current">{currentTrack?.title || 'None'}</span>
      <span data-testid="playing">{isPlaying ? 'Playing' : 'Paused'}</span>
      <button onClick={() => playTrack(mockTrack)}>Play</button>
    </div>
  );
};

const mockTrack = {
  id: '1',
  title: 'Test Track',
  artist: 'Artist',
  audioUrl: 'https://example.com/audio.mp3',
};

describe('PlayerContext Integration', () => {
  it('should update state when playing a track', async () => {
    render(
      <PlayerProvider>
        <TestComponent />
      </PlayerProvider>
    );
    
    expect(screen.getByTestId('current')).toHaveTextContent('None');
    
    await act(async () => {
      screen.getByText('Play').click();
    });
    
    expect(screen.getByTestId('current')).toHaveTextContent('Test Track');
  });
});
```

### 3.2 API Integration Tests

```typescript
// src/services/__tests__/deezer.integration.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { deezerService } from '../deezer.service';

// Mock fetch
global.fetch = vi.fn();

describe('DeezerService Integration', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should search and return formatted results', async () => {
    const mockResponse = {
      data: [
        {
          id: 1,
          title: 'Test Song',
          artist: { name: 'Test Artist' },
          album: { title: 'Test Album', cover_medium: 'cover.jpg' },
          preview: 'audio.mp3',
          duration: 180,
        },
      ],
    };

    (fetch as any).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(mockResponse),
    });

    const results = await deezerService.search('test');
    
    expect(results).toHaveLength(1);
    expect(results[0].title).toBe('Test Song');
    expect(fetch).toHaveBeenCalledWith(
      expect.stringContaining('search/track')
    );
  });

  it('should handle API errors gracefully', async () => {
    (fetch as any).mockResolvedValueOnce({
      ok: false,
      status: 500,
    });

    await expect(deezerService.search('test')).rejects.toThrow();
  });
});
```

---

## 4. End-to-End Testing

### 4.1 E2E Framework

- **Tool**: Playwright or Cypress
- **Coverage**: Critical user journeys

### 4.2 E2E Test Scenarios

```typescript
// e2e/playback.spec.ts (Playwright)
import { test, expect } from '@playwright/test';

test.describe('Music Playback', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173');
  });

  test('should play a track from search results', async ({ page }) => {
    // Search for music
    await page.fill('[data-testid="search-input"]', 'Daft Punk');
    await page.keyboard.press('Enter');
    
    // Wait for results
    await page.waitForSelector('[data-testid="track-result"]');
    
    // Click play on first result
    await page.click('[data-testid="track-result"]:first-child [data-testid="play-button"]');
    
    // Verify player shows track
    await expect(page.locator('[data-testid="now-playing-title"]')).toBeVisible();
    await expect(page.locator('[data-testid="player-progress"]')).toBeVisible();
  });

  test('should add track to queue', async ({ page }) => {
    // Navigate to a track
    await page.fill('[data-testid="search-input"]', 'Test');
    await page.keyboard.press('Enter');
    
    // Add to queue
    await page.click('[data-testid="add-to-queue-button"]');
    
    // Open queue panel
    await page.click('[data-testid="queue-toggle"]');
    
    // Verify track in queue
    await expect(page.locator('[data-testid="queue-item"]')).toHaveCount(1);
  });
});
```

### 4.3 E2E Test Scenarios Matrix

| Scenario | Priority | Steps |
|----------|----------|-------|
| Search and Play | High | Search → Click result → Verify playback |
| Create Playlist | High | Library → Create → Name → Verify |
| Like Track | Medium | Play track → Click heart → Verify in library |
| Queue Management | Medium | Add to queue → Reorder → Play from queue |
| Settings Change | Low | Settings → Change option → Verify persistence |

---

## 5. Test Configuration

### 5.1 Vitest Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts',
        '**/*.config.*',
      ],
    },
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
  },
});
```

### 5.2 Test Setup File

```typescript
// src/test/setup.ts
import '@testing-library/jest-dom';
import { vi } from 'vitest';

// Mock localStorage
const localStorageMock = {
  getItem: vi.fn(),
  setItem: vi.fn(),
  removeItem: vi.fn(),
  clear: vi.fn(),
};
global.localStorage = localStorageMock as any;

// Mock Audio
class AudioMock {
  play = vi.fn(() => Promise.resolve());
  pause = vi.fn();
  addEventListener = vi.fn();
  removeEventListener = vi.fn();
}
global.Audio = AudioMock as any;

// Mock AudioContext
class AudioContextMock {
  createGain = vi.fn(() => ({ connect: vi.fn(), gain: { value: 1 } }));
  createAnalyser = vi.fn(() => ({
    connect: vi.fn(),
    frequencyBinCount: 64,
    getByteFrequencyData: vi.fn(),
  }));
  createMediaElementSource = vi.fn(() => ({ connect: vi.fn() }));
  createBiquadFilter = vi.fn(() => ({
    connect: vi.fn(),
    frequency: { value: 0 },
    gain: { value: 0 },
    type: 'peaking',
  }));
  destination = {};
}
global.AudioContext = AudioContextMock as any;
```

---

## 6. Running Tests

### 6.1 Commands

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- src/services/__tests__/storage.test.ts

# Run tests matching pattern
npm test -- --grep "PlayerContext"
```

### 6.2 CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run test:coverage
      - uses: codecov/codecov-action@v3
```

---

## 7. Mocking Guidelines

### 7.1 API Mocking

```typescript
// Mock entire service
vi.mock('../services/deezer.service', () => ({
  deezerService: {
    search: vi.fn(),
    getAlbum: vi.fn(),
    getArtist: vi.fn(),
  },
}));

// Mock specific implementation
import { deezerService } from '../services/deezer.service';

vi.mocked(deezerService.search).mockResolvedValue([
  { id: '1', title: 'Mock Song' },
]);
```

### 7.2 Component Mocking

```typescript
// Mock child component
vi.mock('../components/AudioVisualizer', () => ({
  AudioVisualizer: () => <div data-testid="visualizer-mock" />,
}));
```

### 7.3 Hook Mocking

```typescript
// Mock custom hook
vi.mock('../hooks/useKeyboardShortcuts', () => ({
  useKeyboardShortcuts: vi.fn(),
}));
```

---

## 8. Test Quality Metrics

### 8.1 Coverage Targets

| Metric | Target | Current |
|--------|--------|---------|
| Statements | 80% | - |
| Branches | 75% | - |
| Functions | 80% | - |
| Lines | 80% | - |

### 8.2 Quality Gates

- All tests must pass before merge
- Coverage must not decrease
- No skipped tests in main branch
- E2E tests must pass for releases
