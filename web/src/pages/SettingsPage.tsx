/**
 * Settings Page - App Configuration with localStorage persistence
 */

import { motion } from 'framer-motion'
import { Bell, Volume2, Shield, Music2, Info, Trash2 } from 'lucide-react'
import { useState, useEffect } from 'react'
import { apiCacheService } from '../services/apiCache.service'
import { usePlayer } from '../contexts/PlayerContext'
import styles from './SettingsPage.module.css'

interface Settings {
  notifications: boolean
  autoPlay: boolean
  audioQuality: 'low' | 'medium' | 'high'
  privateProfile: boolean
  explicitContent: boolean
  crossfade: number
  gapless: boolean
  volumeNormalization: boolean
  equalizerPreset: string
}

const SETTINGS_KEY = 'jetstream_settings'

const defaultSettings: Settings = {
  notifications: true,
  autoPlay: true,
  audioQuality: 'high',
  privateProfile: false,
  explicitContent: true,
  crossfade: 0,
  gapless: true,
  volumeNormalization: false,
  equalizerPreset: 'off'
}

function SettingsPage() {
  const [settings, setSettings] = useState<Settings>(defaultSettings)
  const [cacheSize, setCacheSize] = useState('0')
  const { setEqualizerPreset } = usePlayer()

  useEffect(() => {
    // Load settings from localStorage
    const saved = localStorage.getItem(SETTINGS_KEY)
    if (saved) {
      try {
        setSettings({ ...defaultSettings, ...JSON.parse(saved) })
      } catch (error) {
        console.error('Failed to load settings:', error)
      }
    }
    // Calculate cache size
    calculateCacheSize()
  }, [])

  const calculateCacheSize = () => {
    try {
      let total = 0
      for (let key in localStorage) {
        if (localStorage.hasOwnProperty(key)) {
          total += localStorage[key].length + key.length
        }
      }
      setCacheSize((total / 1024).toFixed(2))
    } catch (error) {
      setCacheSize('0')
    }
  }

  const updateSetting = <K extends keyof Settings>(key: K, value: Settings[K]) => {
    const newSettings = { ...settings, [key]: value }
    setSettings(newSettings)
    localStorage.setItem(SETTINGS_KEY, JSON.stringify(newSettings))
  }

  const handleClearCache = () => {
    if (window.confirm('Are you sure you want to clear all cache? This will remove liked songs, playlists, and recently played tracks.')) {
      localStorage.clear()
      setSettings(defaultSettings)
      calculateCacheSize()
      alert('Cache cleared successfully! The page will reload.')
      window.location.reload()
    }
  }

  const handleClearApiCache = () => {
    if (window.confirm('Clear API cache? This will free up space but require re-fetching data from Deezer.')) {
      const stats = apiCacheService.getStats()
      apiCacheService.clearAll()
      calculateCacheSize()
      alert(`Cleared ${stats.count} cached API responses (${(stats.size / 1024).toFixed(2)} KB)`)
    }
  }

  const handleResetSettings = () => {
    if (window.confirm('Reset all settings to default?')) {
      setSettings(defaultSettings)
      localStorage.setItem(SETTINGS_KEY, JSON.stringify(defaultSettings))
    }
  }

  return (
    <div className={styles.container}>
      {/* Header */}
      <motion.section
        className={styles.header}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className={styles.title}>Settings</h1>
        <p className={styles.subtitle}>Customize your JetStream experience</p>
      </motion.section>

      {/* Settings Grid */}
      <div className={styles.settingsGrid}>
        {/* Playback Settings */}
        <motion.section
          className={styles.card}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <h2 className={styles.cardTitle}>
            <Music2 size={20} />
            Playback
          </h2>
          
          <div className={styles.settingsList}>
            <div className={styles.settingItem}>
              <div className={styles.settingInfo}>
                <div className={styles.settingLabel}>AutoPlay</div>
                <div className={styles.settingDesc}>Continue playing similar tracks</div>
              </div>
              <label className={styles.toggle}>
                <input
                  type="checkbox"
                  checked={settings.autoPlay}
                  onChange={(e) => updateSetting('autoPlay', e.target.checked)}
                />
                <span className={styles.toggleSlider}></span>
              </label>
            </div>

            <div className={styles.settingItem}>
              <div className={styles.settingInfo}>
                <div className={styles.settingLabel}>Audio Quality</div>
                <div className={styles.settingDesc}>Streaming quality setting</div>
              </div>
              <select
                className={styles.select}
                value={settings.audioQuality}
                onChange={(e) => updateSetting('audioQuality', e.target.value as 'low' | 'medium' | 'high')}
              >
                <option value="low">Low (96 kbps)</option>
                <option value="medium">Medium (160 kbps)</option>
                <option value="high">High (320 kbps)</option>
              </select>
            </div>

            <div className={styles.settingItem}>
              <div className={styles.settingInfo}>
                <div className={styles.settingLabel}>Crossfade</div>
                <div className={styles.settingDesc}>Smooth transition between tracks</div>
              </div>
              <div className={styles.sliderContainer}>
                <input
                  type="range"
                  min="0"
                  max="12"
                  step="1"
                  value={settings.crossfade}
                  onChange={(e) => updateSetting('crossfade', parseInt(e.target.value))}
                  className={styles.slider}
                />
                <span className={styles.sliderValue}>{settings.crossfade}s</span>
              </div>
            </div>

            <div className={styles.settingItem}>
              <div className={styles.settingInfo}>
                <div className={styles.settingLabel}>Gapless Playback</div>
                <div className={styles.settingDesc}>Seamless track transitions</div>
              </div>
              <label className={styles.toggle}>
                <input
                  type="checkbox"
                  checked={settings.gapless}
                  onChange={(e) => updateSetting('gapless', e.target.checked)}
                />
                <span className={styles.toggleSlider}></span>
              </label>
            </div>

            <div className={styles.settingItem}>
              <div className={styles.settingInfo}>
                <div className={styles.settingLabel}>Volume Normalization</div>
                <div className={styles.settingDesc}>Equalize volume across tracks</div>
              </div>
              <label className={styles.toggle}>
                <input
                  type="checkbox"
                  checked={settings.volumeNormalization}
                  onChange={(e) => updateSetting('volumeNormalization', e.target.checked)}
                />
                <span className={styles.toggleSlider}></span>
              </label>
            </div>

            <div className={styles.settingItem}>
              <div className={styles.settingInfo}>
                <div className={styles.settingLabel}>Equalizer Preset</div>
                <div className={styles.settingDesc}>Audio equalization</div>
              </div>
              <select
                className={styles.select}
                value={settings.equalizerPreset}
                onChange={(e) => {
                  const preset = e.target.value
                  setEqualizerPreset(preset)
                  updateSetting('equalizerPreset', preset)
                }}
              >
                <option value="off">Off</option>
                <option value="bass-boost">Bass Boost</option>
                <option value="treble-boost">Treble Boost</option>
                <option value="vocal">Vocal</option>
                <option value="pop">Pop</option>
                <option value="rock">Rock</option>
                <option value="jazz">Jazz</option>
                <option value="classical">Classical</option>
                <option value="electronic">Electronic</option>
              </select>
            </div>
          </div>
        </motion.section>



        {/* Notifications */}
        <motion.section
          className={styles.card}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <h2 className={styles.cardTitle}>
            <Bell size={20} />
            Notifications
          </h2>
          
          <div className={styles.settingsList}>
            <div className={styles.settingItem}>
              <div className={styles.settingInfo}>
                <div className={styles.settingLabel}>Push Notifications</div>
                <div className={styles.settingDesc}>Get notified about new releases</div>
              </div>
              <label className={styles.toggle}>
                <input
                  type="checkbox"
                  checked={settings.notifications}
                  onChange={(e) => updateSetting('notifications', e.target.checked)}
                />
                <span className={styles.toggleSlider}></span>
              </label>
            </div>
          </div>
        </motion.section>

        {/* Privacy & Security */}
        <motion.section
          className={styles.card}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
        >
          <h2 className={styles.cardTitle}>
            <Shield size={20} />
            Privacy & Security
          </h2>
          
          <div className={styles.settingsList}>
            <div className={styles.settingItem}>
              <div className={styles.settingInfo}>
                <div className={styles.settingLabel}>Private Profile</div>
                <div className={styles.settingDesc}>Hide your listening activity</div>
              </div>
              <label className={styles.toggle}>
                <input
                  type="checkbox"
                  checked={settings.privateProfile}
                  onChange={(e) => updateSetting('privateProfile', e.target.checked)}
                />
                <span className={styles.toggleSlider}></span>
              </label>
            </div>

            <div className={styles.settingItem}>
              <div className={styles.settingInfo}>
                <div className={styles.settingLabel}>Show Explicit Content</div>
                <div className={styles.settingDesc}>Allow explicit content in search</div>
              </div>
              <label className={styles.toggle}>
                <input
                  type="checkbox"
                  checked={settings.explicitContent}
                  onChange={(e) => updateSetting('explicitContent', e.target.checked)}
                />
                <span className={styles.toggleSlider}></span>
              </label>
            </div>
          </div>
        </motion.section>

        {/* Storage & Data */}
        <motion.section
          className={styles.card}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
        >
          <h2 className={styles.cardTitle}>
            <Volume2 size={20} />
            Storage & Data
          </h2>
          
          <div className={styles.settingsList}>
            <div className={styles.settingItem}>
              <div className={styles.settingInfo}>
                <div className={styles.settingLabel}>Total Cache Size</div>
                <div className={styles.settingDesc}>All local storage usage</div>
              </div>
              <div className={styles.settingValue}>{cacheSize} KB</div>
            </div>

            <div className={styles.settingItem}>
              <div className={styles.settingInfo}>
                <div className={styles.settingLabel}>API Cache</div>
                <div className={styles.settingDesc}>Cached Deezer responses</div>
              </div>
              <button 
                className={styles.secondaryButton} 
                onClick={handleClearApiCache}
                style={{ fontSize: '14px', padding: '6px 12px' }}
              >
                Clear API Cache
              </button>
            </div>
          </div>
        </motion.section>
      </div>

      {/* Action Buttons */}
      <motion.section
        className={styles.actions}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6 }}
      >
        <button className={styles.secondaryButton} onClick={handleResetSettings}>
          Reset to Defaults
        </button>
        <button className={styles.dangerButton} onClick={handleClearCache}>
          <Trash2 size={18} />
          Clear All Cache
        </button>
      </motion.section>

      {/* Footer */}
      <motion.section
        className={styles.footer}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.7 }}
      >
        <div className={styles.footerContent}>
          <Info size={16} />
          <span>JetStream v1.0.0</span>
          <span className={styles.footerDot}>•</span>
          <a href="#" className={styles.footerLink}>Terms of Service</a>
          <span className={styles.footerDot}>•</span>
          <a href="#" className={styles.footerLink}>Privacy Policy</a>
          <span className={styles.footerDot}>•</span>
          <span className={styles.footerText}>Made with ❤️ for music lovers</span>
        </div>
      </motion.section>
    </div>
  )
}

export default SettingsPage
