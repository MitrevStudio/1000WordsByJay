import 'package:audioplayers/audioplayers.dart';
import '../constants/asset_paths.dart';

/// Audio service for playing feedback sounds
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _streakPlayer = AudioPlayer();

  /// Whether sound is enabled
  bool soundEnabled = true;

  /// Play correct answer sound
  Future<void> playCorrect() async {
    if (!soundEnabled) return;
    await _player.play(AssetSource(AssetPaths.correctSound));
  }

  /// Play wrong answer sound
  Future<void> playWrong() async {
    if (!soundEnabled) return;
    await _player.play(AssetSource(AssetPaths.wrongSound));
  }

  /// Play streak celebration sound
  Future<void> playStreak() async {
    if (!soundEnabled) return;
    try {
      await _streakPlayer.setVolume(0.8);
      await _streakPlayer.play(AssetSource(AssetPaths.streakSound));
    } catch (_) {
      // Silently fail if sound file not available
    }
  }

  /// Dispose the audio player
  void dispose() {
    _player.dispose();
    _streakPlayer.dispose();
  }
}
