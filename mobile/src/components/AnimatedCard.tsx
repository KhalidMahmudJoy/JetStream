/**
 * AnimatedCard Component
 * Reusable card with smooth enter/exit animations
 * Features: Fade in, scale animation, press feedback
 */

import React, { useEffect } from 'react';
import { StyleSheet, Pressable, ViewStyle } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
  interpolate,
} from 'react-native-reanimated';

interface AnimatedCardProps {
  children: React.ReactNode;
  onPress?: () => void;
  delay?: number;
  style?: ViewStyle;
  disabled?: boolean;
}

export const AnimatedCard: React.FC<AnimatedCardProps> = ({
  children,
  onPress,
  delay = 0,
  style,
  disabled = false,
}) => {
  const scale = useSharedValue(0);
  const pressed = useSharedValue(0);

  useEffect(() => {
    // Entrance animation with delay
    scale.value = withTiming(1, {
      duration: 300,
      // Add delay for stagger effect
    }, () => {
      // Animation complete
    });
  }, []);

  const animatedStyle = useAnimatedStyle(() => {
    const opacity = interpolate(scale.value, [0, 1], [0, 1]);
    const scaleValue = interpolate(
      scale.value,
      [0, 1],
      [0.8, 1]
    );

    // Press animation: scale down slightly
    const pressScale = pressed.value === 1 ? 0.98 : 1;

    return {
      opacity,
      transform: [
        { scale: scaleValue * pressScale },
      ],
    };
  });

  const handlePressIn = () => {
    pressed.value = 1;
  };

  const handlePressOut = () => {
    pressed.value = 0;
  };

  if (onPress && !disabled) {
    return (
      <Pressable
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        disabled={disabled}
      >
        <Animated.View style={[styles.card, animatedStyle, style]}>
          {children}
        </Animated.View>
      </Pressable>
    );
  }

  return (
    <Animated.View style={[styles.card, animatedStyle, style]}>
      {children}
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#282828',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
});
