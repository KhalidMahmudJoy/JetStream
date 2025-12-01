import { motion } from 'framer-motion'
import { Play } from 'lucide-react'
import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { deezerService } from '../services/deezer.service'
import styles from './HomePage.module.css'

// Quick picks configuration
// 'Liked Songs' links to library, others search for their title
const quickPicksPlaylists = [
  { id: '1', title: 'Liked Songs', image: 'https://i.pravatar.cc/400?img=1', color: '#1DB954', link: '/library?tab=liked' },
  { id: '2', title: 'Chill Mix', image: 'https://i.pravatar.cc/400?img=2', color: '#2D9CDB', searchQuery: 'chill relaxing music' },
  { id: '3', title: 'Workout', image: 'https://i.pravatar.cc/400?img=3', color: '#00D4FF', searchQuery: 'workout gym motivation' },
  { id: '4', title: 'Focus Flow', image: 'https://i.pravatar.cc/400?img=4', color: '#1DD1A1', searchQuery: 'focus concentration study' },
  { id: '5', title: 'Party Hits', image: 'https://i.pravatar.cc/400?img=5', color: '#00B8D4', searchQuery: 'party dance hits' },
  { id: '6', title: 'Sleep Sounds', image: 'https://i.pravatar.cc/400?img=6', color: '#0097A7', searchQuery: 'sleep ambient relaxation' }
]

interface Album {
  id: string
  title: string
  artist: string
  image: string
}

interface Artist {
  id: string
  name: string
  image: string
}

