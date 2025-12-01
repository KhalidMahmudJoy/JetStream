/**
 * JetStream Web Entry Point
 */

import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import './styles/theme-light.css'
import { registerServiceWorker } from './services/serviceWorker'

// Register service worker for PWA functionality
registerServiceWorker()

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
