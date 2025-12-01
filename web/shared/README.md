# Shared Module

This module contains shared code, types, and utilities used across all JetStream applications (mobile, web, desktop, backend).

## Contents

### 📐 Theme (`/theme`)
The complete design system for JetStream with minimalistic dark UI.

**Key Features:**
- 4-color palette (Deep Space Black, Electric Blue, Vibrant Purple)
- Typography scale and font definitions
- Spacing and layout constants
- Border radius and shadow presets
- Animation timing and easing
- Component style presets

**Usage:**
```typescript
import { colors, spacing, typography } from '../shared/theme';

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.background.primary,
    padding: spacing.lg,
  },
  title: {
    fontSize: typography.sizes.xl,
    color: colors.text.primary,
  },
});
```

### 🔤 Types (`/types`)
Comprehensive TypeScript interfaces and types.

**Includes:**
- Audio types (Track, Album, Artist, Playlist)
- User types (User, UserPreferences)
- Playback types (PlaybackState, AudioSettings)
- AI/ML types (Recommendation, MoodAnalysis)
- Blockchain types (NFTPlaylist, NFTMetadata)
- Plugin types (Plugin, PluginType, PluginPermission)
- API types (ApiResponse, PaginatedResponse)

**Usage:**
```typescript
import { Track, Playlist, User } from '../shared/types';

const track: Track = {
  id: '123',
  title: 'Song Name',
  artist: 'Artist Name',
  // ...
};
```

## Design Philosophy

### Color Palette
1. **Background Primary** (`#0A0E27`) - Deep space black for main background
2. **Accent Blue** (`#00D9FF`) - Electric blue for primary actions and focus
3. **Accent Purple** (`#9D4EDD`) - Vibrant purple for secondary highlights
4. **Text Primary** (`#FFFFFF`) - White for maximum readability

### Principles
- **Minimalism**: Use only necessary elements
- **Consistency**: Follow design system strictly
- **Accessibility**: High contrast, readable typography
- **Performance**: Lightweight, optimized constants

## Adding New Shared Code

### Adding a New Type
```typescript
// shared/types/index.ts
export interface NewType {
  id: string;
  // ... properties
}
```

### Adding Theme Values
```typescript
// shared/theme/index.ts
export const newThemeValue = {
  // ... values
};
```

## Best Practices

1. **Keep it DRY**: Don't duplicate types or constants
2. **Type Everything**: Use TypeScript for all shared code
3. **Document Changes**: Update this README when adding new exports
4. **Maintain Consistency**: Follow existing patterns
5. **Test Imports**: Ensure imports work across all modules

## Importing from Other Modules

### Mobile/Web/Desktop
```typescript
import { colors } from '@/theme';
import { Track } from '@/types';
```

### Backend
```typescript
import { Track, User } from '../shared/types';
```

## File Structure

```
shared/
├── theme/
│   └── index.ts          # Design system
├── types/
│   └── index.ts          # TypeScript interfaces
└── README.md             # This file
```

## Maintenance

When updating shared code:
1. Ensure backward compatibility
2. Update all dependent modules
3. Test across all platforms
4. Document breaking changes

## Future Additions

Planned shared modules:
- `/utils` - Common utility functions
- `/constants` - App-wide constants
- `/validators` - Data validation schemas
- `/hooks` - Reusable React hooks (if applicable)

---

This shared module is the foundation of JetStream's consistency across all platforms.
