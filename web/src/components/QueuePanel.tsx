/**
 * Queue Panel - Slide drawer showing upcoming tracks
 * Supports drag-and-drop reordering
 */

import { motion, AnimatePresence, Reorder } from 'framer-motion'
import { X, Music, Trash2, Play, GripVertical } from 'lucide-react'
import { usePlayer } from '../contexts/PlayerContext'
import { useState, useEffect } from 'react'
import styles from './QueuePanel.module.css'

interface Track {
  id: string
  title: string
  artist: string
  albumTitle: string
  coverImage: string
  duration: number
  audioUrl: string
}

interface QueuePanelProps {
  isOpen: boolean
  onClose: () => void
}

function QueuePanel({ isOpen, onClose }: QueuePanelProps) {
  const { queue, currentTrack, playTrack, clearQueue, setQueue } = usePlayer()
  const [localQueue, setLocalQueue] = useState<Track[]>([])

  // Sync local queue with global queue
  useEffect(() => {
    setLocalQueue([...queue])
  }, [queue])

  const handleReorder = (reorderedQueue: Track[]) => {
    setLocalQueue(reorderedQueue)
    setQueue(reorderedQueue)
  }

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }

  const handleClearQueue = () => {
    if (window.confirm('Clear all tracks from queue?')) {
      clearQueue()
    }
  }

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

          {/* Drawer */}
          <motion.div
            className={styles.drawer}
            initial={{ x: '100%' }}
            animate={{ x: 0 }}
            exit={{ x: '100%' }}
            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
          >
            {/* Header */}
            <div className={styles.header}>
              <div className={styles.headerTitle}>
                <Music size={20} />
                <h2>Queue</h2>
                <span className={styles.count}>
                  {localQueue.length} {localQueue.length === 1 ? 'track' : 'tracks'}
                </span>
              </div>
              <div className={styles.headerActions}>
                {localQueue.length > 0 && (
                  <button
                    className={styles.clearButton}
                    onClick={handleClearQueue}
                    title="Clear queue"
                  >
                    <Trash2 size={18} />
                    Clear
                  </button>
                )}
                <button
                  className={styles.closeButton}
                  onClick={onClose}
                  title="Close"
                >
                  <X size={20} />
                </button>
              </div>
            </div>

            {/* Now Playing */}
            {currentTrack && (
              <div className={styles.nowPlaying}>
                <div className={styles.nowPlayingLabel}>Now Playing</div>
                <div className={styles.nowPlayingTrack}>
                  <img src={currentTrack.coverImage} alt={currentTrack.title} />
                  <div className={styles.nowPlayingInfo}>
                    <div className={styles.nowPlayingTitle}>{currentTrack.title}</div>
                    <div className={styles.nowPlayingArtist}>{currentTrack.artist}</div>
                  </div>
                  <div className={styles.playingIndicator}>
                    <div className={styles.bar}></div>
                    <div className={styles.bar}></div>
                    <div className={styles.bar}></div>
                  </div>
                </div>
              </div>
            )}

            {/* Queue List */}
            <div className={styles.queueList}>
              {localQueue.length === 0 ? (
                <div className={styles.emptyState}>
                  <Music size={48} />
                  <p>No tracks in queue</p>
                  <span>Add tracks to see them here</span>
                </div>
              ) : (
                <>
                  <div className={styles.upNextLabel}>Up Next • Drag to reorder</div>
                  <Reorder.Group
                    axis="y"
                    values={localQueue}
                    onReorder={handleReorder}
                    as="ul"
                    style={{ listStyle: 'none', padding: 0, margin: 0 }}
                  >
                    {localQueue.map((track, index) => (
                      <Reorder.Item
                        key={track.id}
                        value={track}
                        as="li"
                        className={styles.queueItem}
                        style={{ listStyle: 'none' }}
                        whileDrag={{ 
                          scale: 1.02, 
                          boxShadow: '0 10px 30px rgba(0,0,0,0.5)',
                          backgroundColor: 'rgba(30, 215, 96, 0.15)',
                          zIndex: 999
                        }}
                      >
                        <div className={styles.dragHandle}>
                          <GripVertical size={16} />
                        </div>
                        <div className={styles.queueNumber}>{index + 1}</div>
                        <img
                          src={track.coverImage}
                          alt={track.title}
                          className={styles.queueImage}
                        />
                        <div className={styles.queueInfo}>
                          <div className={styles.queueTitle}>{track.title}</div>
                          <div className={styles.queueArtist}>{track.artist}</div>
                        </div>
                        <div className={styles.queueDuration}>
                          {formatDuration(track.duration)}
                        </div>
                        <button
                          className={styles.playNowButton}
                          onClick={(e) => {
                            e.stopPropagation()
                            playTrack(track)
                          }}
                          title="Play now"
                        >
                          <Play size={14} fill="currentColor" />
                        </button>
                      </Reorder.Item>
                    ))}
                  </Reorder.Group>
                </>
              )}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

export default QueuePanel
