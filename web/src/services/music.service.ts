/**
 * Hybrid Music Service
 * Combines Deezer (metadata) + YouTube (full audio)
 * 
 * Strategy:
 * 1. Use Deezer for: search, metadata, album art, artist info
 * 2. Use YouTube for: full-length audio playback
 * 3. Cache YouTube video IDs to avoid repeated searches
 */

import { deezerService } from './deezer.service'
// YouTube service is disabled - using Deezer 30s previews
// import { youtubeService } from './youtube.service'

interface CachedAudio {
  trackId: string
  youtubeVideoId: string
  audioUrl: string
  timestamp: number
}

class MusicService {
  private audioCache: Map<string, CachedAudio> = new Map()
  private cacheExpiry = 24 * 60 * 60 * 1000 // 24 hours

  constructor() {
    // Load cache from localStorage
    this.loadCache()
  }

  /**
   * Search for music using Deezer
   */
  async search(query: string, type: 'track' | 'album' | 'artist' = 'track', limit: number = 20) {
    return deezerService.search(query, type, limit)
  }

  /**
   * Get full audio URL for a track
   * DISABLED - Using Deezer 30s previews for reliability
   */
  async getFullAudioUrl(_trackId: string, title: string, artist: string): Promise<string | null> {
    // Full audio extraction disabled - always return null to use Deezer preview
    console.log(`ℹ️ Using Deezer 30s preview for: ${artist} - ${title}`)
    return null
  }

  /**
   * Get track with full audio URL
   */
  async getTrackWithFullAudio(trackId: number) {
    const track = await deezerService.getTrack(trackId)
    if (!track) return null

    const fullAudioUrl = await this.getFullAudioUrl(
      track.id.toString(),
      track.title,
      track.artist.name
    )

    return {
      ...deezerService.transformTrack(track),
      audioUrl: fullAudioUrl || track.preview, // Fallback to 30s preview
      hasFullAudio: !!fullAudioUrl
    }
  }

  /**
   * Get album with full audio URLs for all tracks
   */
  async getAlbumWithFullAudio(albumId: number) {
    const album = await deezerService.getAlbum(albumId)
    if (!album) return null

    // Fetch full audio for all tracks (in parallel, but limited)
    const tracksWithAudio = await Promise.all(
      album.tracks.data.slice(0, 10).map(async (track) => { // Limit to first 10 to avoid rate limits
        const fullAudioUrl = await this.getFullAudioUrl(
          track.id.toString(),
          track.title,
          track.artist.name
        )

        return {
          ...deezerService.transformTrack(track),
          audioUrl: fullAudioUrl || track.preview,
          hasFullAudio: !!fullAudioUrl
        }
      })
    )

    return {
      album,
      tracksWithAudio
    }
  }

  /**
   * Search and get results with full audio capability indicator
   */
  async searchWithAudioInfo(query: string) {
    const results = await this.search(query, 'track', 20)
    
    return results.map((track: any) => ({
      ...track,
      hasFullAudio: true, // YouTube search available for all
      requiresYouTubeSearch: !this.audioCache.has(track.id.toString())
    }))
  }

  /**
   * Clear expired cache entries
   */
  cleanCache() {
    const now = Date.now()
    let cleaned = 0

    for (const [trackId, cached] of this.audioCache.entries()) {
      if ((now - cached.timestamp) > this.cacheExpiry) {
        this.audioCache.delete(trackId)
        cleaned++
      }
    }

    if (cleaned > 0) {
      console.log(`Cleaned ${cleaned} expired cache entries`)
      this.saveCache()
    }
  }

  /**
   * Load cache from localStorage
   */
  private loadCache() {
    try {
      const stored = localStorage.getItem('jetstream_audio_cache')
      if (stored) {
        const entries = JSON.parse(stored) as CachedAudio[]
        entries.forEach(entry => {
          this.audioCache.set(entry.trackId, entry)
        })
        console.log(`Loaded ${entries.length} cached audio URLs`)
      }
    } catch (error) {
      console.error('Failed to load audio cache:', error)
    }
  }

  /**
   * Save cache to localStorage
   */
  private saveCache() {
    try {
      const entries = Array.from(this.audioCache.values())
      localStorage.setItem('jetstream_audio_cache', JSON.stringify(entries))
    } catch (error) {
      console.error('Failed to save audio cache:', error)
    }
  }

  /**
   * Get cache statistics
   */
  getCacheStats() {
    return {
      totalEntries: this.audioCache.size,
      oldestEntry: Math.min(...Array.from(this.audioCache.values()).map(c => c.timestamp)),
      newestEntry: Math.max(...Array.from(this.audioCache.values()).map(c => c.timestamp))
    }
  }

  // Proxy all other Deezer methods
  getChart = deezerService.getChart.bind(deezerService)
  getArtist = deezerService.getArtist.bind(deezerService)
  getArtistTopTracks = deezerService.getArtistTopTracks.bind(deezerService)
  getArtistAlbums = deezerService.getArtistAlbums.bind(deezerService)
  getRelatedArtists = deezerService.getRelatedArtists.bind(deezerService)
  getGenres = deezerService.getGenres.bind(deezerService)
  getGenre = deezerService.getGenre.bind(deezerService)
}

// Export singleton instance
export const musicService = new MusicService()

// Run cache cleanup every hour
setInterval(() => {
  musicService.cleanCache()
}, 60 * 60 * 1000)
