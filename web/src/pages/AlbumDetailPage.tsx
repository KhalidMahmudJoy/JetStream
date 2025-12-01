import { motion } from 'framer-motion'
import { Play, Heart, Share2, MoreHorizontal, Clock, Plus } from 'lucide-react'
import { useState, useEffect } from 'react'
import { useParams, Link } from 'react-router-dom'
import { deezerService } from '../services/deezer.service'
import { usePlayer } from '../contexts/PlayerContext'
import AddToPlaylistModal from '../components/AddToPlaylistModal'
import styles from './AlbumDetailPage.module.css'

interface Track {
  id: string
  number: number
  title: string
  duration: string
  explicit: boolean
  preview: string
}

interface Album {
  id: string
  title: string
  artist: string
  artistId: string
  coverImage: string
  releaseDate: string
  totalTracks: number
  duration: string
  label: string
  tracks: Track[]
}

function AlbumDetailPage() {
  const { id } = useParams()
  const [album, setAlbum] = useState<Album | null>(null)
  const [similarAlbums, setSimilarAlbums] = useState<any[]>([])
  const [liked, setLiked] = useState(false)
  const [hoveredTrack, setHoveredTrack] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [isAddToPlaylistOpen, setIsAddToPlaylistOpen] = useState(false)
  const [selectedTrack, setSelectedTrack] = useState<Track | null>(null)
  const { playTrack } = usePlayer()

  useEffect(() => {
    const fetchAlbumData = async () => {
      if (!id) return

      try {
        const albumData = await deezerService.getAlbum(parseInt(id))
        
        if (albumData) {
          const formatTime = (seconds: number) => {
            const mins = Math.floor(seconds / 60)
            const secs = seconds % 60
            return `${mins}:${secs.toString().padStart(2, '0')}`
          }

          const totalDuration = albumData.tracks.data.reduce((acc: number, track: any) => acc + track.duration, 0)
          const formattedAlbum: Album = {
            id: albumData.id.toString(),
            title: albumData.title,
            artist: albumData.artist.name,
            artistId: albumData.artist.id.toString(),
            coverImage: albumData.cover_medium,
            releaseDate: new Date(albumData.release_date).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' }),
            totalTracks: albumData.tracks.data.length,
            duration: formatTime(totalDuration),
            label: 'Deezer',
            tracks: albumData.tracks.data.map((track: any, index: number) => ({
              id: track.id.toString(),
              number: index + 1,
              title: track.title,
              duration: formatTime(track.duration),
              explicit: track.explicit_lyrics,
              preview: track.preview
            }))
          }

          setAlbum(formattedAlbum)

          // Fetch more albums from same artist
          const artistAlbums = await deezerService.getArtistAlbums(albumData.artist.id, 5)
          setSimilarAlbums(artistAlbums.filter((a: any) => a.id !== albumData.id).slice(0, 4))
        }

        setLoading(false)
      } catch (error) {
        console.error('Error fetching album:', error)
        setLoading(false)
      }
    }

    fetchAlbumData()
  }, [id])

  const handlePlayTrack = (track: Track) => {
    if (album) {
      // Convert all album tracks to queue format
      const allTracks = album.tracks.map(t => ({
        id: t.id,
        title: t.title,
        artist: album.artist,
        albumTitle: album.title,
        coverImage: album.coverImage,
        duration: parseInt(t.duration.split(':')[0]) * 60 + parseInt(t.duration.split(':')[1]),
        audioUrl: t.preview
      }))
      
      // Play the selected track with the full album as queue
      const currentTrack = {
        id: track.id,
        title: track.title,
        artist: album.artist,
        albumTitle: album.title,
        coverImage: album.coverImage,
        duration: parseInt(track.duration.split(':')[0]) * 60 + parseInt(track.duration.split(':')[1]),
        audioUrl: track.preview
      }
      
      playTrack(currentTrack, allTracks)
    }
  }

  const handlePlayAll = () => {
    if (album && album.tracks.length > 0) {
      // Add all tracks to queue and play first track
      const allTracks = album.tracks.map(track => ({
        id: track.id,
        title: track.title,
        artist: album.artist,
        albumTitle: album.title,
        coverImage: album.coverImage,
        duration: parseInt(track.duration.split(':')[0]) * 60 + parseInt(track.duration.split(':')[1]),
        audioUrl: track.preview
      }))
      
      // Play first track with full album as queue
      playTrack(allTracks[0], allTracks)
    }
  }

  const handleAddToPlaylist = (track: Track, e: React.MouseEvent) => {
    e.stopPropagation()
    if (album) {
      setSelectedTrack(track)
      setIsAddToPlaylistOpen(true)
    }
  }
  // Use handleAddToPlaylist to avoid unused warning
  void handleAddToPlaylist

  if (loading || !album) {
    return (
      <div className={styles.container}>
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
          <h2 style={{ color: '#fff' }}>Loading album...</h2>
        </motion.div>
      </div>
    )
  }

  return (
    <div className={styles.container}>
      <motion.div className={styles.header} initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
        <motion.div className={styles.coverImage} initial={{ scale: 0.9 }} animate={{ scale: 1 }} transition={{ duration: 0.5 }}>
          <img src={album.coverImage} alt={album.title} />
        </motion.div>
        <div className={styles.albumInfo}>
          <motion.div className={styles.type} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
            ALBUM
          </motion.div>
          <motion.h1 className={styles.title} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
            {album.title}
          </motion.h1>
          <motion.div className={styles.metadata} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
            <Link to={`/artist/${album.artistId}`} className={styles.artist}>{album.artist}</Link>
            <span className={styles.dot}>•</span>
            <span>{album.releaseDate.split(',')[1]}</span>
            <span className={styles.dot}>•</span>
            <span>{album.totalTracks} songs</span>
            <span className={styles.dot}>•</span>
            <span>{album.duration}</span>
          </motion.div>
        </div>
      </motion.div>

      <motion.div className={styles.controls} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }}>
        <button className={styles.playButton} onClick={handlePlayAll}>
          <Play size={28} fill="currentColor" />
        </button>
        <button className={`${styles.iconButton} ${liked ? styles.liked : ''}`} onClick={() => setLiked(!liked)}>
          <Heart size={32} fill={liked ? 'currentColor' : 'none'} />
        </button>
        <button className={styles.iconButton}>
          <Share2 size={28} />
        </button>
        <button className={styles.iconButton}>
          <MoreHorizontal size={28} />
        </button>
      </motion.div>

      <motion.div className={styles.tracklist} initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.5 }}>
        <div className={styles.trackHeader}>
          <div className={styles.trackNumber}>#</div>
          <div className={styles.trackTitle}>TITLE</div>
          <div className={styles.trackDuration}>
            <Clock size={16} />
          </div>
        </div>
        {album.tracks.map((track, index) => (
          <motion.div
            key={track.id}
            className={styles.trackRow}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.5 + index * 0.03 }}
            onHoverStart={() => setHoveredTrack(track.id)}
            onHoverEnd={() => setHoveredTrack(null)}
            onClick={() => handlePlayTrack(track)}
          >
            <div className={styles.trackNumber}>
              {hoveredTrack === track.id ? (
                <Play size={16} fill="currentColor" />
              ) : (
                <span>{track.number}</span>
              )}
            </div>
            <div className={styles.trackTitle}>
              <span>{track.title}</span>
              {track.explicit && <span className={styles.explicit}>E</span>}
            </div>
            <div className={styles.trackDuration}>{track.duration}</div>
            <button
              className={styles.addToPlaylistButton}
              onClick={(e) => {
                e.stopPropagation()
                setSelectedTrack(track)
                setIsAddToPlaylistOpen(true)
              }}
              title="Add to Playlist"
            >
              <Plus size={16} />
            </button>
          </motion.div>
        ))}
      </motion.div>

      <motion.div className={styles.albumDetails} initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.6 }}>
        <div className={styles.detailRow}>
          <span className={styles.detailLabel}>Release Date</span>
          <span className={styles.detailValue}>{album.releaseDate}</span>
        </div>
        <div className={styles.detailRow}>
          <span className={styles.detailLabel}>Label</span>
          <span className={styles.detailValue}>{album.label}</span>
        </div>
      </motion.div>

      <motion.section className={styles.similarSection} initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.7 }}>
        <h2>More by {album.artist}</h2>
        <div className={styles.similarGrid}>
          {similarAlbums.map((similarAlbum: any) => (
            <Link key={similarAlbum.id} to={`/album/${similarAlbum.id}`} className={styles.similarCard}>
              <div className={styles.similarImage}>
                <img src={similarAlbum.cover_medium} alt={similarAlbum.title} />
                <div className={styles.similarPlay}>
                  <Play size={20} fill="currentColor" />
                </div>
              </div>
              <div className={styles.similarTitle}>{similarAlbum.title}</div>
              <div className={styles.similarArtist}>{album.artist}</div>
            </Link>
          ))}
        </div>
      </motion.section>

      {/* Add to Playlist Modal */}
      {selectedTrack && album && (
        <AddToPlaylistModal
          isOpen={isAddToPlaylistOpen}
          onClose={() => {
            setIsAddToPlaylistOpen(false)
            setSelectedTrack(null)
          }}
          track={{
            id: selectedTrack.id,
            title: selectedTrack.title,
            artist: album.artist,
            albumTitle: album.title,
            coverImage: album.coverImage,
            duration: parseInt(selectedTrack.duration.split(':')[0]) * 60 + parseInt(selectedTrack.duration.split(':')[1]),
            audioUrl: selectedTrack.preview
          }}
        />
      )}
    </div>
  )
}

export default AlbumDetailPage
