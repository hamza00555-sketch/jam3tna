import 'dart:async';

import 'package:just_audio/just_audio.dart';

/// خدمة بسيطة لتشغيل ملف صوت من assets مع loop.
///
/// تُستخدم حالياً لتكبيرات العيد. مصمَّمة لتفشل بهدوء إذا لم
/// يوجد الملف (لا crash، فقط تُرجع false).
class AudioService {
  AudioPlayer? _player;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// يحاول تشغيل [assetPath] مع loop. يُرجع true لو نجح.
  Future<bool> playLoop(String assetPath) async {
    try {
      await stop();
      _player = AudioPlayer();
      await _player!.setAsset(assetPath);
      await _player!.setLoopMode(LoopMode.all);
      await _player!.setVolume(0.85);
      unawaited(_player!.play());
      _isPlaying = true;
      return true;
    } catch (_) {
      _isPlaying = false;
      await _disposePlayer();
      return false;
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    try {
      await _player?.stop();
    } catch (_) {}
    await _disposePlayer();
  }

  Future<void> _disposePlayer() async {
    try {
      await _player?.dispose();
    } catch (_) {}
    _player = null;
  }
}
