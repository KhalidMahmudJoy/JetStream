/**
 * Animation System - Futuristic UI Animations
 * Shared animation configurations for mobile and web
 */

// Animation Durations (in ms)
export const durations = {
  instant: 0,
  fast: 200,
  normal: 300,
  medium: 400,
  slow: 600,
  slower: 800,
  slowest: 1000,
}

// Easing Functions
export const easings = {
  // Standard easings
  linear: [0, 0, 1, 1],
  easeIn: [0.4, 0, 1, 1],
  easeOut: [0, 0, 0.2, 1],
  easeInOut: [0.4, 0, 0.2, 1],
  
  // Smooth easings
  smooth: [0.25, 0.1, 0.25, 1],
  smoothIn: [0.3, 0, 0.8, 0.15],
  smoothOut: [0.2, 0.85, 0.7, 1],
  
  // Bounce & Spring
  bounce: [0.68, -0.55, 0.265, 1.55],
  spring: [0.5, 1.5, 0.5, 1],
  elastic: [0.68, -0.6, 0.32, 1.6],
  
  // Custom futuristic
  neon: [0.34, 1.56, 0.64, 1],
  glow: [0.22, 1, 0.36, 1],
  cyber: [0.87, 0, 0.13, 1],
}

// Preset Animations for Web (Framer Motion)
export const webAnimations = {
  // Fade animations
  fadeIn: {
    initial: { opacity: 0 },
    animate: { opacity: 1 },
    exit: { opacity: 0 },
    transition: { duration: durations.normal / 1000 },
  },
  
  fadeInUp: {
    initial: { opacity: 0, y: 20 },
    animate: { opacity: 1, y: 0 },
    exit: { opacity: 0, y: 20 },
    transition: { 
      duration: durations.normal / 1000,
      ease: [0.4, 0, 0.2, 1],
    },
  },
  
  fadeInDown: {
    initial: { opacity: 0, y: -20 },
    animate: { opacity: 1, y: 0 },
    exit: { opacity: 0, y: -20 },
  },
  
  // Scale animations
  scaleIn: {
    initial: { opacity: 0, scale: 0.8 },
    animate: { opacity: 1, scale: 1 },
    exit: { opacity: 0, scale: 0.8 },
    transition: { 
      duration: durations.medium / 1000,
      ease: [0.68, -0.55, 0.265, 1.55],
    },
  },
  
  scaleInBounce: {
    initial: { opacity: 0, scale: 0.3 },
    animate: { opacity: 1, scale: 1 },
    transition: { 
      duration: durations.slow / 1000,
      ease: [0.68, -0.6, 0.32, 1.6],
    },
  },
  
  // Slide animations
  slideInLeft: {
    initial: { opacity: 0, x: -50 },
    animate: { opacity: 1, x: 0 },
    exit: { opacity: 0, x: -50 },
  },
  
  slideInRight: {
    initial: { opacity: 0, x: 50 },
    animate: { opacity: 1, x: 0 },
    exit: { opacity: 0, x: 50 },
  },
  
  // Glow animation
  glow: {
    animate: {
      boxShadow: [
        '0 0 10px rgba(0, 217, 255, 0.3)',
        '0 0 20px rgba(0, 217, 255, 0.6)',
        '0 0 10px rgba(0, 217, 255, 0.3)',
      ],
    },
    transition: {
      duration: 2,
      repeat: Infinity,
      ease: 'easeInOut',
    },
  },
  
  // Pulse animation
  pulse: {
    animate: {
      scale: [1, 1.05, 1],
      opacity: [1, 0.8, 1],
    },
    transition: {
      duration: 2,
      repeat: Infinity,
      ease: 'easeInOut',
    },
  },
  
  // Float animation
  float: {
    animate: {
      y: [0, -10, 0],
    },
    transition: {
      duration: 3,
      repeat: Infinity,
      ease: 'easeInOut',
    },
  },
  
  // Neon glow cycle
  neonCycle: {
    animate: {
      textShadow: [
        '0 0 10px rgba(0, 217, 255, 0.5)',
        '0 0 20px rgba(157, 78, 221, 0.5)',
        '0 0 10px rgba(0, 217, 255, 0.5)',
      ],
    },
    transition: {
      duration: 3,
      repeat: Infinity,
      ease: 'linear',
    },
  },
}

