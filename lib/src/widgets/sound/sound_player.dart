import 'package:audioplayers/audioplayers.dart';

class SoundPlayer {
  static final AudioPlayer _player = AudioPlayer();

  // Constructor opcionalmente puede permitir configurar el volumen, entre otras cosas
  SoundPlayer();

  static Future<void> playSound(String sound) async {
    try {
      await _player.play(AssetSource('sounds/$sound'));
    } catch (e) {
      print('Error reproduciendo sonido: $e');
    }
  }

  static Future<void> stopSound() async {
    await _player.stop();
  }

  static Future<void> pauseSound() async {
    await _player.pause();
  }

  static Future<void> resumeSound() async {
    await _player.resume();
  }

  void dispose() {
    _player.dispose();
  }
}
