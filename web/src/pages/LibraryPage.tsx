import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { Music, Heart, ListMusic, Clock, Play, Trash2, Plus, X, ArrowUpDown } from 'lucide-react'
import { storageService, Track, Playlist } from '../services/storage.service'
import { usePlayer } from '../contexts/PlayerContext'
import AddToPlaylistModal from '../components/AddToPlaylistModal'
import styles from './LibraryPage.module.css'

type TabType = 'liked' | 'playlists' | 'recent'
type SortType = 'dateAdded' | 'title' | 'artist' | 'duration'

function LibraryPage() {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  
  // Get initial tab from URL parameter or default to 'liked'
  const getInitialTab = (): TabType => {
    const tabParam = searchParams.get('tab')
    if (tabParam === 'liked' || tabParam === 'playlists' || tabParam === 'recent') {
      return tabParam
    }
    return 'liked'
  }
  
  const [activeTab, setActiveTab] = useState<TabType>(getInitialTab())
  const [likedSongs, setLikedSongs] = useState<Track[]>([])
  const [playlists, setPlaylists] = useState<Playlist[]>([])
  const [recentlyPlayed, setRecentlyPlayed] = useState<Track[]>([])
  const [sortBy, setSortBy] = useState<SortType>('dateAdded')
  const [showCreatePlaylist, setShowCreatePlaylist] = useState(false)
  const [newPlaylistName, setNewPlaylistName] = useState('')
  const [newPlaylistDesc, setNewPlaylistDesc] = useState('')
  const [isAddToPlaylistOpen, setIsAddToPlaylistOpen] = useState(false)
  const [selectedTrack, setSelectedTrack] = useState<Track | null>(null)
  const { playTrack } = usePlayer()

  const loadData = () => {
    setLikedSongs(storageService.getLikedSongs())
    setPlaylists(storageService.getPlaylists())
    setRecentlyPlayed(storageService.getRecentlyPlayed())
  }

  useEffect(() => {
    loadData()
  }, [])

  // Update tab when URL parameter changes
  useEffect(() => {
    const tabParam = searchParams.get('tab')
    if (tabParam === 'liked' || tabParam === 'playlists' || tabParam === 'recent') {
      setActiveTab(tabParam)
    }
  }, [searchParams])

  const tabs = [
    { id: 'liked' as TabType, label: 'Liked Songs', icon: Heart, count: likedSongs.length },
    { id: 'playlists' as TabType, label: 'Playlists', icon: ListMusic, count: playlists.length },
    { id: 'recent' as TabType, label: 'Recently Played', icon: Clock, count: recentlyPlayed.length },
  ]

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }

  const handleUnlike = (trackId: string) => {
    storageService.unlikeTrack(trackId)
    loadData()
  }

  const handleDeletePlaylist = (playlistId: string) => {
    if (window.confirm('Are you sure you want to delete this playlist?')) {
      storageService.deletePlaylist(playlistId)
      loadData()
    }
  }

  const handleCreatePlaylist = () => {
    if (newPlaylistName.trim()) {
      console.log('Creating playlist:', newPlaylistName.trim())
      const newPlaylist = storageService.createPlaylist(newPlaylistName.trim(), newPlaylistDesc.trim())
      console.log('Playlist created:', newPlaylist)
      setNewPlaylistName('')
      setNewPlaylistDesc('')
      setShowCreatePlaylist(false)
      loadData()
      console.log('Playlists after creation:', storageService.getPlaylists())
    }
  }

  const handlePlayTrack = (track: Track) => {
    playTrack(track)
  }

  const getSortedTracks = (tracks: Track[]) => {
    const sorted = [...tracks]
    switch (sortBy) {
      case 'title':
        return sorted.sort((a, b) => a.title.localeCompare(b.title))
      case 'artist':
        return sorted.sort((a, b) => a.artist.localeCompare(b.artist))
      case 'duration':
        return sorted.sort((a, b) => b.duration - a.duration)
      case 'dateAdded':
      default:
        return sorted.reverse() // Most recent first
    }
  }

  const renderTrackList = (tracks: Track[], showUnlike = false) => {
    if (tracks.length === 0) return null

    const sortedTracks = getSortedTracks(tracks)

    return (
      <div className={styles.trackListContainer}>
        {/* Sort Controls */}
        <div className={styles.sortControls}>
          <button
            className={`${styles.sortButton} ${sortBy === 'dateAdded' ? styles.active : ''}`}
            onClick={() => setSortBy('dateAdded')}
          >
            <ArrowUpDown size={16} />
            Date Added
          </button>
          <button
            className={`${styles.sortButton} ${sortBy === 'title' ? styles.active : ''}`}
            onClick={() => setSortBy('title')}
          >
            <ArrowUpDown size={16} />
            Title
          </button>
          <button
            className={`${styles.sortButton} ${sortBy === 'artist' ? styles.active : ''}`}
            onClick={() => setSortBy('artist')}
          >
            <ArrowUpDown size={16} />
            Artist
          </button>
          <button
            className={`${styles.sortButton} ${sortBy === 'duration' ? styles.active : ''}`}
            onClick={() => setSortBy('duration')}
          >
            <ArrowUpDown size={16} />
            Duration
          </button>
        </div>

        {/* Track List */}
        <div className={styles.trackList}>
          <AnimatePresence mode="popLayout">
            {sortedTracks.map((track, index) => (
              <motion.div
                key={track.id}
                className={styles.trackItem}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, x: -100 }}
                transition={{ delay: index * 0.03 }}
              >
                <div className={styles.trackNumber}>{index + 1}</div>
                <div className={styles.trackImageWrapper}>
                  <img src={track.coverImage} alt={track.title} className={styles.trackImage} />
                  <button className={styles.trackPlayButton} onClick={() => handlePlayTrack(track)}>
                    <Play size={20} fill="currentColor" />
                  </button>
                </div>
                <div className={styles.trackInfo}>
                  <div className={styles.trackTitle}>{track.title}</div>
                  <div className={styles.trackArtist}>{track.artist}</div>
                </div>
                <div className={styles.trackAlbum}>{track.albumTitle}</div>
                <div className={styles.trackDuration}>{formatDuration(track.duration)}</div>
                <button 
                  className={styles.trackAddToPlaylist} 
                  onClick={(e) => {
                    e.stopPropagation()
                    setSelectedTrack(track)
                    setIsAddToPlaylistOpen(true)
                  }}
                  title="Add to Playlist"
                >
                  <Plus size={18} />
                </button>
                {showUnlike && (
                  <button className={styles.trackUnlike} onClick={() => handleUnlike(track.id)}>
                    <Heart size={20} fill="#1ed760" color="#1ed760" />
                  </button>
                )}
              </motion.div>
            ))}
          </AnimatePresence>
        </div>
      </div>
    )
  }

  return (
    <div className={styles.container}>
      <motion.div className={styles.header} initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
        <h1 className={styles.title}>
          <Music className={styles.titleIcon} />
          Your Library
        </h1>
        <p className={styles.subtitle}>All your music in one place</p>
      </motion.div>

      <div className={styles.tabs}>
        {tabs.map((tab) => {
          const Icon = tab.icon
          return (
            <button
              key={tab.id}
              className={`${styles.tab} ${activeTab === tab.id ? styles.activeTab : ''}`}
              onClick={() => setActiveTab(tab.id)}
            >
              <Icon size={20} />
              <span>{tab.label}</span>
              {tab.count > 0 && <span className={styles.badge}>{tab.count}</span>}
            </button>
          )
        })}
      </div>

      <div className={styles.content}>
        {/* Liked Songs Tab */}
        {activeTab === 'liked' && (
          <>
            {likedSongs.length === 0 ? (
              <div className={styles.emptyState}>
                <Heart size={64} />
                <h3>No liked songs yet</h3>
                <p>Songs you like will appear here</p>
              </div>
            ) : (
              renderTrackList(likedSongs, true)
            )}
          </>
        )}

        {/* Playlists Tab */}
        {activeTab === 'playlists' && (
          <>
            <div className={styles.playlistHeader}>
              <button className={styles.createPlaylistButton} onClick={() => setShowCreatePlaylist(true)}>
                <Plus size={20} />
                Create Playlist
              </button>
            </div>

            {playlists.length === 0 ? (
              <div className={styles.emptyState}>
                <ListMusic size={64} />
                <h3>No playlists yet</h3>
                <p>Create a playlist to organize your music</p>
              </div>
            ) : (
              <div className={styles.playlistGrid}>
                {playlists.map((playlist) => (
                  <motion.div
                    key={playlist.id}
                    className={styles.playlistCard}
                    whileHover={{ y: -4 }}
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    onClick={() => navigate(`/playlist/${playlist.id}`)}
                    style={{ cursor: 'pointer' }}
                  >
                    <div className={styles.playlistCover}>
                      {playlist.coverImage ? (
                        <img src={playlist.coverImage} alt={playlist.name} />
                      ) : (
                        <div className={styles.playlistCoverPlaceholder}>
                          <ListMusic size={48} />
                        </div>
                      )}
                    </div>
                    <div className={styles.playlistInfo}>
                      <h3>{playlist.name}</h3>
                      <p>{playlist.description || 'No description'}</p>
                      <span>{playlist.tracks.length} tracks</span>
                    </div>
                    <button
                      className={styles.deletePlaylistButton}
                      onClick={(e) => {
                        e.stopPropagation()
                        handleDeletePlaylist(playlist.id)
                      }}
                    >
                      <Trash2 size={18} />
                    </button>
                  </motion.div>
                ))}
              </div>
            )}
          </>
        )}

        {/* Recently Played Tab */}
        {activeTab === 'recent' && (
          <>
            {recentlyPlayed.length === 0 ? (
              <div className={styles.emptyState}>
                <Clock size={64} />
                <h3>No recently played tracks</h3>
                <p>Tracks you play will appear here</p>
              </div>
            ) : (
              renderTrackList(recentlyPlayed, false)
            )}
          </>
        )}
      </div>

      {/* Create Playlist Modal */}
      <AnimatePresence>
        {showCreatePlaylist && (
          <motion.div
            className={styles.modalOverlay}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setShowCreatePlaylist(false)}
          >
            <motion.div
              className={styles.modal}
              initial={{ scale: 0.9, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.9, y: 20 }}
              onClick={(e: React.MouseEvent) => e.stopPropagation()}
            >
              <div className={styles.modalHeader}>
                <h2>Create Playlist</h2>
                <button onClick={() => setShowCreatePlaylist(false)}>
                  <X size={24} />
                </button>
              </div>
              <div className={styles.modalBody}>
                <input
                  type="text"
                  placeholder="Playlist name"
                  value={newPlaylistName}
                  onChange={(e) => setNewPlaylistName(e.target.value)}
                  className={styles.input}
                  autoFocus
                />
                <textarea
                  placeholder="Description (optional)"
                  value={newPlaylistDesc}
                  onChange={(e) => setNewPlaylistDesc(e.target.value)}
                  className={styles.textarea}
                  rows={3}
                />
              </div>
              <div className={styles.modalFooter}>
                <button className={styles.cancelButton} onClick={() => setShowCreatePlaylist(false)}>
                  Cancel
                </button>
                <button
                  className={styles.createButton}
                  onClick={handleCreatePlaylist}
                  disabled={!newPlaylistName.trim()}
                >
                  Create
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Add to Playlist Modal */}
      {selectedTrack && (
        <AddToPlaylistModal
          isOpen={isAddToPlaylistOpen}
          onClose={() => {
            setIsAddToPlaylistOpen(false)
            setSelectedTrack(null)
          }}
          track={selectedTrack}
        />
      )}
    </div>
  )
}

export default LibraryPage
