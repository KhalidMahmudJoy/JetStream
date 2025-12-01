/**
 * Shared TypeScript types and interfaces for JetStream
 */

// ============= Audio Types =============

export interface Track {
  id: string;
  title: string;
  artist: string;
  album?: string;
  duration: number; // in seconds
  coverArt?: string;
  audioUrl: string;
  isOffline: boolean;
  localPath?: string;
  genre?: string[];
  releaseDate?: string;
  lyrics?: string;
  isExplicit?: boolean;
  metadata?: TrackMetadata;
}

export interface TrackMetadata {
  bitrate?: number;
  sampleRate?: number;
  codec?: string;
  fileSize?: number;
  bpm?: number;
  key?: string;
  mood?: string[];
  tags?: string[];
}

export interface Album {
  id: string;
  title: string;
  artist: string;
  coverArt: string;
  tracks: Track[];
  releaseDate: string;
  genre?: string[];
  totalDuration: number;
}

export interface Artist {
  id: string;
  name: string;
  bio?: string;
  image?: string;
  genres?: string[];
  albums: Album[];
  topTracks: Track[];
  followers?: number;
  verified?: boolean;
}

export interface Playlist {
  id: string;
  name: string;
  description?: string;
  coverArt?: string;
  tracks: Track[];
  owner: User;
  isPublic: boolean;
  isCollaborative: boolean;
  collaborators?: User[];
  createdAt: string;
  updatedAt: string;
  followers?: number;
  totalDuration: number;
  blockchainId?: string; // For NFT playlists
}

// ============= User Types =============

export interface User {
  id: string;
  username: string;
  email: string;
  displayName: string;
  avatar?: string;
  bio?: string;
  isPremium: boolean;
  preferences: UserPreferences;
  playlists: Playlist[];
  likedTracks: Track[];
  following: User[];
  followers: User[];
  createdAt: string;
  walletAddress?: string; // For blockchain features
}

export interface UserPreferences {
  theme: 'dark' | 'light' | 'auto';
  audioQuality: 'low' | 'medium' | 'high' | 'lossless';
  offlineMode: boolean;
  crossfadeEnabled: boolean;
  crossfadeDuration: number; // in seconds
  gaplessPlayback: boolean;
  normalizeVolume: boolean;
  language: string;
  notificationsEnabled: boolean;
  dataUsage: 'wifi' | 'cellular' | 'both';
  aiRecommendations: boolean;
  explicitContent: boolean;
}

// ============= Playback Types =============

export interface PlaybackState {
  currentTrack: Track | null;
  isPlaying: boolean;
  isPaused: boolean;
  isLoading: boolean;
  queue: Track[];
  history: Track[];
  currentIndex: number;
  position: number; // in seconds
  duration: number; // in seconds
  volume: number; // 0-1
  repeatMode: RepeatMode;
  shuffleEnabled: boolean;
  speed: number; // 0.5-2.0
}

export type RepeatMode = 'off' | 'one' | 'all';

export interface AudioSettings {
  equalizer: EqualizerPreset;
  bass: number; // -12 to +12 dB
  treble: number; // -12 to +12 dB
  spatialAudio: boolean;
  noiseCancellation: boolean;
  reverb: number; // 0-100
}

export interface EqualizerPreset {
  name: string;
  bands: number[]; // Frequency bands in dB
}

// ============= AI/ML Types =============

export interface Recommendation {
  tracks: Track[];
  playlists: Playlist[];
  artists: Artist[];
  reason: string;
  confidence: number; // 0-1
}

export interface MoodAnalysis {
  mood: 'happy' | 'sad' | 'energetic' | 'calm' | 'angry' | 'focused';
  energy: number; // 0-1
  valence: number; // 0-1 (musical positivity)
  danceability: number; // 0-1
  acousticness: number; // 0-1
}

// ============= Blockchain Types =============

export interface NFTPlaylist {
  tokenId: string;
  contractAddress: string;
  owner: string;
  playlist: Playlist;
  metadata: NFTMetadata;
  price?: number;
  forSale: boolean;
  royalties: number; // percentage
}

export interface NFTMetadata {
  name: string;
  description: string;
  image: string;
  attributes: NFTAttribute[];
  createdAt: string;
  network: 'ethereum' | 'polygon' | 'solana';
}

export interface NFTAttribute {
  trait_type: string;
  value: string | number;
}

// ============= Plugin Types =============

export interface Plugin {
  id: string;
  name: string;
  version: string;
  description: string;
  author: string;
  icon?: string;
  enabled: boolean;
  type: PluginType;
  entryPoint: string;
  permissions: PluginPermission[];
  settings?: Record<string, any>;
}

export type PluginType = 
  | 'audio-effect' 
  | 'visualization' 
  | 'integration' 
  | 'ai-model' 
  | 'ui-extension';

export type PluginPermission =
  | 'audio-access'
  | 'file-system'
  | 'network'
  | 'blockchain'
  | 'user-data'
  | 'notifications';

// ============= API Response Types =============

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: ApiError;
  timestamp: string;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  hasMore: boolean;
}

// ============= Search Types =============

export interface SearchResult {
  tracks: Track[];
  albums: Album[];
  artists: Artist[];
  playlists: Playlist[];
  query: string;
}

export interface SearchFilters {
  type?: 'track' | 'album' | 'artist' | 'playlist' | 'all';
  genre?: string[];
  year?: number[];
  duration?: { min: number; max: number };
  mood?: string[];
  explicit?: boolean;
}

// ============= Analytics Types =============

export interface ListeningStats {
  totalPlaytime: number; // in seconds
  topTracks: Track[];
  topArtists: Artist[];
  topGenres: string[];
  listeningHistory: ListeningSession[];
  favoriteTime: string; // peak listening time
  diversityScore: number; // 0-1
}

export interface ListeningSession {
  trackId: string;
  startTime: string;
  duration: number;
  completionRate: number; // 0-1
  skipped: boolean;
  source: 'search' | 'playlist' | 'recommendation' | 'album';
}

// ============= Export Everything =============

// Re-export theme types from the theme module
export type { Theme } from '../theme';
