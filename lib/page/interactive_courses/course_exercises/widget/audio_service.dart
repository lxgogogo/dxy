import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> playSequentially(List<String> urls) async {
    for (final url in urls) {
      if (_isPlaying) await player.stop(); // 停止当前播放

      await player.play(UrlSource(url));
      _isPlaying = true;

      // 等待当前音频播放完成
      await player.onPlayerStateChanged.firstWhere(
              (state) => state == PlayerState.completed
      );
    }
  }

  static void dispose() {
    player.dispose();
  }
}