import { motion } from 'framer-motion'
import { Play, TrendingUp } from 'lucide-react'
import { useState, useEffect } from 'react'
import { deezerService } from '../services/deezer.service'
import { usePlayer } from '../contexts/PlayerContext'
import styles from './HitsPage.module.css'

interface Track {
  id: string
  title: string
  artist: string
  albumTitle: string
  coverImage: string
  duration: number
  audioUrl: string
}

function HitsPage() {
  const [globalHits, setGlobalHits] = useState<Track[]>([])
  const [loading, setLoading] = useState(true)
  const [hoveredTrack, setHoveredTrack] = useState<string | null>(null)
  const { playTrack } = usePlayer()

  useEffect(() => {
    const fetchHits = async () => {
      try {
        console.log('🔥 Fetching global and Bangladeshi hits...')

        // Fetch Global Hit Songs from Deezer Chart
        const globalTracks = await deezerService.getChart('tracks', 50)
        if (globalTracks && globalTracks.length > 0) {
          const formattedGlobal = globalTracks.slice(0, 50).map((track: any) => 
            deezerService.transformTrack(track)
          )
          setGlobalHits(formattedGlobal)
          console.log('🌍 Global hits loaded:', formattedGlobal.length)
        }

        setLoading(false)
        console.log('✅ All hits loaded!')
      } catch (error) {
        console.error('❌ Error fetching hits:', error)
        setGlobalHits([])
        setLoading(false)
      }
    }

    fetchHits()
  }, [])

  const handlePlayTrack = (track: Track, _index: number) => {
    // Play this track and set up queue with all hits
    playTrack({
      id: track.id,
      title: track.title,
      artist: track.artist,
      albumTitle: track.albumTitle,
      coverImage: track.coverImage,
      duration: track.duration,
      audioUrl: track.audioUrl
    }, globalHits)
  }

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }

  if (loading) {
    return (
      <div className={styles.container}>
        <motion.div
          className={styles.header}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
        >
          <h1>Loading hits...</h1>
          <p>Fetching the hottest tracks 🔥</p>
        </motion.div>
      </div>
    )
  }

  return (
    <div className={styles.container}>
      <motion.div
        className={styles.header}
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <div className={styles.headerIcon}>
          <TrendingUp size={48} />
        </div>
        <div className={styles.headerContent}>
          <p className={styles.headerLabel}>Trending Now</p>
          <h1 className={styles.headerTitle}>Top Hits</h1>
          <p className={styles.headerSubtitle}>
            Global chart-toppers and trending tracks
          </p>
        </div>
      </motion.div>

      {/* Global Hits Section */}
      <motion.section
        className={styles.section}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.2 }}
      >
        <div className={styles.sectionHeader}>
          <h2>🌍 Global Hits</h2>
          <span className={styles.trackCount}>{globalHits.length} tracks</span>
        </div>

        <div className={styles.trackList}>
          {globalHits.map((track, index) => (
            <motion.div
              key={track.id}
              className={styles.trackItem}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 + index * 0.02 }}
              onHoverStart={() => setHoveredTrack(`global-${track.id}`)}
              onHoverEnd={() => setHoveredTrack(null)}
              onClick={() => handlePlayTrack(track, index)}
            >
              <div className={styles.trackNumber}>
                {hoveredTrack === `global-${track.id}` ? (
                  <motion.div
                    className={styles.playIcon}
                    initial={{ scale: 0.8 }}
                    animate={{ scale: 1 }}
                  >
                    <Play size={16} fill="currentColor" />
                  </motion.div>
                ) : (
                  <span>{index + 1}</span>
                )}
              </div>
              <div className={styles.trackImage}>
                <img src={track.coverImage} alt={track.title} />
              </div>
              <div className={styles.trackInfo}>
                <div className={styles.trackTitle}>{track.title}</div>
                <div className={styles.trackArtist}>{track.artist}</div>
              </div>
              <div className={styles.trackAlbum}>{track.albumTitle}</div>
              <div className={styles.trackDuration}>
                {formatDuration(track.duration)}
              </div>
            </motion.div>
          ))}
        </div>
      </motion.section>


    </div>
  )
}

export default HitsPage