// Stagger configurations
export const stagger = {
  fast: {
    delayChildren: 0.1,
    staggerChildren: 0.05,
  },
  normal: {
    delayChildren: 0.2,
    staggerChildren: 0.1,
  },
  slow: {
    delayChildren: 0.3,
    staggerChildren: 0.15,
  },
}

// Page transition variants
export const pageTransitions = {
  fade: {
    initial: { opacity: 0 },
    animate: { opacity: 1 },
    exit: { opacity: 0 },
    transition: { duration: durations.normal / 1000 },
  },
  
  slideUp: {
    initial: { opacity: 0, y: 50 },
    animate: { opacity: 1, y: 0 },
    exit: { opacity: 0, y: 50 },
    transition: { duration: durations.medium / 1000 },
  },
  
  scale: {
    initial: { opacity: 0, scale: 0.95 },
    animate: { opacity: 1, scale: 1 },
    exit: { opacity: 0, scale: 0.95 },
    transition: { duration: durations.normal / 1000 },
  },
}

// Mobile animation configs (for React Native Reanimated)
export const mobileSpring = {
  fast: {
    damping: 20,
    stiffness: 300,
  },
  normal: {
    damping: 15,
    stiffness: 200,
  },
  slow: {
    damping: 10,
    stiffness: 100,
  },
  bounce: {
    damping: 8,
    stiffness: 150,
    mass: 0.5,
  },
}

export const mobileTiming = {
  fast: {
    duration: durations.fast,
    easing: easings.easeOut,
  },
  normal: {
    duration: durations.normal,
    easing: easings.easeInOut,
  },
  slow: {
    duration: durations.slow,
    easing: easings.smooth,
  },
}

// Particle system configs
export const particles = {
  count: {
    low: 20,
    medium: 50,
    high: 100,
  },
  speed: {
    slow: 0.5,
    normal: 1,
    fast: 2,
  },
  size: {
    small: 2,
    medium: 4,
    large: 6,
  },
}

// Glassmorphism effect values
export const glass = {
  light: {
    blur: 10,
    opacity: 0.1,
    border: 0.2,
  },
  medium: {
    blur: 20,
    opacity: 0.15,
    border: 0.3,
  },
  heavy: {
    blur: 30,
    opacity: 0.2,
    border: 0.4,
  },
}

// Gradient animation keyframes
export const gradientKeyframes = {
  neonFlow: {
    '0%': { backgroundPosition: '0% 50%' },
    '50%': { backgroundPosition: '100% 50%' },
    '100%': { backgroundPosition: '0% 50%' },
  },
  shimmer: {
    '0%': { backgroundPosition: '-200% center' },
    '100%': { backgroundPosition: '200% center' },
  },
  wave: {
    '0%, 100%': { transform: 'translateY(0)' },
    '50%': { transform: 'translateY(-10px)' },
  },
}

// Hover effects
export const hoverEffects = {
  scale: {
    scale: 1.05,
    transition: { duration: durations.fast / 1000 },
  },
  lift: {
    y: -4,
    transition: { duration: durations.fast / 1000 },
  },
  glow: {
    boxShadow: '0 0 20px rgba(0, 217, 255, 0.5)',
    transition: { duration: durations.normal / 1000 },
  },
  tilt: {
    rotateY: 10,
    rotateX: 5,
    transition: { duration: durations.normal / 1000 },
  },
}

export default {
  durations,
  easings,
  webAnimations,
  stagger,
  pageTransitions,
  mobileSpring,
  mobileTiming,
  particles,
  glass,
  gradientKeyframes,
  hoverEffects,
}
