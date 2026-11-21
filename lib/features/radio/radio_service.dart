import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Serviço de player — just_audio com stream real configurável.
/// A URL do stream vem das Configurações (SharedPreferences).
class RadioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  String streamUrl = '';
  bool isPlaying = false;
  bool isBuffering = false;
  double volume = 0.8;
  String? error;

  RadioService() {
    _player.playingStream.listen((playing) {
      isPlaying = playing;
      notifyListeners();
    });
    _player.processingStateStream.listen((state) {
      isBuffering = state == ProcessingState.loading ||
          state == ProcessingState.buffering;
      notifyListeners();
    });
    _player.setVolume(volume);
  }

  Future<void> setStream(String url) async {
    streamUrl = url;
    error = null;
    if (url.isEmpty) return;
    try {
      await _player.setUrl(url);
    } catch (e) {
      error = 'Falha ao carregar o stream. Verifique a URL nas Configurações.';
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    if (streamUrl.isEmpty) {
      error = 'Configure a URL do stream nas Configurações.';
      notifyListeners();
      return;
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_player.audioSource == null) {
        await setStream(streamUrl);
      }
      await _player.play();
    }
  }

  Future<void> setVolume(double value) async {
    volume = value.clamp(0.0, 1.0);
    await _player.setVolume(volume);
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
