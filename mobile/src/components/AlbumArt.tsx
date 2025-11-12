/**
 * AlbumArt Component
 * Optimized image component with caching, loading states, and animations
 * Features: Fade-in animation, placeholder, error handling
 */

import React, { useState } from 'react';
import { StyleSheet, View, Image, ImageStyle, ViewStyle } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
} from 'react-native-reanimated';

interface AlbumArtProps {
  uri?: string;
  size?: number;
  borderRadius?: number;
  style?: ViewStyle | ImageStyle;
}

export const AlbumArt: React.FC<AlbumArtProps> = ({
  uri,
  size = 200,
  borderRadius = 12,
  style,
}) => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const opacity = useSharedValue(0);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
  }));

  const handleLoadEnd = () => {
    setLoading(false);
    opacity.value = withTiming(1, { duration: 300 });
  };

  const handleError = () => {
    setLoading(false);
    setError(true);
  };

  return (
    <View
      style={[
        styles.container,
        { width: size, height: size, borderRadius },
        style,
      ]}
    >
      {/* Placeholder/Error state */}
      {(loading || error || !uri) && (
        <View style={[styles.placeholder, { borderRadius }]}>
          <Ionicons
            name="musical-notes"
            size={size * 0.4}
            color="#878787"
          />
        </View>
      )}

      {/* Actual image */}
      {uri && !error && (
        <Animated.Image
          source={{ uri }}
          style={[
            styles.image,
            { width: size, height: size, borderRadius },
            animatedStyle,
          ]}
          onLoadEnd={handleLoadEnd}
          onError={handleError}
          resizeMode="cover"
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    overflow: 'hidden',
    backgroundColor: '#181818',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 4.65,
    elevation: 8,
  },
  placeholder: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#282828',
    justifyContent: 'center',
    alignItems: 'center',
  },
  image: {
    position: 'absolute',
    top: 0,
    left: 0,
  },
});
