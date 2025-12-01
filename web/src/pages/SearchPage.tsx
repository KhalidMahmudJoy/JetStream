/**
 * Search Page - Futuristic Search Experience
 */

import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Search, X, TrendingUp, Clock, Music, Mic2, Disc3, Play, Plus } from 'lucide-react'
import { Link } from 'react-router-dom'
import { deezerService } from '../services/deezer.service'
import { usePlayer } from '../contexts/PlayerContext'
import { webAnimations } from '../../shared/theme/animations'
import AddToPlaylistModal from '../components/AddToPlaylistModal'
import styles from './SearchPage.module.css'

const trendingSearches = [
  'Chill Vibes', 'Workout Mix', 'Jazz Essentials', 'Electronic Dreams',
  'Indie Rock', 'Classical Piano', 'Hip Hop Beats', 'Summer Hits'
]

type FilterType = 'all' | 'tracks' | 'albums' | 'artists'

interface SearchResults {
  tracks: any[]
  albums: any[]
  artists: any[]
}

function SearchPage() {
  const [searchQuery, setSearchQuery] = useState('')
  const [activeFilter, setActiveFilter] = useState<FilterType>('all')
  const [searchResults, setSearchResults] = useState<SearchResults | null>(null)
  const [isSearching, setIsSearching] = useState(false)
  const [recentSearches, setRecentSearches] = useState<string[]>(() => {
    const saved = localStorage.getItem('recentSearches')
    return saved ? JSON.parse(saved) : []
  })
  const [isAddToPlaylistOpen, setIsAddToPlaylistOpen] = useState(false)
  const [selectedTrack, setSelectedTrack] = useState<any>(null)
  const { playTrack } = usePlayer()

  // Debounced search with real Deezer API
  useEffect(() => {
    if (searchQuery.length < 2) {
      setSearchResults(null)
      return
    }

    setIsSearching(true)
    const timer = setTimeout(async () => {
      try {
        const [tracks, albums, artists] = await Promise.all([
          deezerService.search(searchQuery, 'track', 20),
          deezerService.search(searchQuery, 'album', 20),
          deezerService.search(searchQuery, 'artist', 20)
        ])
        setSearchResults({ tracks, albums, artists })
        setIsSearching(false)
      } catch (error) {
        console.error('Search error:', error)
        setSearchResults({ tracks: [], albums: [], artists: [] })
        setIsSearching(false)
      }
    }, 500)

    return () => clearTimeout(timer)
  }, [searchQuery])

  // Save recent searches to localStorage
  useEffect(() => {
    localStorage.setItem('recentSearches', JSON.stringify(recentSearches))
  }, [recentSearches])

  const handleSearch = (query: string) => {
    setSearchQuery(query)
    if (query && !recentSearches.includes(query)) {
      setRecentSearches([query, ...recentSearches.slice(0, 9)])
    }
  }

  const clearSearch = () => {
    setSearchQuery('')
    setSearchResults(null)
  }

  const handlePlayTrack = (track: any) => {
    const transformedTrack = deezerService.transformTrack(track)
    playTrack(transformedTrack)
  }

  const handleAddToPlaylist = (track: any, e: React.MouseEvent) => {
    e.stopPropagation()
    setSelectedTrack(track)
    setIsAddToPlaylistOpen(true)
  }

  const filters: { type: FilterType; label: string; icon: any }[] = [
    { type: 'all', label: 'All', icon: Search },
    { type: 'tracks', label: 'Tracks', icon: Music },
    { type: 'albums', label: 'Albums', icon: Disc3 },
    { type: 'artists', label: 'Artists', icon: Mic2 }
  ]

  const getFilteredResults = () => {
    if (!searchResults) return null
    if (activeFilter === 'all') return searchResults
    return {
      tracks: activeFilter === 'tracks' ? searchResults.tracks : [],
      albums: activeFilter === 'albums' ? searchResults.albums : [],
      artists: activeFilter === 'artists' ? searchResults.artists : []
    }
  }

  const filteredResults = getFilteredResults()

  return (
    <div className={styles.container}>
      {/* Search Header */}
      <motion.div 
        className={styles.searchHeader}
        {...webAnimations.fadeInUp}
      >
        <h1 className={styles.title}>
          <Search className={styles.titleIcon} />
          Search
        </h1>
        
        {/* Search Bar */}
        <div className={styles.searchBarContainer}>
          <motion.div 
            className={styles.searchBar}
            whileFocus={{ scale: 1.02 }}
          >
            <Search className={styles.searchIcon} />
            <input
              type="text"
              placeholder="Search for tracks, albums, artists, or playlists..."
              value={searchQuery}
              onChange={(e) => handleSearch(e.target.value)}
              className={styles.searchInput}
              autoFocus
            />
            <AnimatePresence>
              {searchQuery && (
                <motion.button
                  initial={{ scale: 0, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  exit={{ scale: 0, opacity: 0 }}
                  className={styles.clearButton}
                  onClick={clearSearch}
                >
                  <X size={18} />
                </motion.button>
              )}
            </AnimatePresence>
          </motion.div>

          {/* Filter Pills */}
          <motion.div 
            className={styles.filters}
            {...webAnimations.fadeInUp}
            transition={{ delay: 0.1 }}
          >
            {filters.map((filter) => {
              const Icon = filter.icon
              return (
                <motion.button
                  key={filter.type}
                  className={`${styles.filterPill} ${activeFilter === filter.type ? styles.active : ''}`}
                  onClick={() => setActiveFilter(filter.type)}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <Icon size={16} />
                  {filter.label}
                </motion.button>
              )
            })}
          </motion.div>
        </div>
      </motion.div>

      {/* Content */}
      <div className={styles.content}>
        {!searchQuery && !searchResults && (
          <>
            {/* Trending Searches */}
            <motion.section 
              className={styles.section}
              {...webAnimations.fadeInUp}
              transition={{ delay: 0.2 }}
            >
              <h2 className={styles.sectionTitle}>
                <TrendingUp size={20} />
                Trending Searches
              </h2>
              <div className={styles.chipGrid}>
                {trendingSearches.map((term, index) => (
                  <motion.button
                    key={term}
                    className={styles.trendingChip}
                    onClick={() => handleSearch(term)}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.3 + index * 0.05 }}
                    whileHover={{ scale: 1.05, boxShadow: '0 0 20px rgba(139, 92, 246, 0.5)' }}
                    whileTap={{ scale: 0.95 }}
                  >
                    {term}
                  </motion.button>
                ))}
              </div>
            </motion.section>

            {/* Recent Searches */}
            {recentSearches.length > 0 && (
              <motion.section 
                className={styles.section}
                {...webAnimations.fadeInUp}
                transition={{ delay: 0.4 }}
              >
                <h2 className={styles.sectionTitle}>
                  <Clock size={20} />
                  Recent Searches
                </h2>
                <div className={styles.recentList}>
                  {recentSearches.map((term, index) => (
                    <motion.button
                      key={index}
                      className={styles.recentItem}
                      onClick={() => handleSearch(term)}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.5 + index * 0.05 }}
                      whileHover={{ x: 5 }}
                    >
                      <Clock size={16} className={styles.recentIcon} />
                      {term}
                      <button
                        className={styles.removeRecent}
                        onClick={(e) => {
                          e.stopPropagation()
                          setRecentSearches(recentSearches.filter((_, i) => i !== index))
                        }}
                      >
                        <X size={14} />
                      </button>
                    </motion.button>
                  ))}
                </div>
              </motion.section>
            )}
          </>
        )}

        {/* Search Results */}
        {isSearching && (
          <div className={styles.loadingState}>
            <motion.div
              className={styles.loadingSpinner}
              animate={{ rotate: 360 }}
              transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
            >
              <Search size={32} />
            </motion.div>
            <p>Searching...</p>
          </div>
        )}

        {filteredResults && !isSearching && (
          <motion.div
            className={styles.results}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
          >
            {/* Tracks Results */}
            {(activeFilter === 'all' || activeFilter === 'tracks') && filteredResults.tracks.length > 0 && (
              <motion.section 
                className={styles.section}
                {...webAnimations.fadeInUp}
              >
                <h2 className={styles.sectionTitle}>
                  <Music size={20} />
                  Tracks ({filteredResults.tracks.length})
                </h2>
                <div className={styles.tracksGrid}>
                  {filteredResults.tracks.slice(0, 12).map((track: any, index: number) => (
                    <motion.div
                      key={track.id}
                      className={styles.trackCard}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.05 }}
                      whileHover={{ y: -4 }}
                      onClick={() => handlePlayTrack(track)}
                    >
                      <div className={styles.trackImage}>
                        <img src={track.album.cover_medium} alt={track.title} />
                        <div className={styles.trackPlayOverlay}>
                          <Play size={24} fill="currentColor" />
                        </div>
                      </div>
                      <div className={styles.trackInfo}>
                        <div className={styles.trackTitle}>{track.title}</div>
                        <div className={styles.trackArtist}>{track.artist.name}</div>
                      </div>
                      <button
                        className={styles.addToPlaylistButton}
                        onClick={(e) => handleAddToPlaylist(track, e)}
                        title="Add to Playlist"
                      >
                        <Plus size={18} />
                      </button>
                    </motion.div>
                  ))}
                </div>
              </motion.section>
            )}

            {/* Albums Results */}
            {(activeFilter === 'all' || activeFilter === 'albums') && filteredResults.albums.length > 0 && (
              <motion.section 
                className={styles.section}
                {...webAnimations.fadeInUp}
                transition={{ delay: 0.1 }}
              >
                <h2 className={styles.sectionTitle}>
                  <Disc3 size={20} />
                  Albums ({filteredResults.albums.length})
                </h2>
                <div className={styles.tracksGrid}>
                  {filteredResults.albums.slice(0, 12).map((album: any, index: number) => (
                    <Link key={album.id} to={`/album/${album.id}`} style={{ textDecoration: 'none' }}>
                      <motion.div
                        className={styles.trackCard}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.05 }}
                        whileHover={{ y: -4 }}
                      >
                        <div className={styles.trackImage}>
                          <img src={album.cover_medium} alt={album.title} />
                          <div className={styles.trackPlayOverlay}>
                            <Play size={24} fill="currentColor" />
                          </div>
                        </div>
                        <div className={styles.trackInfo}>
                          <div className={styles.trackTitle}>{album.title}</div>
                          <div className={styles.trackArtist}>{album.artist.name}</div>
                        </div>
                      </motion.div>
                    </Link>
                  ))}
                </div>
              </motion.section>
            )}

            {/* Artists Results */}
            {(activeFilter === 'all' || activeFilter === 'artists') && filteredResults.artists.length > 0 && (
              <motion.section 
                className={styles.section}
                {...webAnimations.fadeInUp}
                transition={{ delay: 0.2 }}
              >
                <h2 className={styles.sectionTitle}>
                  <Mic2 size={20} />
                  Artists ({filteredResults.artists.length})
                </h2>
                <div className={styles.tracksGrid}>
                  {filteredResults.artists.slice(0, 12).map((artist: any, index: number) => (
                    <Link key={artist.id} to={`/artist/${artist.id}`} style={{ textDecoration: 'none' }}>
                      <motion.div
                        className={styles.artistCard}
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.05 }}
                        whileHover={{ y: -4 }}
                      >
                        <div className={styles.artistImage}>
                          <img src={artist.picture_medium} alt={artist.name} />
                        </div>
                        <div className={styles.artistInfo}>
                          <div className={styles.artistName}>{artist.name}</div>
                          <div className={styles.artistType}>Artist</div>
                        </div>
                      </motion.div>
                    </Link>
                  ))}
                </div>
              </motion.section>
            )}

            {/* Empty State */}
            {filteredResults.tracks.length === 0 && 
             filteredResults.albums.length === 0 && 
             filteredResults.artists.length === 0 && (
              <motion.div
                className={styles.emptyState}
                {...webAnimations.fadeInUp}
              >
                <Search size={64} className={styles.emptyIcon} />
                <h3>No results found</h3>
                <p>Try searching with different keywords</p>
              </motion.div>
            )}
          </motion.div>
        )}
      </div>

      {/* Add to Playlist Modal */}
      {selectedTrack && (
        <AddToPlaylistModal
          isOpen={isAddToPlaylistOpen}
          onClose={() => {
            setIsAddToPlaylistOpen(false)
            setSelectedTrack(null)
          }}
          track={deezerService.transformTrack(selectedTrack)}
        />
      )}
    </div>
  )
}

export default SearchPage
