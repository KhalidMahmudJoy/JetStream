/**
 * Home Screen - Main landing page with minimalistic dark design
 */

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  Dimensions,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';

import { colors, spacing, borderRadius, typography } from '../theme';
import { useAppSelector } from '../store';
import { AnimatedCard, MusicCard, NeonButton } from '../components';

const { width } = Dimensions.get('window');

export default function HomeScreen() {
  const { currentUser } = useAppSelector((state) => state.user);
  
  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  };

  return (
    <View style={styles.container}>
      <ScrollView 
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Header Section */}
        <View style={styles.header}>
          <View>
            <Text style={styles.greeting}>{getGreeting()}</Text>
            <Text style={styles.username}>{currentUser?.displayName || 'Music Lover'}</Text>
          </View>
          <TouchableOpacity style={styles.settingsButton}>
            <Ionicons name="settings-outline" size={24} color={colors.text.secondary} />
          </TouchableOpacity>
        </View>

        {/* Quick Play Section */}
        <AnimatedCard delay={0}>
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Quick Play</Text>
            <View style={styles.quickPlayGrid}>
              {mockQuickPlay.map((item) => (
                <TouchableOpacity key={item.id} style={styles.quickPlayItem}>
                  <Image source={{ uri: item.image }} style={styles.quickPlayImage} />
                  <Text style={styles.quickPlayTitle} numberOfLines={1}>
                    {item.title}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>
        </AnimatedCard>

        {/* Recently Played */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Recently Played</Text>
            <TouchableOpacity>
              <Text style={styles.seeAll}>See all</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.trackList}>
            {mockTracks.map((track, index) => (
              <AnimatedCard key={track.id} delay={index * 100}>
                <MusicCard
                  track={{
                    id: track.id,
                    title: track.title,
                    artist: track.artist,
                    albumArt: track.image,
                    duration: 225, // 3:45 in seconds
                  }}
                  isPlaying={false}
                  onPress={() => console.log('Play:', track.title)}
                  onPlay={() => console.log('Play button:', track.title)}
                  onLike={() => console.log('Liked:', track.title)}
                />
              </AnimatedCard>
            ))}
          </View>
        </View>

        {/* AI Recommendations */}
        <View style={styles.section}>
          <View style={styles.aiHeader}>
            <Ionicons name="sparkles" size={20} color={colors.secondary.primary} />
            <Text style={styles.aiTitle}>Made for You</Text>
          </View>
          <Text style={styles.aiSubtitle}>AI-powered recommendations</Text>
          <ScrollView 
            horizontal 
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.horizontalScroll}
          >
            {mockPlaylists.map((playlist) => (
              <TouchableOpacity key={playlist.id} style={styles.playlistCard}>
                <View style={styles.playlistImageContainer}>
                  <Image source={{ uri: playlist.image }} style={styles.playlistImage} />
                  <View style={styles.glowOverlay} />
                </View>
                <Text style={styles.playlistTitle} numberOfLines={2}>
                  {playlist.title}
                </Text>
                <Text style={styles.playlistDescription} numberOfLines={2}>
                  {playlist.description}
                </Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>

        {/* Spacer for mini player */}
        <View style={styles.bottomSpacer} />
      </ScrollView>
    </View>
  );
}

// Mock Data
const mockQuickPlay = [
  { id: '1', title: 'Liked Songs', image: 'https://picsum.photos/200/200?random=1' },
  { id: '2', title: 'Chill Vibes', image: 'https://picsum.photos/200/200?random=2' },
  { id: '3', title: 'Workout Mix', image: 'https://picsum.photos/200/200?random=3' },
  { id: '4', title: 'Focus Flow', image: 'https://picsum.photos/200/200?random=4' },
  { id: '5', title: 'Night Drive', image: 'https://picsum.photos/200/200?random=5' },
  { id: '6', title: 'Morning Energy', image: 'https://picsum.photos/200/200?random=6' },
];

const mockTracks = [
  { id: '1', title: 'Midnight Dreams', artist: 'Luna Eclipse', image: 'https://picsum.photos/300/300?random=10' },
  { id: '2', title: 'Electric Pulse', artist: 'Neon Waves', image: 'https://picsum.photos/300/300?random=11' },
  { id: '3', title: 'Urban Symphony', artist: 'City Lights', image: 'https://picsum.photos/300/300?random=12' },
  { id: '4', title: 'Cosmic Journey', artist: 'Stellar Sound', image: 'https://picsum.photos/300/300?random=13' },
];

const mockPlaylists = [
  { id: '1', title: 'Your Daily Mix', description: 'Based on your listening habits', image: 'https://picsum.photos/400/400?random=20' },
  { id: '2', title: 'Discover Weekly', description: 'Fresh tracks picked for you', image: 'https://picsum.photos/400/400?random=21' },
  { id: '3', title: 'Mood Booster', description: 'Energetic vibes to lift you up', image: 'https://picsum.photos/400/400?random=22' },
];

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background.primary,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: spacing['4xl'],
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
    paddingTop: spacing.lg,
    paddingBottom: spacing.xl,
  },
  greeting: {
    fontSize: typography.sizes.sm,
    color: colors.text.secondary,
    fontWeight: '500',
    marginBottom: spacing.xs,
  },
  username: {
    fontSize: typography.sizes['3xl'],
    color: colors.text.primary,
    fontWeight: '700',
  },
  settingsButton: {
    padding: spacing.sm,
  },
  section: {
    marginBottom: spacing.xl,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
    marginBottom: spacing.md,
  },
  sectionTitle: {
    fontSize: typography.sizes.xl,
    color: colors.text.primary,
    fontWeight: '700',
    paddingHorizontal: spacing.lg,
    marginBottom: spacing.md,
  },
  seeAll: {
    fontSize: typography.sizes.sm,
    color: colors.accent.primary,
    fontWeight: '600',
  },
  quickPlayGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingHorizontal: spacing.lg,
    gap: spacing.md,
  },
  quickPlayItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.background.secondary,
    borderRadius: borderRadius.md,
    width: (width - spacing.lg * 2 - spacing.md) / 2,
    overflow: 'hidden',
  },
  quickPlayImage: {
    width: 60,
    height: 60,
  },
  quickPlayTitle: {
    flex: 1,
    fontSize: typography.sizes.sm,
    color: colors.text.primary,
    fontWeight: '600',
    paddingHorizontal: spacing.md,
  },
  horizontalScroll: {
    paddingHorizontal: spacing.lg,
    gap: spacing.md,
  },
  trackCard: {
    width: 140,
  },
  trackImageContainer: {
    position: 'relative',
    width: 140,
    height: 140,
    borderRadius: borderRadius.md,
    overflow: 'hidden',
    marginBottom: spacing.sm,
  },
  trackImage: {
    width: '100%',
    height: '100%',
  },
  trackGradient: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: '50%',
  },
  playButton: {
    position: 'absolute',
    right: spacing.sm,
    bottom: spacing.sm,
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: colors.accent.primary,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: colors.accent.primary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.5,
    shadowRadius: 8,
    elevation: 8,
  },
  trackTitle: {
    fontSize: typography.sizes.base,
    color: colors.text.primary,
    fontWeight: '600',
    marginBottom: spacing.xs,
  },
  trackArtist: {
    fontSize: typography.sizes.sm,
    color: colors.text.secondary,
  },
  aiHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
    marginBottom: spacing.xs,
    gap: spacing.sm,
  },
  aiTitle: {
    fontSize: typography.sizes.xl,
    color: colors.text.primary,
    fontWeight: '700',
  },
  aiSubtitle: {
    fontSize: typography.sizes.sm,
    color: colors.text.secondary,
    paddingHorizontal: spacing.lg,
    marginBottom: spacing.md,
  },
  playlistCard: {
    width: 160,
  },
  playlistImageContainer: {
    position: 'relative',
    width: 160,
    height: 160,
    borderRadius: borderRadius.lg,
    overflow: 'hidden',
    marginBottom: spacing.sm,
  },
  playlistImage: {
    width: '100%',
    height: '100%',
  },
  glowOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: colors.secondary.glow,
  },
  playlistTitle: {
    fontSize: typography.sizes.base,
    color: colors.text.primary,
    fontWeight: '600',
    marginBottom: spacing.xs,
    lineHeight: 20,
  },
  playlistDescription: {
    fontSize: typography.sizes.sm,
    color: colors.text.secondary,
    lineHeight: 18,
  },
  bottomSpacer: {
    height: 80,
  },
  trackList: {
    paddingHorizontal: spacing.md,
    gap: spacing.sm,
  },
});
