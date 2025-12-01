/**
 * Keyboard Shortcuts Help Modal
 * Display all available keyboard shortcuts
 */

import { motion, AnimatePresence } from 'framer-motion'
import { X, Keyboard } from 'lucide-react'
import { keyboardShortcuts } from '../hooks/useKeyboardShortcuts'
import styles from './KeyboardShortcutsModal.module.css'

interface KeyboardShortcutsModalProps {
  isOpen: boolean
  onClose: () => void
}

function KeyboardShortcutsModal({ isOpen, onClose }: KeyboardShortcutsModalProps) {
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
          >
            {/* Modal */}
            <motion.div
              className={styles.modal}
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              onClick={(e) => e.stopPropagation()}
            >
            {/* Header */}
            <div className={styles.header}>
              <div className={styles.headerTitle}>
                <Keyboard size={24} />
                <h2>Keyboard Shortcuts</h2>
              </div>
              <button className={styles.closeButton} onClick={onClose}>
                <X size={20} />
              </button>
            </div>

            {/* Shortcuts List */}
            <div className={styles.content}>
              <div className={styles.section}>
                <h3 className={styles.sectionTitle}>Playback Controls</h3>
                <div className={styles.shortcuts}>
                  {keyboardShortcuts.slice(0, 7).map((shortcut, index) => (
                    <motion.div
                      key={index}
                      className={styles.shortcutItem}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.05 }}
                    >
                      <kbd className={styles.key}>{shortcut.key}</kbd>
                      <span className={styles.description}>{shortcut.description}</span>
                    </motion.div>
                  ))}
                </div>
              </div>

              <div className={styles.section}>
                <h3 className={styles.sectionTitle}>Player Features</h3>
                <div className={styles.shortcuts}>
                  {keyboardShortcuts.slice(7, 12).map((shortcut, index) => (
                    <motion.div
                      key={index}
                      className={styles.shortcutItem}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: (index + 7) * 0.05 }}
                    >
                      <kbd className={styles.key}>{shortcut.key}</kbd>
                      <span className={styles.description}>{shortcut.description}</span>
                    </motion.div>
                  ))}
                </div>
              </div>

              <div className={styles.section}>
                <h3 className={styles.sectionTitle}>Navigation</h3>
                <div className={styles.shortcuts}>
                  {keyboardShortcuts.slice(12).map((shortcut, index) => (
                    <motion.div
                      key={index}
                      className={styles.shortcutItem}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: (index + 12) * 0.05 }}
                    >
                      <kbd className={styles.key}>{shortcut.key}</kbd>
                      <span className={styles.description}>{shortcut.description}</span>
                    </motion.div>
                  ))}
                </div>
              </div>
            </div>

            {/* Footer */}
            <div className={styles.footer}>
              <p>Press <kbd className={styles.keySmall}>?</kbd> to toggle this help modal</p>
            </div>
            </motion.div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

export default KeyboardShortcutsModal
