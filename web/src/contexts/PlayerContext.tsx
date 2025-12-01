import React, { createContext, useContext, useState, useRef, useCallback } from 'react'
import { storageService } from '../services/storage.service'

interface Track {
  id: string
  title: string
  artist: string
  albumTitle: string
  coverImage: string
  duration: number
  audioUrl: string
}

interface PlayerContextType {
  currentTrack: Track | null
  isPlaying: boolean
  progress: number
  volume: number
  queue: Track[]
  shuffle: boolean
  repeat: 'off' | 'one' | 'all'
  playbackSpeed: number
  equalizerEnabled: boolean
  equalizerGains: number[]
  audioElement: HTMLAudioElement | null
  analyserNode: AnalyserNode | null
  playTrack: (track: Track, queueTracks?: Track[]) => void
  playPause: () => void
  skipNext: () => void
  skipPrevious: () => void
  seek: (time: number) => void
  setVolume: (volume: number) => void
  addToQueue: (track: Track) => void
  clearQueue: () => void
  setQueue: (tracks: Track[]) => void
  toggleShuffle: () => void
  toggleRepeat: () => void
  reorderQueue: (startIndex: number, endIndex: number) => void
  setPlaybackSpeed: (speed: number) => void
  setEqualizerBand: (bandIndex: number, gain: number) => void
  setEqualizerPreset: (preset: string) => void
  toggleEqualizer: () => void
}

const PlayerContext = createContext<PlayerContextType | undefined>(undefined)

// Utility function to shuffle array
const shuffleArray = <T,>(array: T[]): T[] => {
  const shuffled = [...array]
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]
  }
  return shuffled
}

export const usePlayer = () => {
  const context = useContext(PlayerContext)
  if (!context) {
    throw new Error('usePlayer must be used within PlayerProvider')
  }
  return context
}

interface PlayerProviderProps {
  children: React.ReactNode
}

