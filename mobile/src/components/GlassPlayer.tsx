/**
 * GlassPlayer Component
 * Mini player at bottom with glassmorphism effect
 * Features: Album art, track info, play/pause, progress bar, tap to expand
 */

import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  Pressable,
  Dimensions,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { BlurView } from 'expo-blur';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import { AlbumArt } from './AlbumArt';

const { width } = Dimensions.get('window');

interface Track {
  id: string;
  title: string;
  artist: string;
  albumArt?: string;
}

interface GlassPlayerProps {
  track: Track | null;
  isPlaying: boolean;
  progress: number; // 0 to 1
  onPlayPause: () => void;
  onNext?: () => void;
  onExpand?: () => void;
}

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export const GlassPlayer: React.FC<GlassPlayerProps> = ({
  track,
  isPlaying,
  progress,
  onPlayPause,
  onNext,
  onExpand,
}) => {
  const scale = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const handlePressIn = () => {
    scale.value = withSpring(0.98);
  };

  const handlePressOut = () => {
    scale.value = withSpring(1);
  };

  if (!track) return null;

  return (
    <View style={styles.container}>
      {/* Progress bar */}
      <View style={styles.progressBarContainer}>
        <View style={[styles.progressBar, { width: `${progress * 100}%` }]} />
      </View>

      {/* Glass effect background */}
      <BlurView intensity={80} tint="dark" style={styles.blurContainer}>
        <AnimatedPressable
          onPress={onExpand}
          onPressIn={handlePressIn}
          onPressOut={handlePressOut}
          style={[styles.content, animatedStyle]}
        >
          {/* Album Art Thumbnail */}
          <AlbumArt uri={track.albumArt} size={48} borderRadius={8} />

          {/* Track Info */}
          <View style={styles.info}>
            <Text style={styles.title} numberOfLines={1}>
              {track.title}
            </Text>
            <Text style={styles.artist} numberOfLines={1}>
              {track.artist}
            </Text>
          </View>

          {/* Controls */}
          <View style={styles.controls}>
            {/* Play/Pause Button */}
            <Pressable onPress={onPlayPause} style={styles.playButton}>
              <Ionicons
                name={isPlaying ? 'pause' : 'play'}
                size={28}
                color="#FFFFFF"
              />
            </Pressable>

            {/* Next Button */}
            {onNext && (
              <Pressable onPress={onNext} style={styles.nextButton}>
                <Ionicons name="play-skip-forward" size={24} color="#FFFFFF" />
              </Pressable>
            )}
          </View>
        </AnimatedPressable>
      </BlurView>

      {/* Gradient overlay for depth */}
      <LinearGradient
        colors={['rgba(0,0,0,0.3)', 'rgba(0,0,0,0)']}
        style={styles.gradientOverlay}
        pointerEvents="none"
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: 80,
    zIndex: 100,
  },
  progressBarContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 2,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
  },
  progressBar: {
    height: '100%',
    backgroundColor: '#1ED760',
  },
  blurContainer: {
    flex: 1,
    overflow: 'hidden',
  },
  gradientOverlay: {
    position: 'absolute',
    top: 2,
    left: 0,
    right: 0,
    height: 30,
  },
  content: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  info: {
    flex: 1,
    marginLeft: 12,
    marginRight: 12,
  },
  title: {
    fontSize: 14,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 2,
  },
  artist: {
    fontSize: 12,
    color: '#B3B3B3',
  },
  controls: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  playButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(30, 215, 96, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 8,
  },
  nextButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
