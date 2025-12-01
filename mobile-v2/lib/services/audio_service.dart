import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../shared/models/track.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  AudioSession? _audioSession;

  AudioPlayer get player => _player;
  
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;
  
  Future<void> init() async {
    // Configure audio session for playback
    _audioSession = await AudioSession.instance;
    await _audioSession!.configure(const AudioSessionConfiguration.music());

    // Handle audio interruptions (calls, alarms, etc.)
    _audioSession!.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // Lower volume
            _player.setVolume(0.3);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            // Pause playback
            _player.pause();
            break;
        }
      } else {
        // Resume normal volume
        if (event.type == AudioInterruptionType.duck) {
          _player.setVolume(1.0);
        }
      }
    });

    // Handle becoming noisy (headphones unplugged)
    _audioSession!.becomingNoisyEventStream.listen((_) {
      _player.pause();
    });

    // Listen to playback events for automatic track progression
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Track finished, player will automatically move to next
      }
    });
  }

  Future<void> playTrack(Track track, {List<Track>? playlist}) async {
    try {
      if (track.previewUrl == null || track.previewUrl!.isEmpty) {
        throw Exception('No preview URL available for this track');
      }

      // Create audio source
      final audioSource = AudioSource.uri(
        Uri.parse(track.previewUrl!),
        tag: {
          'id': track.id,
          'title': track.title,
          'artist': track.artist,
          'album': track.album ?? 'Unknown Album',
          'albumArt': track.albumArt,
        },
      );

      // If playlist provided, create a playlist
      if (playlist != null && playlist.isNotEmpty) {
        final sources = playlist
            .where((t) => t.previewUrl != null && t.previewUrl!.isNotEmpty)
            .map((t) => AudioSource.uri(
          Uri.parse(t.previewUrl!),
          tag: {
            'id': t.id,
            'title': t.title,
            'artist': t.artist,
            'album': t.album ?? 'Unknown Album',
            'albumArt': t.albumArt,
          },
        )).toList();

        final playlistSource = ConcatenatingAudioSource(children: sources);
        
        await _player.setAudioSource(
          playlistSource,
          initialIndex: playlist.indexWhere((t) => t.id == track.id),
        );
      } else {
        await _player.setAudioSource(audioSource);
      }

      await _player.play();
    } catch (e) {
      print('Error playing track: $e');
      throw Exception('Failed to play track');
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> skipToNext() async {
    await _player.seekToNext();
  }

  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed.clamp(0.5, 2.0));
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    await _player.setLoopMode(loopMode);
  }

  Future<void> setShuffleModeEnabled(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> addToQueue(Track track) async {
    if (track.previewUrl == null || track.previewUrl!.isEmpty) {
      throw Exception('No preview URL available for this track');
    }

    final audioSource = AudioSource.uri(
      Uri.parse(track.previewUrl!),
      tag: {
        'id': track.id,
        'title': track.title,
        'artist': track.artist,
        'album': track.album ?? 'Unknown Album',
        'albumArt': track.albumArt,
      },
    );

    if (_player.audioSource is ConcatenatingAudioSource) {
      await (_player.audioSource as ConcatenatingAudioSource).add(audioSource);
    }
  }

  Future<void> removeFromQueue(int index) async {
    if (_player.audioSource is ConcatenatingAudioSource) {
      await (_player.audioSource as ConcatenatingAudioSource).removeAt(index);
    }
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (_player.audioSource is ConcatenatingAudioSource) {
      await (_player.audioSource as ConcatenatingAudioSource).move(oldIndex, newIndex);
    }
  }

  Future<void> clearQueue() async {
    if (_player.audioSource is ConcatenatingAudioSource) {
      await (_player.audioSource as ConcatenatingAudioSource).clear();
    }
  }

  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get isPlaying => _player.playing;
  double get volume => _player.volume;
  double get speed => _player.speed;
  LoopMode get loopMode => _player.loopMode;
  bool get shuffleModeEnabled => _player.shuffleModeEnabled;

  List<IndexedAudioSource> get queue {
    final audioSource = _player.audioSource;
    if (audioSource is ConcatenatingAudioSource) {
      return audioSource.children.cast<IndexedAudioSource>();
    }
    return [];
  }

  int? get currentIndex => _player.currentIndex;

  void dispose() {
    _player.dispose();
  }
}
