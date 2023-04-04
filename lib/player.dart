import 'package:flutter_sound/flutter_sound.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';

class AudioPlayer {
  FlutterSoundPlayer? _player;
//  final _player = AssetsAudioPlayer();

  bool _isPlaying = false;

  AudioPlayer() {
    _player = FlutterSoundPlayer();
  }

  Future<void> startPlaying(String url) async {
    if (_isPlaying) {
      return;
    }
    _isPlaying = true;
    await _player!.openPlayer();
    await _player!.startPlayer(fromURI: url);
  }

  Future<void> stopPlaying() async {
    if (!_isPlaying) {
      return;
    }
    _isPlaying = false;
    await _player!.stopPlayer();
    await _player!.closePlayer();
  }
}