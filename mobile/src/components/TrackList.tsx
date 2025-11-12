/**
 * TrackList Component
 * Optimized scrollable list of tracks with virtualization
 * Features: FlatList, pull to refresh, empty state, loading state
 */

import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  FlatList,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { MusicCard } from './MusicCard';

interface Track {
  id: string;
  title: string;
  artist: string;
  albumArt?: string;
  duration?: number;
}

interface TrackListProps {
  tracks: Track[];
  onTrackPress?: (track: Track) => void;
  onTrackPlay?: (track: Track) => void;
  onTrackLike?: (track: Track) => void;
  likedTrackIds?: Set<string>;
  currentTrackId?: string;
  isPlaying?: boolean;
  loading?: boolean;
  refreshing?: boolean;
  onRefresh?: () => void;
  emptyMessage?: string;
  ListHeaderComponent?: React.ComponentType<any> | React.ReactElement | null;
}

export const TrackList: React.FC<TrackListProps> = ({
  tracks,
  onTrackPress,
  onTrackPlay,
  onTrackLike,
  likedTrackIds = new Set(),
  currentTrackId,
  isPlaying = false,
  loading = false,
  refreshing = false,
  onRefresh,
  emptyMessage = 'No tracks found',
  ListHeaderComponent,
}) => {
  const renderItem = ({ item, index }: { item: Track; index: number }) => (
    <MusicCard
      track={item}
      onPress={() => onTrackPress?.(item)}
      onPlay={() => onTrackPlay?.(item)}
      onLike={() => onTrackLike?.(item)}
      isLiked={likedTrackIds.has(item.id)}
      isPlaying={currentTrackId === item.id && isPlaying}
    />
  );

  const renderEmpty = () => {
    if (loading) {
      return (
        <View style={styles.centerContainer}>
          <ActivityIndicator size="large" color="#1ED760" />
          <Text style={styles.loadingText}>Loading tracks...</Text>
        </View>
      );
    }

    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>{emptyMessage}</Text>
        <Text style={styles.emptySubtext}>
          Try searching for your favorite music
        </Text>
      </View>
    );
  };

  const keyExtractor = (item: Track) => item.id;

  return (
    <FlatList
      data={tracks}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      ListHeaderComponent={ListHeaderComponent}
      ListEmptyComponent={renderEmpty}
      contentContainerStyle={[
        styles.container,
        tracks.length === 0 && styles.emptyListContainer,
      ]}
      refreshControl={
        onRefresh ? (
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor="#1ED760"
            colors={['#1ED760']}
          />
        ) : undefined
      }
      showsVerticalScrollIndicator={false}
      // Performance optimizations
      removeClippedSubviews={true}
      maxToRenderPerBatch={10}
      updateCellsBatchingPeriod={50}
      initialNumToRender={10}
      windowSize={21}
    />
  );
};

const styles = StyleSheet.create({
  container: {
    paddingTop: 8,
    paddingBottom: 100, // Space for mini player
  },
  emptyListContainer: {
    flexGrow: 1,
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 60,
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#B3B3B3',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 60,
    paddingHorizontal: 40,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFFFFF',
    textAlign: 'center',
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#878787',
    textAlign: 'center',
  },
});
