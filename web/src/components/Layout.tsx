/**
 * Main Layout Component - Top Navigation Design
 */

import { Outlet, Link, useLocation } from 'react-router-dom'
import { useState, useEffect } from 'react'
import { Search, Library, User, Settings, Play, Volume2, SkipBack, SkipForward, Pause, Heart, Radio, TrendingUp, Shuffle, Repeat, Repeat1, ListMusic, Plus, Keyboard, Music2, Activity } from 'lucide-react'
import { motion } from 'framer-motion'
import { usePlayer } from '../contexts/PlayerContext'
import { storageService } from '../services/storage.service'
import QueuePanel from './QueuePanel'
import AddToPlaylistModal from './AddToPlaylistModal'
import PlaybackSpeedControl from './PlaybackSpeedControl'
import KeyboardShortcutsModal from './KeyboardShortcutsModal'
import { LyricsPanel } from './LyricsPanel'
import { AudioVisualizer } from './AudioVisualizer'
import { useKeyboardShortcuts } from '../hooks/useKeyboardShortcuts'
import { useSwipeGesture } from '../hooks/useSwipeGesture'
import styles from './Layout.module.css'

function Layout() {
  const location = useLocation()
  const { currentTrack, isPlaying, progress, volume, shuffle, repeat, queue, playbackSpeed, playPause, skipNext, skipPrevious, seek, setVolume, toggleShuffle, toggleRepeat, setPlaybackSpeed } = usePlayer()
  const [isLiked, setIsLiked] = useState(false)
  const [isQueueOpen, setIsQueueOpen] = useState(false)
  const [isAddToPlaylistOpen, setIsAddToPlaylistOpen] = useState(false)
  const [isShortcutsOpen, setIsShortcutsOpen] = useState(false)
  const [isLyricsOpen, setIsLyricsOpen] = useState(false)
  const [showVisualizer, setShowVisualizer] = useState(false)

  // Enable keyboard shortcuts
  useKeyboardShortcuts()

  // Enable touch gestures for mobile (swipe left/right to skip tracks)
  useSwipeGesture({
    onSwipeLeft: () => {
      if (currentTrack && window.innerWidth <= 968) {
        skipNext()
      }
    },
    onSwipeRight: () => {
      if (currentTrack && window.innerWidth <= 968) {
        skipPrevious()
      }
    },
  }, {
    threshold: 75, // Require 75px swipe to trigger
    timeout: 400,  // Allow up to 400ms for swipe
  })

  // Listen for "?" key to toggle shortcuts modal
  useEffect(() => {
    const handleKeyPress = (e: KeyboardEvent) => {
      if (e.key === '?' && e.shiftKey) {
        setIsShortcutsOpen(prev => !prev)
      }
    }
    window.addEventListener('keydown', handleKeyPress)
    return () => window.removeEventListener('keydown', handleKeyPress)
  }, [])

  // Check if current track is liked
  useEffect(() => {
    if (currentTrack) {
      const likedSongs = storageService.getLikedSongs()
      setIsLiked(likedSongs.some(song => song.id === currentTrack.id))
    } else {
      setIsLiked(false)
    }
  }, [currentTrack])

  const handleToggleLike = () => {
    if (!currentTrack) return
    
    if (isLiked) {
      storageService.unlikeTrack(currentTrack.id)
      setIsLiked(false)
    } else {
      storageService.likeTrack(currentTrack)
      setIsLiked(true)
    }
  }

  const navItems = [
    { path: '/', icon: Radio, label: 'Discover' },
    { path: '/search', icon: Search, label: 'Search' },
    { path: '/hits', icon: TrendingUp, label: 'Hits' },
    { path: '/library', icon: Library, label: 'Library' },
    { path: '/profile', icon: User, label: 'Profile' },
    { path: '/settings', icon: Settings, label: 'Settings' }
  ]

  const isActive = (path: string) => location.pathname === path

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }

  return (
    <div className={styles.layout}>
      {/* Top Navigation */}
      <nav className={styles.navbar}>
        <div className={styles.navContent}>
          {/* Logo */}
          <Link to="/" className={styles.logo}>
            <div className={styles.logoIcon}>
              <Play size={24} fill="currentColor" />
            </div>
            <span className={styles.logoText}>JetStream</span>
          </Link>

          {/* Navigation Links */}
          <div className={styles.navLinks}>
            {navItems.map((item) => {
              const Icon = item.icon
              const active = isActive(item.path)
              return (
                <Link
                  key={item.path}
                  to={item.path}
                  className={`${styles.navLink} ${active ? styles.active : ''}`}
                >
                  <Icon size={20} />
                  <span>{item.label}</span>
                  {active && (
                    <motion.div
                      className={styles.activeIndicator}
                      layoutId="activeTab"
                      transition={{ type: 'spring', stiffness: 500, damping: 30 }}
                    />
                  )}
                </Link>
              )
            })}
          </div>

          {/* Right Actions */}
          <div className={styles.navActions}>
            <button 
              className={styles.actionButton}
              onClick={() => setShowVisualizer(prev => !prev)}
              title="Toggle visualizer"
            >
              <Activity size={20} />
            </button>
            <button 
              className={styles.actionButton}
              onClick={() => setIsLyricsOpen(prev => !prev)}
              title="Show lyrics"
            >
              <Music2 size={20} />
            </button>
            <button 
              className={styles.actionButton}
              onClick={() => setIsShortcutsOpen(true)}
              title="Keyboard shortcuts (?)"
            >
              <Keyboard size={20} />
            </button>
            <Link to="/library" className={styles.actionButton} title="Liked Songs">
              <Heart size={20} />
            </Link>
            <Link to="/profile" className={styles.actionButton} title="Profile">
              <User size={20} />
            </Link>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className={styles.main}>
        <div className={styles.content}>
          {/* Audio Visualizer */}
          {showVisualizer && currentTrack && (
            <div style={{ marginBottom: '2rem' }}>
              <AudioVisualizer />
            </div>
          )}
          <Outlet />
        </div>
      </main>

      {/* Bottom Player Bar */}
      <div className={styles.playerBar}>
        <div className={styles.playerContent}>
          {/* Track Info */}
          <div className={styles.trackInfo}>
            <div className={styles.trackImage}>
              <img 
                src={currentTrack?.coverImage || 'https://e-cdns-images.dzcdn.net/images/cover/2e18122a1c929a5f23cfdfc8985e6c67/250x250-000000-80-0-0.jpg'} 
                alt={currentTrack?.title || 'No track playing'}
              />
            </div>
            <div className={styles.trackDetails}>
              <div className={styles.trackName}>{currentTrack?.title || 'No track playing'}</div>
              <div className={styles.trackArtist}>{currentTrack?.artist || 'Select a track'}</div>
            </div>
            <button 
              className={`${styles.likeButton} ${isLiked ? styles.liked : ''}`}
              onClick={handleToggleLike}
              disabled={!currentTrack}
              title={isLiked ? 'Unlike' : 'Like'}
            >
              <Heart size={18} fill={isLiked ? 'currentColor' : 'none'} />
            </button>
            <button 
              className={styles.likeButton}
              onClick={() => setIsAddToPlaylistOpen(true)}
              disabled={!currentTrack}
              title="Add to Playlist"
            >
              <Plus size={18} />
            </button>
          </div>

          {/* Player Controls */}
          <div className={styles.playerControls}>
            <div className={styles.controlButtons}>
              <button 
                className={`${styles.controlButton} ${shuffle ? styles.active : ''}`}
                onClick={toggleShuffle}
                title="Shuffle"
              >
                <Shuffle size={18} />
              </button>
              <button className={styles.controlButton} onClick={skipPrevious}>
                <SkipBack size={20} />
              </button>
              <button 
                className={styles.playButton}
                onClick={playPause}
                disabled={!currentTrack}
              >
                {isPlaying ? <Pause size={24} fill="currentColor" /> : <Play size={24} fill="currentColor" />}
              </button>
              <button className={styles.controlButton} onClick={skipNext}>
                <SkipForward size={20} />
              </button>
              <button 
                className={`${styles.controlButton} ${repeat !== 'off' ? styles.active : ''}`}
                onClick={toggleRepeat}
                title={`Repeat: ${repeat}`}
              >
                {repeat === 'one' ? <Repeat1 size={18} /> : <Repeat size={18} />}
              </button>
              <button 
                className={`${styles.controlButton} ${styles.queueButton}`}
                onClick={() => setIsQueueOpen(true)}
                title="Queue"
              >
                <ListMusic size={18} />
                {queue.length > 0 && (
                  <span className={styles.queueBadge}>{queue.length}</span>
                )}
              </button>
            </div>
            <div className={styles.progressBar}>
              <span className={styles.timeText}>{formatTime((progress / 100) * (currentTrack?.duration || 0))}</span>
              <div 
                className={styles.progressTrack}
                onClick={(e) => {
                  const rect = e.currentTarget.getBoundingClientRect()
                  const x = e.clientX - rect.left
                  const percentage = (x / rect.width) * 100
                  seek(percentage)
                }}
              >
                <motion.div 
                  className={styles.progressFill}
                  style={{ width: `${progress}%` }}
                />
              </div>
              <span className={styles.timeText}>{formatTime(currentTrack?.duration || 0)}</span>
            </div>
          </div>

          {/* Playback Speed & Volume Control */}
          <div className={styles.volumeControl}>
            <PlaybackSpeedControl 
              currentSpeed={playbackSpeed}
              onSpeedChange={setPlaybackSpeed}
            />
            <Volume2 size={18} />
            <div 
              className={styles.volumeSlider}
              onClick={(e) => {
                const rect = e.currentTarget.getBoundingClientRect()
                const x = e.clientX - rect.left
                const percentage = x / rect.width
                setVolume(percentage)
              }}
            >
              <div className={styles.volumeTrack}>
                <div className={styles.volumeFill} style={{ width: `${volume * 100}%` }} />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Queue Panel */}
      <QueuePanel 
        isOpen={isQueueOpen} 
        onClose={() => setIsQueueOpen(false)} 
      />

      {/* Add to Playlist Modal */}
      {currentTrack && (
        <AddToPlaylistModal
          isOpen={isAddToPlaylistOpen}
          onClose={() => setIsAddToPlaylistOpen(false)}
          track={currentTrack}
        />
      )}

      {/* Keyboard Shortcuts Modal */}
      <KeyboardShortcutsModal
        isOpen={isShortcutsOpen}
        onClose={() => setIsShortcutsOpen(false)}
      />

      {/* Lyrics Panel */}
      <LyricsPanel
        isOpen={isLyricsOpen}
        onClose={() => setIsLyricsOpen(false)}
      />
    </div>
  )
}

export default Layout
