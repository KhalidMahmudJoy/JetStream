/**
 * JetStream Design System
 * Minimalistic Dark Theme with 4 Carefully Curated Colors
 * 
 * Design Principles:
 * - Dark theme for reduced eye strain
 * - High contrast for accessibility
 * - Minimal color palette for cohesion
 * - Purposeful use of accent colors
 */

export const colors = {
  // Primary Background - Deep Space Black
  background: {
    primary: '#0A0E27',      // Main background
    secondary: '#141B34',    // Cards, elevated surfaces
    tertiary: '#1C2541',     // Hover states, active elements
  },

  // Accent Color - Electric Blue (primary action color)
  accent: {
    primary: '#00D9FF',      // Primary actions, links, active states
    light: '#33E3FF',        // Hover states
    dark: '#00A3CC',         // Pressed states
    glow: 'rgba(0, 217, 255, 0.2)', // Glow effects
  },

  // Secondary Accent - Spotify Green (highlights, special features)
  secondary: {
    primary: '#1ED760',      // Secondary actions, badges
    light: '#1FDF64',        // Hover
    dark: '#1DB954',         // Pressed
    glow: 'rgba(30, 215, 96, 0.15)',
  },

  // Text Colors
  text: {
    primary: '#FFFFFF',      // Main text, headings
    secondary: '#A0A9C0',    // Secondary text, descriptions
    tertiary: '#6B7280',     // Placeholder, disabled text
    inverse: '#0A0E27',      // Text on light backgrounds
  },

  // Semantic Colors
  success: '#10B981',        // Success states
  warning: '#F59E0B',        // Warning states
  error: '#EF4444',          // Error states
  info: '#00D9FF',           // Info (uses accent)

  // Functional Colors
  border: {
    default: '#1C2541',      // Default borders
    focus: '#00D9FF',        // Focused elements
    subtle: '#141B34',       // Subtle dividers
  },

  // Overlay and Shadow
  overlay: 'rgba(10, 14, 39, 0.8)',
  shadow: 'rgba(0, 0, 0, 0.5)',

  // Transparent variants
  transparent: 'transparent',
  black: '#000000',
  white: '#FFFFFF',
};

export const typography = {
  fonts: {
    primary: 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    mono: 'Fira Code, Consolas, Monaco, monospace',
  },

  sizes: {
    xs: 11,
    sm: 13,
    base: 15,
    lg: 17,
    xl: 20,
    '2xl': 24,
    '3xl': 30,
    '4xl': 36,
    '5xl': 48,
  },

  weights: {
    light: '300',
    regular: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
  },

  lineHeights: {
    tight: 1.2,
    normal: 1.5,
    relaxed: 1.75,
  },
};

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  '2xl': 40,
  '3xl': 48,
  '4xl': 64,
};

export const borderRadius = {
  none: 0,
  sm: 4,
  md: 8,
  lg: 12,
  xl: 16,
  '2xl': 24,
  full: 9999,
};

export const shadows = {
  sm: {
    shadowColor: colors.shadow,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  md: {
    shadowColor: colors.shadow,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 4,
  },
  lg: {
    shadowColor: colors.shadow,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.2,
    shadowRadius: 16,
    elevation: 8,
  },
  glow: {
    shadowColor: colors.accent.primary,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.5,
    shadowRadius: 12,
    elevation: 0,
  },
};

export const animations = {
  duration: {
    fast: 150,
    normal: 250,
    slow: 350,
  },
  easing: {
    easeIn: 'ease-in',
    easeOut: 'ease-out',
    easeInOut: 'ease-in-out',
    spring: 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
  },
};

export const breakpoints = {
  mobile: 0,
  tablet: 768,
  desktop: 1024,
  wide: 1440,
};

// Preset component styles
export const components = {
  button: {
    primary: {
      backgroundColor: colors.accent.primary,
      color: colors.text.inverse,
      borderRadius: borderRadius.md,
      paddingVertical: spacing.md,
      paddingHorizontal: spacing.lg,
    },
    secondary: {
      backgroundColor: colors.background.tertiary,
      color: colors.text.primary,
      borderRadius: borderRadius.md,
      paddingVertical: spacing.md,
      paddingHorizontal: spacing.lg,
    },
    ghost: {
      backgroundColor: colors.transparent,
      color: colors.accent.primary,
      borderRadius: borderRadius.md,
      paddingVertical: spacing.md,
      paddingHorizontal: spacing.lg,
    },
  },

  card: {
    default: {
      backgroundColor: colors.background.secondary,
      borderRadius: borderRadius.lg,
      padding: spacing.md,
      ...shadows.md,
    },
    elevated: {
      backgroundColor: colors.background.tertiary,
      borderRadius: borderRadius.lg,
      padding: spacing.lg,
      ...shadows.lg,
    },
  },

  input: {
    default: {
      backgroundColor: colors.background.tertiary,
      borderColor: colors.border.default,
      borderWidth: 1,
      borderRadius: borderRadius.md,
      padding: spacing.md,
      color: colors.text.primary,
    },
    focused: {
      borderColor: colors.border.focus,
      ...shadows.glow,
    },
  },
};

// Export animation and effects systems
export * from './animations';
export * from './effects';

export const theme = {
  colors,
  typography,
  spacing,
  borderRadius,
  shadows,
  animations,
  breakpoints,
  components,
};

export type Theme = typeof theme;
export default theme;
