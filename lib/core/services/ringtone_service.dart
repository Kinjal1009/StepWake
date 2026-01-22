import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RingtoneService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String url) async {
    try {
      await _player.setUrl(url);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
    } catch (e) {
      // Ignore errors in background
    }
  }

  void stop() {
    _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}

final ringtoneServiceProvider = Provider<RingtoneService>((ref) {
  final service = RingtoneService();
  ref.onDispose(() => service.dispose());
  return service;
});
