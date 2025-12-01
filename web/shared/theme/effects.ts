/**
 * Visual Effects System - Futuristic UI Effects
 * Glassmorphism, Neon Glows, Gradients, and more
 */

import { colors } from './index'

// Glassmorphism CSS strings
export const glassmorphism = {
  light: `
    background: rgba(20, 27, 52, 0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.1);
  `,
  medium: `
    background: rgba(20, 27, 52, 0.6);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.15);
  `,
  heavy: `
    background: rgba(20, 27, 52, 0.8);
    backdrop-filter: blur(30px);
    -webkit-backdrop-filter: blur(30px);
    border: 1px solid rgba(255, 255, 255, 0.2);
  `,
}

// Neon glow effects
export const neonGlow = {
  cyan: {
    boxShadow: `
      0 0 10px ${colors.accent.primary},
      0 0 20px ${colors.accent.glow},
      0 0 40px ${colors.accent.glow}
    `,
  },
  purple: {
    boxShadow: `
      0 0 10px ${colors.secondary.primary},
      0 0 20px ${colors.secondary.glow},
      0 0 40px ${colors.secondary.glow}
    `,
  },
  mixed: {
    boxShadow: `
      0 0 10px ${colors.accent.primary},
      0 0 20px ${colors.secondary.primary},
      0 0 40px ${colors.accent.glow}
    `,
  },
  subtle: {
    boxShadow: `
      0 0 5px ${colors.accent.glow},
      0 0 10px ${colors.accent.glow}
    `,
  },
}

// Text glow effects
export const textGlow = {
  cyan: {
    textShadow: `
      0 0 10px ${colors.accent.primary},
      0 0 20px ${colors.accent.glow}
    `,
  },
  purple: {
    textShadow: `
      0 0 10px ${colors.secondary.primary},
      0 0 20px ${colors.secondary.glow}
    `,
  },
  white: {
    textShadow: `
      0 0 10px rgba(255, 255, 255, 0.5),
      0 0 20px rgba(255, 255, 255, 0.3)
    `,
  },
}

// Gradient backgrounds
export const gradients = {
  // Animated backgrounds
  neonFlow: `
    linear-gradient(
      135deg,
      ${colors.accent.primary} 0%,
      ${colors.secondary.primary} 50%,
      ${colors.accent.primary} 100%
    )
  `,
  
  darkNeon: `
    linear-gradient(
      135deg,
      ${colors.background.primary} 0%,
      ${colors.background.secondary} 50%,
      ${colors.background.primary} 100%
    )
  `,
  
  cosmic: `
    linear-gradient(
      135deg,
      #0A0E27 0%,
      #1C2541 25%,
      #2D1B69 50%,
      #1C2541 75%,
      #0A0E27 100%
    )
  `,
  
  // Overlay gradients
  fadeTop: `
    linear-gradient(
      to bottom,
      ${colors.background.primary} 0%,
      transparent 100%
    )
  `,
  
  fadeBottom: `
    linear-gradient(
      to top,
      ${colors.background.primary} 0%,
      transparent 100%
    )
  `,
  
  glowOverlay: `
    radial-gradient(
      circle at center,
      ${colors.accent.glow} 0%,
      transparent 70%
    )
  `,
  
  // Card gradients
  cardGlow: `
    linear-gradient(
      135deg,
      rgba(0, 217, 255, 0.1) 0%,
      rgba(157, 78, 221, 0.1) 100%
    )
  `,
  
  cardBorder: `
    linear-gradient(
      135deg,
      ${colors.accent.primary} 0%,
      ${colors.secondary.primary} 100%
    )
  `,
}

// Border styles
export const borders = {
  neon: {
    border: `1px solid ${colors.accent.primary}`,
    boxShadow: `0 0 10px ${colors.accent.glow}`,
  },
  
  neonPurple: {
    border: `1px solid ${colors.secondary.primary}`,
    boxShadow: `0 0 10px ${colors.secondary.glow}`,
  },
  
  gradient: {
    border: 'none',
    backgroundImage: gradients.cardBorder,
    backgroundOrigin: 'border-box',
    backgroundClip: 'padding-box, border-box',
  },
  
  glass: {
    border: '1px solid rgba(255, 255, 255, 0.1)',
  },
}

// Shadow effects
export const shadows = {
  // Elevation shadows
  low: '0 2px 8px rgba(0, 0, 0, 0.3)',
  medium: '0 4px 16px rgba(0, 0, 0, 0.4)',
  high: '0 8px 32px rgba(0, 0, 0, 0.5)',
  
  // Colored shadows
  cyanGlow: `0 4px 20px ${colors.accent.glow}`,
  purpleGlow: `0 4px 20px ${colors.secondary.glow}`,
  
  // Inner shadows
  innerGlow: `inset 0 0 20px ${colors.accent.glow}`,
  innerDark: 'inset 0 2px 8px rgba(0, 0, 0, 0.5)',
}

// Particle effect colors
export const particleColors = [
  colors.accent.primary,
  colors.secondary.primary,
  colors.accent.light,
  colors.secondary.light,
  'rgba(255, 255, 255, 0.5)',
]

// Shimmer effect
export const shimmer = {
  background: `
    linear-gradient(
      90deg,
      transparent 0%,
      rgba(255, 255, 255, 0.1) 50%,
      transparent 100%
    )
  `,
  backgroundSize: '200% 100%',
  animation: 'shimmer 2s infinite',
}

// Scan line effect
export const scanlines = {
  background: `
    repeating-linear-gradient(
      0deg,
      transparent,
      transparent 2px,
      rgba(0, 0, 0, 0.1) 2px,
      rgba(0, 0, 0, 0.1) 4px
    )
  `,
}

// Holographic effect
export const holographic = {
  background: `
    linear-gradient(
      135deg,
      ${colors.accent.primary}00 0%,
      ${colors.accent.primary}33 25%,
      ${colors.secondary.primary}33 50%,
      ${colors.accent.primary}33 75%,
      ${colors.accent.primary}00 100%
    )
  `,
  backgroundSize: '200% 200%',
  animation: 'holographic 3s ease infinite',
}

// CSS keyframes as strings
export const keyframes = {
  shimmer: `
    @keyframes shimmer {
      0% { background-position: -200% center; }
      100% { background-position: 200% center; }
    }
  `,
  
  holographic: `
    @keyframes holographic {
      0% { background-position: 0% 50%; }
      50% { background-position: 100% 50%; }
      100% { background-position: 0% 50%; }
    }
  `,
  
  neonPulse: `
    @keyframes neonPulse {
      0%, 100% {
        text-shadow: 0 0 10px ${colors.accent.primary},
                     0 0 20px ${colors.accent.glow};
      }
      50% {
        text-shadow: 0 0 20px ${colors.accent.primary},
                     0 0 40px ${colors.accent.glow};
      }
    }
  `,
  
  float: `
    @keyframes float {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(-10px); }
    }
  `,
  
  rotate: `
    @keyframes rotate {
      from { transform: rotate(0deg); }
      to { transform: rotate(360deg); }
    }
  `,
  
  glow: `
    @keyframes glow {
      0%, 100% {
        box-shadow: 0 0 10px ${colors.accent.glow},
                    0 0 20px ${colors.accent.glow};
      }
      50% {
        box-shadow: 0 0 20px ${colors.accent.primary},
                    0 0 40px ${colors.accent.glow};
      }
    }
  `,
}

export default {
  glassmorphism,
  neonGlow,
  textGlow,
  gradients,
  borders,
  shadows,
  particleColors,
  shimmer,
  scanlines,
  holographic,
  keyframes,
}
