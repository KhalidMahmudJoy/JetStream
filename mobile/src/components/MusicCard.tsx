/**
 * MusicCard Component
 * Display track/album with play button and gestures
 * Features: Swipe actions, long press, album art, track info
 */

import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  Image,
  Pressable,
  Dimensions,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';

const { width } = Dimensions.get('window');
const CARD_WIDTH = width - 32; // 16px padding on each side

interface Track {
  id: string;
  title: string;
  artist: string;
  albumArt?: string;
  duration?: number;
}

interface MusicCardProps {
  track: Track;
  onPress?: () => void;
  onPlay?: () => void;
  onLike?: () => void;
  isLiked?: boolean;
  isPlaying?: boolean;
}

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export const MusicCard: React.FC<MusicCardProps> = ({
  track,
  onPress,
  onPlay,
  onLike,
  isLiked = false,
  isPlaying = false,
}) => {
  const pressed = useSharedValue(0);
  const translateX = useSharedValue(0);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { scale: pressed.value === 1 ? 0.98 : 1 },
      { translateX: translateX.value },
    ],
  }));

  // Swipe gesture for like action
  const panGesture = Gesture.Pan()
    .onUpdate((event) => {
      if (event.translationX < 0) {
        translateX.value = event.translationX * 0.5; // Resistance effect
      }
    })
    .onEnd(() => {
      if (translateX.value < -50 && onLike) {
        // Swipe left detected - trigger like
        onLike();
      }
      translateX.value = withSpring(0);
    });

  const handlePressIn = () => {
    pressed.value = 1;
  };

  const handlePressOut = () => {
    pressed.value = 0;
  };

  const formatDuration = (seconds?: number) => {
    if (!seconds) return '--:--';
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <GestureDetector gesture={panGesture}>
      <AnimatedPressable
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        style={[styles.card, animatedStyle]}
      >
        <View style={styles.content}>
          {/* Album Art */}
          <View style={styles.albumArtContainer}>
            {track.albumArt ? (
              <Image source={{ uri: track.albumArt }} style={styles.albumArt} />
            ) : (
              <View style={[styles.albumArt, styles.placeholderArt]}>
                <Ionicons name="musical-notes" size={24} color="#878787" />
              </View>
            )}
            {/* Play indicator overlay */}
            {isPlaying && (
              <View style={styles.playingOverlay}>
                <Ionicons name="volume-high" size={20} color="#1ED760" />
              </View>
            )}
          </View>

          {/* Track Info */}
          <View style={styles.info}>
            <Text style={styles.title} numberOfLines={1}>
              {track.title}
            </Text>
            <Text style={styles.artist} numberOfLines={1}>
              {track.artist}
            </Text>
          </View>

          {/* Duration */}
          <Text style={styles.duration}>{formatDuration(track.duration)}</Text>

          {/* Play Button */}
          {onPlay && (
            <Pressable onPress={onPlay} style={styles.playButton}>
              <Ionicons
                name={isPlaying ? 'pause' : 'play'}
                size={24}
                color="#1ED760"
              />
            </Pressable>
          )}
        </View>

        {/* Like button (appears on swipe) */}
        {onLike && (
          <Animated.View style={[styles.likeAction, { right: -translateX.value }]}>
            <Ionicons
              name={isLiked ? 'heart' : 'heart-outline'}
              size={24}
              color="#1ED760"
            />
          </Animated.View>
        )}
      </AnimatedPressable>
    </GestureDetector>
  );
};

const styles = StyleSheet.create({
  card: {
    width: CARD_WIDTH,
    backgroundColor: '#282828',
    borderRadius: 12,
    marginHorizontal: 16,
    marginVertical: 6,
    overflow: 'hidden',
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
  },
  albumArtContainer: {
    position: 'relative',
  },
  albumArt: {
    width: 56,
    height: 56,
    borderRadius: 8,
  },
  placeholderArt: {
    backgroundColor: '#181818',
    justifyContent: 'center',
    alignItems: 'center',
  },
  playingOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 8,
  },
  info: {
    flex: 1,
    marginLeft: 12,
    marginRight: 8,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  artist: {
    fontSize: 14,
    color: '#B3B3B3',
  },
  duration: {
    fontSize: 14,
    color: '#878787',
    marginRight: 8,
  },
  playButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(30, 215, 96, 0.1)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  likeAction: {
    position: 'absolute',
    right: 0,
    top: 0,
    bottom: 0,
    width: 80,
    backgroundColor: '#1ED760',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