function HomePage() {
  const [hoveredItem, setHoveredItem] = useState<string | null>(null)
  const [trendingAlbums, setTrendingAlbums] = useState<Album[]>([])
  const [popularArtists, setPopularArtists] = useState<Artist[]>([])
  const [madeForYou, setMadeForYou] = useState<Album[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchData = async () => {
      try {
        console.log('🎵 Fetching music data from Deezer...')
        console.log('🌐 Using CORS proxy to access Deezer API')
        
        // Fetch trending albums from TOP TRACKS (albums of most popular songs)
        const topTracks = await deezerService.getChart('tracks', 50)
        console.log('� Top tracks fetched:', topTracks.length)
        
        if (topTracks && topTracks.length > 0) {
          // Get unique albums from top tracks (these are albums with most popular songs)
          const uniqueAlbums = new Map()
          topTracks.forEach((track: any) => {
            if (track.album && !uniqueAlbums.has(track.album.id)) {
              uniqueAlbums.set(track.album.id, {
                id: track.album.id.toString(),
                title: track.album.title,
                artist: track.artist.name,
                image: track.album.cover_big || track.album.cover_xl || track.album.cover_medium || 'https://via.placeholder.com/300x300?text=No+Image'
              })
            }
          })
          const formattedAlbums = Array.from(uniqueAlbums.values()).slice(0, 12)
          console.log('✅ Trending albums from top tracks:', formattedAlbums.length, formattedAlbums)
          setTrendingAlbums(formattedAlbums)
        }

        // Fetch popular artists from Deezer chart (get MORE!)
        const artists = await deezerService.getChart('artists', 50)
        console.log('🎤 Artists fetched:', artists.length)
        
        if (artists && artists.length > 0) {
          const formattedArtists = artists.slice(0, 12).map((artist: any) => ({
            id: artist.id.toString(),
            name: artist.name,
            image: artist.picture_xl || artist.picture_big || artist.picture_medium || 'https://via.placeholder.com/300x300?text=No+Image'
          }))
          console.log('✅ Formatted artists:', formattedArtists)
          setPopularArtists(formattedArtists)
        }



        // Fetch "Made For You" - personalized mix of popular genres
        console.log('🎁 Fetching Made For You recommendations...')
        const madeForYouSearches = [
          deezerService.search('pop hits 2024 2025', 'album', 15),
          deezerService.search('chill vibes relax', 'album', 15),
          deezerService.search('workout energy gym', 'album', 15)
        ]
        const madeForYouResults = await Promise.all(madeForYouSearches)
        const allMadeForYou = madeForYouResults.flat()
        console.log('🎁 Made For You results:', allMadeForYou.length)
        
        if (allMadeForYou.length > 0) {
          // Shuffle and get diverse selection
          const shuffled = allMadeForYou.sort(() => 0.5 - Math.random())
          const formattedMadeForYou = shuffled.slice(0, 12).map((album: any) => ({
            id: album.id.toString(),
            title: album.title,
            artist: album.artist.name,
            image: album.cover_big || album.cover_xl || album.cover_medium || 'https://via.placeholder.com/300x300?text=No+Image'
          }))
          console.log('✅ Formatted Made For You:', formattedMadeForYou.length, formattedMadeForYou)
          setMadeForYou(formattedMadeForYou)
        } else {
          console.log('⚠️ No Made For You results found')
        }

        setLoading(false)
        console.log('🎉 All data loaded successfully!')
      } catch (error) {
        console.error('❌ Error fetching data:', error)
        // Set empty arrays instead of staying in loading state
        setTrendingAlbums([])
        setPopularArtists([])
        setMadeForYou([])
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  const getGreeting = () => {
    const hour = new Date().getHours()
    if (hour < 12) return 'Good morning'
    if (hour < 18) return 'Good afternoon'
    return 'Good evening'
  }

  if (loading) {
    return (
      <div className={styles.container}>
        <motion.div className={styles.greeting} initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
          <h1>Loading music from Deezer...</h1>
          <p style={{ color: 'rgba(255,255,255,0.6)', marginTop: '1rem' }}>Fetching trending albums and artists 🎵</p>
        </motion.div>
      </div>
    )
  }

  if (!loading && trendingAlbums.length === 0 && popularArtists.length === 0) {
    return (
      <div className={styles.container}>
        <motion.div className={styles.greeting} initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
          <h1>No music data available</h1>
          <p style={{ color: 'rgba(255,255,255,0.6)', marginTop: '1rem' }}>
            Could not load music from Deezer. Please check your internet connection.
          </p>
        </motion.div>
      </div>
    )
  }

  return (
    <div className={styles.container}>
      <motion.div className={styles.greeting} initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }}>
        <h1>{getGreeting()}</h1>
      </motion.div>

      <motion.section className={styles.quickPicks} initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.1 }}>
        {quickPicksPlaylists.map((item, index) => (
          <Link 
            key={item.id} 
            to={item.link || `/search?q=${encodeURIComponent(item.searchQuery || item.title)}`} 
            style={{ textDecoration: 'none' }}
          >
            <motion.div
              className={styles.quickPickCard}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 + index * 0.05 }}
              onHoverStart={() => setHoveredItem(`quick-${item.id}`)}
              onHoverEnd={() => setHoveredItem(null)}
            >
              <div className={styles.quickPickImage} style={{ background: item.color }}>
                <img src={item.image} alt={item.title} />
              </div>
              <div className={styles.quickPickInfo}>
                <div className={styles.quickPickTitle}>{item.title}</div>
              </div>
              <motion.div
                className={styles.quickPickPlay}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{
                  opacity: hoveredItem === `quick-${item.id}` ? 1 : 0,
                  scale: hoveredItem === `quick-${item.id}` ? 1 : 0.8
                }}
              >
                <Play size={20} fill="currentColor" />
              </motion.div>
            </motion.div>
          </Link>
        ))}
      </motion.section>

      <motion.section className={styles.section} initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.3 }}>
        <div className={styles.sectionHeader}>
          <h2>Trending Albums</h2>
          <Link to="/search" className={styles.seeAll}>See all</Link>
        </div>
        <div className={styles.horizontalScroll}>
          {trendingAlbums.map((album) => (
            <Link key={album.id} to={`/album/${album.id}`} style={{ textDecoration: 'none' }}>
              <motion.div className={styles.albumCard} onHoverStart={() => setHoveredItem(`album-${album.id}`)} onHoverEnd={() => setHoveredItem(null)} whileHover={{ y: -4 }}>
                <div className={styles.albumImage}>
                  <img src={album.image} alt={album.title} />
                  <motion.div className={styles.albumPlay} initial={{ opacity: 0, y: 10 }} animate={{ opacity: hoveredItem === `album-${album.id}` ? 1 : 0, y: hoveredItem === `album-${album.id}` ? 0 : 10 }}>
                    <Play size={24} fill="currentColor" />
                  </motion.div>
                </div>
                <div className={styles.albumInfo}>
                  <div className={styles.albumTitle}>{album.title}</div>
                  <div className={styles.albumArtist}>{album.artist}</div>
                </div>
              </motion.div>
            </Link>
          ))}
        </div>
      </motion.section>

      <motion.section className={styles.section} initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.4 }}>
        <div className={styles.sectionHeader}>
          <h2>Popular Artists</h2>
          <Link to="/search" className={styles.seeAll}>See all</Link>
        </div>
        <div className={styles.horizontalScroll}>
          {popularArtists.map((artist) => (
            <Link key={artist.id} to={`/artist/${artist.id}`} style={{ textDecoration: 'none' }}>
              <motion.div className={styles.artistCard} onHoverStart={() => setHoveredItem(`artist-${artist.id}`)} onHoverEnd={() => setHoveredItem(null)} whileHover={{ y: -4 }}>
                <div className={styles.artistImage}>
                  <img src={artist.image} alt={artist.name} />
                  <motion.div className={styles.artistPlay} initial={{ opacity: 0, y: 10 }} animate={{ opacity: hoveredItem === `artist-${artist.id}` ? 1 : 0, y: hoveredItem === `artist-${artist.id}` ? 0 : 10 }}>
                    <Play size={24} fill="currentColor" />
                  </motion.div>
                </div>
                <div className={styles.artistName}>{artist.name}</div>
                <div className={styles.artistType}>Artist</div>
              </motion.div>
            </Link>
          ))}
        </div>
      </motion.section>

      {/* Made For You Section - Personalized Recommendations */}
      {madeForYou.length > 0 && (
        <motion.section className={styles.section} initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.9 }}>
          <div className={styles.sectionHeader}>
            <h2>🎁 Made For You</h2>
            <Link to="/library" className={styles.seeAll}>See all</Link>
          </div>
          <div className={styles.horizontalScroll}>
            {madeForYou.map((album) => (
              <Link key={album.id} to={`/album/${album.id}`} style={{ textDecoration: 'none' }}>
                <motion.div className={styles.playlistCard} onHoverStart={() => setHoveredItem(`playlist-${album.id}`)} onHoverEnd={() => setHoveredItem(null)} whileHover={{ y: -4 }}>
                  <div className={styles.playlistImage}>
                    <img src={album.image} alt={album.title} />
                    <motion.div className={styles.playlistPlay} initial={{ opacity: 0, y: 10 }} animate={{ opacity: hoveredItem === `playlist-${album.id}` ? 1 : 0, y: hoveredItem === `playlist-${album.id}` ? 0 : 10 }}>
                      <Play size={24} fill="currentColor" />
                    </motion.div>
                  </div>
                  <div className={styles.playlistInfo}>
                    <div className={styles.playlistTitle}>{album.title}</div>
                    <div className={styles.playlistSubtitle}>{album.artist}</div>
                  </div>
                </motion.div>
              </Link>
            ))}
          </div>
        </motion.section>
      )}
    </div>
  )
}

export default HomePage