export const PlayerProvider: React.FC<PlayerProviderProps> = ({ children }) => {
  const [currentTrack, setCurrentTrack] = useState<Track | null>(null)
  const [isPlaying, setIsPlaying] = useState(false)
  const [progress, setProgress] = useState(0)
  const [volume, setVolumeState] = useState(0.7)
  const [queue, setQueue] = useState<Track[]>([])
  const [originalQueue, setOriginalQueue] = useState<Track[]>([])
  const [currentIndex, setCurrentIndex] = useState(-1)
  const [playHistory, setPlayHistory] = useState<Track[]>([])
  const [shuffle, setShuffle] = useState(false)
  const [repeat, setRepeat] = useState<'off' | 'one' | 'all'>('off')
  const [playbackSpeed, setPlaybackSpeedState] = useState(1.0)
  const [equalizerEnabled, setEqualizerEnabled] = useState(false)
  const [equalizerGains, setEqualizerGains] = useState([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  
  const audioRef = useRef<HTMLAudioElement | null>(null)
  const animationRef = useRef<number>()
  const audioContextRef = useRef<AudioContext | null>(null)
  const sourceNodeRef = useRef<MediaElementAudioSourceNode | null>(null)
  const gainNodeRef = useRef<GainNode | null>(null)
  const analyserNodeRef = useRef<AnalyserNode | null>(null)
  const equalizerNodesRef = useRef<BiquadFilterNode[]>([])

  // Initialize audio element and Web Audio API
  if (!audioRef.current) {
    audioRef.current = new Audio()
    audioRef.current.volume = volume
    audioRef.current.playbackRate = playbackSpeed
    audioRef.current.crossOrigin = 'anonymous'
    
    // Initialize Web Audio API for equalizer
    try {
      const AudioContext = window.AudioContext || (window as any).webkitAudioContext
      audioContextRef.current = new AudioContext()
      sourceNodeRef.current = audioContextRef.current.createMediaElementSource(audioRef.current)
      gainNodeRef.current = audioContextRef.current.createGain()
      
      // Create 10-band equalizer (frequencies: 32, 64, 125, 250, 500, 1k, 2k, 4k, 8k, 16k Hz)
      const frequencies = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
      equalizerNodesRef.current = frequencies.map((freq) => {
        const filter = audioContextRef.current!.createBiquadFilter()
        filter.type = 'peaking'
        filter.frequency.value = freq
        filter.Q.value = 1
        filter.gain.value = 0
        return filter
      })
      
      // Create analyser for visualizer
      analyserNodeRef.current = audioContextRef.current.createAnalyser()
      analyserNodeRef.current.fftSize = 256
      analyserNodeRef.current.smoothingTimeConstant = 0.8
      
      // Connect audio graph: source -> equalizers -> analyser -> gain -> destination
      let currentNode: AudioNode = sourceNodeRef.current
      equalizerNodesRef.current.forEach(filter => {
        currentNode.connect(filter)
        currentNode = filter
      })
      currentNode.connect(analyserNodeRef.current)
      analyserNodeRef.current.connect(gainNodeRef.current)
      gainNodeRef.current.connect(audioContextRef.current.destination)
    } catch (error) {
      console.warn('Web Audio API not supported:', error)
    }
  }

  // Update progress
  const updateProgress = useCallback(() => {
    if (audioRef.current) {
      const current = audioRef.current.currentTime
      const duration = audioRef.current.duration
      if (duration > 0) {
        setProgress((current / duration) * 100)
      }
    }
    animationRef.current = requestAnimationFrame(updateProgress)
  }, [])

  // Play a track
  const playTrack = useCallback((track: Track, queueTracks?: Track[]) => {
    if (audioRef.current) {
      // Resume audio context if suspended (browser autoplay policy)
      if (audioContextRef.current && audioContextRef.current.state === 'suspended') {
        audioContextRef.current.resume()
      }
      
      // Set current track immediately for UI feedback
      setCurrentTrack(track)
      setIsPlaying(true)
      
      // If queue tracks provided, set up the queue
      if (queueTracks && queueTracks.length > 0) {
        setOriginalQueue(queueTracks)
        setQueue(shuffle ? shuffleArray(queueTracks) : queueTracks)
        const index = queueTracks.findIndex(t => t.id === track.id)
        setCurrentIndex(index)
      } else {
        setCurrentIndex(-1)
      }
      
      // Add to history
      setPlayHistory(prev => [...prev, track])
      
      // Using Deezer 30s previews (reliable and simple)
      console.log('🎵 Playing track:', track.title, '-', track.artist, '(30s preview)')
      console.log('🔊 Audio URL:', track.audioUrl)
      console.log('🔊 AudioContext state:', audioContextRef.current?.state)
      
      // Play the track with Deezer preview URL
      audioRef.current.src = track.audioUrl
      audioRef.current.load()
      audioRef.current.play()
        .then(() => {
          setCurrentTrack(track)
          setIsPlaying(true)
          animationRef.current = requestAnimationFrame(updateProgress)
          // Add to recently played
          storageService.addToRecentlyPlayed(track)
        })
        .catch((error) => {
          console.error('Error playing track:', error)
          setIsPlaying(false)
        })
    }
  }, [updateProgress, shuffle])

  // Play/Pause toggle
  const playPause = useCallback(() => {
    if (!audioRef.current || !currentTrack) return

    if (isPlaying) {
      audioRef.current.pause()
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current)
      }
      setIsPlaying(false)
    } else {
      // Resume audio context if suspended
      if (audioContextRef.current && audioContextRef.current.state === 'suspended') {
        audioContextRef.current.resume()
      }
      
      audioRef.current.play()
        .then(() => {
          setIsPlaying(true)
          animationRef.current = requestAnimationFrame(updateProgress)
        })
        .catch((error) => {
          console.error('Error playing:', error)
        })
    }
  }, [isPlaying, currentTrack, updateProgress])

  // Skip to next track
  const skipNext = useCallback(() => {
    if (queue.length === 0 || currentIndex === -1) return
    
    let nextIndex = currentIndex + 1
    
    // Handle repeat modes
    if (repeat === 'one') {
      // Replay current track
      if (currentTrack) playTrack(currentTrack, queue)
      return
    }
    
    if (nextIndex >= queue.length) {
      if (repeat === 'all') {
        nextIndex = 0 // Loop back to start
      } else {
        return // End of queue
      }
    }
    
    const nextTrack = queue[nextIndex]
    setCurrentIndex(nextIndex)
    playTrack(nextTrack, queue)
  }, [queue, currentIndex, currentTrack, repeat, playTrack])

  // Skip to previous track
  const skipPrevious = useCallback(() => {
    if (audioRef.current && audioRef.current.currentTime > 3) {
      // If more than 3 seconds played, restart current track
      audioRef.current.currentTime = 0
      return
    }
    
    if (queue.length === 0 || currentIndex === -1) {
      // No queue, try history
      if (playHistory.length > 1) {
        const prevTrack = playHistory[playHistory.length - 2]
        playTrack(prevTrack)
      }
      return
    }
    
    let prevIndex = currentIndex - 1
    
    if (prevIndex < 0) {
      if (repeat === 'all') {
        prevIndex = queue.length - 1 // Loop to end
      } else {
        return // Start of queue
      }
    }
    
    const prevTrack = queue[prevIndex]
    setCurrentIndex(prevIndex)
    playTrack(prevTrack, queue)
  }, [queue, currentIndex, playHistory, repeat, playTrack])

  // Seek to specific time
  const seek = useCallback((time: number) => {
    if (audioRef.current && currentTrack) {
      audioRef.current.currentTime = (time / 100) * audioRef.current.duration
      setProgress(time)
    }
  }, [currentTrack])

  // Set volume
  const setVolume = useCallback((newVolume: number) => {
    if (audioRef.current) {
      audioRef.current.volume = newVolume
      setVolumeState(newVolume)
    }
  }, [])

  // Add track to queue
  const addToQueue = useCallback((track: Track) => {
    setQueue((prev) => [...prev, track])
  }, [])

  // Clear queue
  const clearQueue = useCallback(() => {
    setQueue([])
  }, [])

  // Toggle shuffle
  const toggleShuffle = useCallback(() => {
    setShuffle((prev) => {
      const newShuffle = !prev
      if (originalQueue.length > 0) {
        if (newShuffle) {
          // Shuffle the queue
          setQueue(shuffleArray(originalQueue))
        } else {
          // Restore original order
          setQueue([...originalQueue])
        }
      }
      return newShuffle
    })
  }, [originalQueue])

  // Toggle repeat (off -> one -> all -> off)
  const toggleRepeat = useCallback(() => {
    setRepeat((prev) => {
      if (prev === 'off') return 'one'
      if (prev === 'one') return 'all'
      return 'off'
    })
  }, [])

  // Reorder queue items
  const reorderQueue = useCallback((startIndex: number, endIndex: number) => {
    setQueue((prev) => {
      const result = Array.from(prev)
      const [removed] = result.splice(startIndex, 1)
      result.splice(endIndex, 0, removed)
      return result
    })
  }, [])

  // Set playback speed
  const setPlaybackSpeed = useCallback((speed: number) => {
    if (audioRef.current) {
      audioRef.current.playbackRate = speed
      setPlaybackSpeedState(speed)
    }
  }, [])

  // Equalizer controls
  const setEqualizerBand = useCallback((bandIndex: number, gain: number) => {
    if (bandIndex < 0 || bandIndex >= equalizerNodesRef.current.length) return
    
    const filter = equalizerNodesRef.current[bandIndex]
    if (filter) {
      filter.gain.value = gain
      setEqualizerGains(prev => {
        const newGains = [...prev]
        newGains[bandIndex] = gain
        return newGains
      })
    }
  }, [])

  const setEqualizerPreset = useCallback((preset: string) => {
    const presets: { [key: string]: number[] } = {
      'off': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      'bass-boost': [8, 6, 4, 2, 0, 0, 0, 0, 0, 0],
      'treble-boost': [0, 0, 0, 0, 0, 0, 2, 4, 6, 8],
      'vocal': [0, -2, -4, -2, 2, 4, 4, 3, 1, 0],
      'classical': [0, 0, 0, 0, 0, 0, -2, -2, -2, -4],
      'rock': [4, 3, 2, 0, -1, -1, 0, 2, 3, 4],
      'pop': [2, 4, 3, 0, -1, -2, -1, 1, 2, 3],
      'jazz': [4, 3, 1, 2, -2, -2, 0, 2, 3, 4],
      'electronic': [4, 3, 1, 0, -2, 2, 1, 2, 3, 4]
    }
    
    const gains = presets[preset] || presets['off']
    gains.forEach((gain, index) => {
      if (equalizerNodesRef.current[index]) {
        equalizerNodesRef.current[index].gain.value = gain
      }
    })
    setEqualizerGains(gains)
    setEqualizerEnabled(preset !== 'off')
  }, [])

  const toggleEqualizer = useCallback(() => {
    setEqualizerEnabled(prev => {
      const newEnabled = !prev
      if (!newEnabled) {
        // Turn off all bands
        equalizerNodesRef.current.forEach(filter => {
          filter.gain.value = 0
        })
        setEqualizerGains([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
      }
      return newEnabled
    })
  }, [])

  // Handle track end
  React.useEffect(() => {
    const audio = audioRef.current
    if (!audio) return

    const handleEnded = () => {
      if (queue.length > 0) {
        skipNext()
      } else {
        setIsPlaying(false)
        setProgress(0)
      }
    }

    audio.addEventListener('ended', handleEnded)
    return () => {
      audio.removeEventListener('ended', handleEnded)
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current)
      }
    }
  }, [queue, skipNext])

  const value: PlayerContextType = {
    currentTrack,
    isPlaying,
    progress,
    volume,
    queue,
    shuffle,
    repeat,
    playbackSpeed,
    equalizerEnabled,
    equalizerGains,
    audioElement: audioRef.current,
    analyserNode: analyserNodeRef.current,
    playTrack,
    playPause,
    skipNext,
    skipPrevious,
    seek,
    setVolume,
    addToQueue,
    toggleShuffle,
    toggleRepeat,
    clearQueue,
    setQueue,
    reorderQueue,
    setPlaybackSpeed,
    setEqualizerBand,
    setEqualizerPreset,
    toggleEqualizer,
  }

  return <PlayerContext.Provider value={value}>{children}</PlayerContext.Provider>
}
