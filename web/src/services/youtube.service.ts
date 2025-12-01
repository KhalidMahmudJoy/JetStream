/**
 * YouTube Music Service
 * Fetches full-length audio from YouTube for playback
 * Uses YouTube Data API v3 for search
 * 
 * IMPORTANT: You'll need a YouTube API key from Google Cloud Console
 * Get one at: https://console.cloud.google.com/apis/credentials
 */

const YOUTUBE_API_KEY = import.meta.env.VITE_YOUTUBE_API_KEY || ''
const YOUTUBE_API_BASE = 'https://www.googleapis.com/youtube/v3'

// CORS proxy for Invidious requests
const CORS_PROXY = 'https://corsproxy.io/?'

// Alternative: Use Invidious API (no API key needed, but less reliable)
const INVIDIOUS_INSTANCES = [
  'https://invidious.privacyredirect.com',
  'https://inv.riverside.rocks',
  'https://invidious.snopyta.org'
]

// YouTubeSearchResult interface - kept for reference
// interface YouTubeSearchResult {
//   id: { videoId: string }
//   snippet: {
//     title: string
//     channelTitle: string
//     thumbnails: {
//       default: { url: string }
//       medium: { url: string }
//       high: { url: string }
//     }
//   }
// }

class YouTubeService {
  private useInvidious = !YOUTUBE_API_KEY || YOUTUBE_API_KEY.trim() === ''
  
  constructor() {
    console.log('🔑 YouTube Service initialized:', {
      hasApiKey: !!YOUTUBE_API_KEY && YOUTUBE_API_KEY.trim() !== '',
      keyPreview: YOUTUBE_API_KEY ? YOUTUBE_API_KEY.substring(0, 10) + '...' : 'None',
      willUseInvidious: this.useInvidious
    })
  }
  
  /**
   * Search for a song on YouTube
   * Returns the best matching video ID
   */
  async searchSong(title: string, artist: string): Promise<string | null> {
    const query = `${artist} ${title} official audio`
    
    console.log('🔍 YouTube search method:', this.useInvidious ? 'Invidious' : 'YouTube API')
    
    if (this.useInvidious) {
      console.log('⚠️ Using Invidious (no API key detected)')
      return this.searchWithInvidious(query)
    } else {
      console.log('✅ Using YouTube Data API')
      return this.searchWithYouTubeAPI(query)
    }
  }

  /**
   * Search using official YouTube Data API (requires API key)
   */
  private async searchWithYouTubeAPI(query: string): Promise<string | null> {
    try {
      const params = new URLSearchParams({
        part: 'snippet',
        q: query,
        type: 'video',
        videoCategoryId: '10', // Music category
        maxResults: '1',
        key: YOUTUBE_API_KEY
      })

      console.log('📡 Calling YouTube Data API...')
      const response = await fetch(`${YOUTUBE_API_BASE}/search?${params}`)
      
      if (!response.ok) {
        const errorText = await response.text()
        console.error('YouTube API error:', response.status, errorText)
        
        // If API fails, try Invidious as fallback
        console.log('⚠️ YouTube API failed, trying Invidious as fallback...')
        return this.searchWithInvidious(query)
      }

      const data = await response.json()
      
      if (data.error) {
        console.error('YouTube API returned error:', data.error)
        return this.searchWithInvidious(query)
      }
      
      if (data.items && data.items.length > 0) {
        const videoId = data.items[0].id.videoId
        console.log('✅ Found video ID from YouTube API:', videoId)
        return videoId
      }

      console.warn('No results from YouTube API')
      return null
    } catch (error) {
      console.error('YouTube search error:', error)
      // Fallback to Invidious
      return this.searchWithInvidious(query)
    }
  }

  /**
   * Search using Invidious API (no API key needed) with CORS proxy
   */
  private async searchWithInvidious(query: string): Promise<string | null> {
    for (const instance of INVIDIOUS_INSTANCES) {
      try {
        const params = new URLSearchParams({
          q: query,
          type: 'video',
          page: '1'
        })

        // Use CORS proxy for search as well
        const url = `${CORS_PROXY}${encodeURIComponent(`${instance}/api/v1/search?${params}`)}`
        console.log(`🔍 Searching via ${instance}`)
        
        const controller = new AbortController()
        const timeout = setTimeout(() => controller.abort(), 5000)

        const response = await fetch(url, {
          signal: controller.signal
        })
        
        clearTimeout(timeout)

        if (!response.ok) {
          console.warn(`${instance} search failed with status: ${response.status}`)
          continue
        }

        const data = await response.json()
        
        if (data && data.length > 0) {
          const videoId = data[0].videoId
          console.log(`✅ Found video ID from ${instance}:`, videoId)
          return videoId
        }
      } catch (error: any) {
        if (error.name === 'AbortError') {
          console.warn(`${instance} search timed out, trying next...`)
        } else {
          console.warn(`Invidious instance ${instance} failed:`, error.message)
        }
        continue
      }
    }

    console.error('❌ All Invidious instances failed for search')
    return null
  }

  /**
   * Get YouTube video embed URL
   */
  getEmbedUrl(videoId: string): string {
    return `https://www.youtube.com/embed/${videoId}?autoplay=1&enablejsapi=1`
  }

  /**
   * Get YouTube video watch URL
   */
  getWatchUrl(videoId: string): string {
    return `https://www.youtube.com/watch?v=${videoId}`
  }

  /**
   * Get audio stream URL - DISABLED (using Deezer 30s previews instead)
   * Full audio extraction is complex and unreliable
   */
  async getAudioStreamUrl(_videoId: string): Promise<string | null> {
    console.log(`⚠️ YouTube audio disabled - using Deezer 30s previews`)
    
    // Return null to always fall back to Deezer preview
    return null
  }

  /**
   * OLD METHOD: Invidious (kept as fallback, but now we use backend!)
   * Try Invidious instances (direct audio stream)
   * This is the OLD way - backend is better!
    console.warn('⚠️ Could not get direct audio stream from any source')
    console.warn('💡 Recommendation: Use a backend service like youtube-dl or yt-dlp')
    console.warn('💡 For now, falling back to Deezer 30s preview')
    
    return null
  }

  /**
   * Check if API key is configured
   */
  isConfigured(): boolean {
    return !this.useInvidious
  }

  /**
   * Get configuration instructions
   */
  getSetupInstructions(): string {
    return `
To use YouTube integration:
1. Go to https://console.cloud.google.com/
2. Create a new project or select existing one
3. Enable "YouTube Data API v3"
4. Create credentials (API key)
5. Add to .env file: VITE_YOUTUBE_API_KEY=your_api_key_here

Alternatively, the app will use Invidious API (no key needed, but less reliable)
    `.trim()
  }
}

// Export singleton instance
export const youtubeService = new YouTubeService()
