/**
 * Add to Playlist Modal - Select playlist to add track
 */

import { motion, AnimatePresence } from 'framer-motion'
import { X, Plus, ListMusic, Music } from 'lucide-react'
import { useState, useEffect } from 'react'
import { storageService, Playlist, Track } from '../services/storage.service'
import styles from './AddToPlaylistModal.module.css'

interface AddToPlaylistModalProps {
  isOpen: boolean
  track: Track | null
  onClose: () => void
}

function AddToPlaylistModal({ isOpen, track, onClose }: AddToPlaylistModalProps) {
  const [playlists, setPlaylists] = useState<Playlist[]>([])
  const [isCreatingNew, setIsCreatingNew] = useState(false)
  const [newPlaylistName, setNewPlaylistName] = useState('')
  const [newPlaylistDescription, setNewPlaylistDescription] = useState('')

  useEffect(() => {
    if (isOpen) {
      loadPlaylists()
    }
  }, [isOpen])

  const loadPlaylists = () => {
    const allPlaylists = storageService.getPlaylists()
    setPlaylists(allPlaylists)
  }

  const handleAddToPlaylist = (playlistId: string) => {
    if (!track) return

    storageService.addTrackToPlaylist(playlistId, track)
    
    // Show success feedback
    const playlist = playlists.find(p => p.id === playlistId)
    alert(`Added "${track.title}" to "${playlist?.name}"`)
    
    onClose()
  }

  const handleCreateAndAdd = () => {
    if (!track || !newPlaylistName.trim()) return

    // Create new playlist
    console.log('Creating playlist:', newPlaylistName.trim())
    const newPlaylist = storageService.createPlaylist(
      newPlaylistName.trim(),
      newPlaylistDescription.trim()
    )
    console.log('Playlist created:', newPlaylist)

    // Add track to new playlist
    storageService.addTrackToPlaylist(newPlaylist.id, track)
    console.log('Track added to playlist')

    alert(`Created "${newPlaylistName}" and added "${track.title}"`)
    
    // Reset form
    setNewPlaylistName('')
    setNewPlaylistDescription('')
    setIsCreatingNew(false)
    loadPlaylists()
    onClose()
  }

  if (!track) return null

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Overlay */}
          <motion.div
            className={styles.overlay}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
          />

          {/* Modal */}
          <motion.div
            className={styles.modal}
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
          >
            {/* Header */}
            <div className={styles.header}>
              <div className={styles.headerTitle}>
                <ListMusic size={20} />
                <h2>Add to Playlist</h2>
              </div>
              <button className={styles.closeButton} onClick={onClose}>
                <X size={20} />
              </button>
            </div>

            {/* Track Info */}
            <div className={styles.trackInfo}>
              <img src={track.coverImage} alt={track.title} />
              <div className={styles.trackDetails}>
                <div className={styles.trackTitle}>{track.title}</div>
                <div className={styles.trackArtist}>{track.artist}</div>
              </div>
            </div>

            {/* Create New Playlist */}
            {!isCreatingNew ? (
              <button
                className={styles.createNewButton}
                onClick={() => setIsCreatingNew(true)}
              >
                <Plus size={18} />
                Create New Playlist
              </button>
            ) : (
              <div className={styles.createForm}>
                <input
                  type="text"
                  placeholder="Playlist name"
                  value={newPlaylistName}
                  onChange={(e) => setNewPlaylistName(e.target.value)}
                  autoFocus
                />
                <input
                  type="text"
                  placeholder="Description (optional)"
                  value={newPlaylistDescription}
                  onChange={(e) => setNewPlaylistDescription(e.target.value)}
                />
                <div className={styles.createFormButtons}>
                  <button
                    className={styles.cancelButton}
                    onClick={() => {
                      setIsCreatingNew(false)
                      setNewPlaylistName('')
                      setNewPlaylistDescription('')
                    }}
                  >
                    Cancel
                  </button>
                  <button
                    className={styles.createButton}
                    onClick={handleCreateAndAdd}
                    disabled={!newPlaylistName.trim()}
                  >
                    Create & Add
                  </button>
                </div>
              </div>
            )}

            {/* Playlist List */}
            <div className={styles.playlistList}>
              {playlists.length === 0 ? (
                <div className={styles.emptyState}>
                  <Music size={48} />
                  <p>No playlists yet</p>
                  <span>Create your first playlist above</span>
                </div>
              ) : (
                <>
                  <div className={styles.sectionTitle}>Your Playlists</div>
                  {playlists.map((playlist) => {
                    const alreadyInPlaylist = playlist.tracks.some(t => t.id === track.id)
                    
                    return (
                      <motion.button
                        key={playlist.id}
                        className={`${styles.playlistItem} ${alreadyInPlaylist ? styles.added : ''}`}
                        onClick={() => !alreadyInPlaylist && handleAddToPlaylist(playlist.id)}
                        disabled={alreadyInPlaylist}
                        whileHover={!alreadyInPlaylist ? { x: 4 } : {}}
                      >
                        <div className={styles.playlistCover}>
                          {playlist.coverImage ? (
                            <img src={playlist.coverImage} alt={playlist.name} />
                          ) : (
                            <div className={styles.playlistCoverPlaceholder}>
                              <ListMusic size={24} />
                            </div>
                          )}
                        </div>
                        <div className={styles.playlistInfo}>
                          <div className={styles.playlistName}>{playlist.name}</div>
                          <div className={styles.playlistCount}>
                            {playlist.tracks.length} {playlist.tracks.length === 1 ? 'track' : 'tracks'}
                          </div>
                        </div>
                        {alreadyInPlaylist && (
                          <span className={styles.addedBadge}>Added</span>
                        )}
                      </motion.button>
                    )
                  })}
                </>
              )}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

export default AddToPlaylistModal
