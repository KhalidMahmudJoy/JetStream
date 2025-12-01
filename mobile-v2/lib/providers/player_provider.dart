import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../shared/models/track.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  Track? _currentTrack;
  List<Track> _queue = [];
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.off;
  
  // Getters
  Track? get currentTrack => _currentTrack;
  List<Track> get queue => List.unmodifiable(_queue);
  bool get isPlaying => _audioPlayer.playing;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;
  Duration get position => _audioPlayer.position;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;
  double get volume => _audioPlayer.volume;
  double get playbackSpeed => _audioPlayer.speed;
  
  bool get hasNext => _queue.isNotEmpty;
  bool get hasPrevious => position.inSeconds > 3;

  PlayerProvider() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      notifyListeners();
      if (state.processingState == ProcessingState.completed) {
        _onTrackFinished();
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((_) => notifyListeners());
    
    // Listen to duration changes
    _audioPlayer.durationStream.listen((_) => notifyListeners());
  }

  void _onTrackFinished() {
    if (_repeatMode == RepeatMode.one) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else {
      skipNext();
    }
  }

  // Play track
  Future<void> playTrack(Track track, {List<Track>? playlist}) async {
    _currentTrack = track;
    
    if (playlist != null) {
      _queue = playlist.where((t) => t.id != track.id).toList();
      if (_isShuffle) {
        _queue.shuffle();
      }
    }
    
    try {
      if (track.previewUrl != null) {
        await _audioPlayer.setUrl(track.previewUrl!);
        await _audioPlayer.play();
      } else {
        debugPrint("No preview URL for track: ${track.title}");
      }
    } catch (e) {
      debugPrint("Error playing track: $e");
    }
    
    notifyListeners();
  }

  // Playback controls
  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    notifyListeners();
  }

  Future<void> play() async {
    await _audioPlayer.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  Future<void> skipNext() async {
    if (_queue.isEmpty) {
      if (_repeatMode == RepeatMode.all && _currentTrack != null) {
        // If repeat all and queue empty, just replay current (simplified logic)
        // Ideally we should have the full original list to loop back
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();
      }
      return;
    }
    
    final nextTrack = _queue.removeAt(0);
    // Add current track to end of queue if repeat all? 
    // For now, simple queue logic
    await playTrack(nextTrack);
  }

  Future<void> skipPrevious() async {
    if (position.inSeconds > 3) {
      await seek(Duration.zero);
    } else {
      // Logic to go to previous track in history would go here
      // For now just restart
      await seek(Duration.zero);
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
    notifyListeners();
  }

  // Queue management
  void addToQueue(Track track) {
    _queue.add(track);
    notifyListeners();
  }

  void addAllToQueue(List<Track> tracks) {
    _queue.addAll(tracks);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      notifyListeners();
    }
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final track = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, track);
    notifyListeners();
  }

  void clearQueue() {
    _queue.clear();
    notifyListeners();
  }

  // Shuffle & Repeat
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    if (_isShuffle) {
      _queue.shuffle();
    }
    notifyListeners();
  }

  void toggleRepeat() {
    _repeatMode = RepeatMode.values[(_repeatMode.index + 1) % RepeatMode.values.length];
    notifyListeners();
  }

  // Stop
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentTrack = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

enum RepeatMode {
  off,
  one,
  all,
}
