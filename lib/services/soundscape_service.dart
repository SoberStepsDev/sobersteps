import 'package:audioplayers/audioplayers.dart';

class SoundscapeService {
  static final SoundscapeService _instance = SoundscapeService._();
  factory SoundscapeService() => _instance;
  SoundscapeService._();

  final AudioPlayer _player = AudioPlayer();
  String? _currentSoundscape;

  String? get currentSoundscape => _currentSoundscape;
  bool get isPlaying => _player.state == PlayerState.playing;

  static const Map<String, String> soundscapes = {
    'ocean': 'Ocean Breathing',
    'forest': 'Rainy Forest',
    'campfire': 'Campfire',
    'night_rain': 'Night Rain',
    'mountain': 'Mountain Wind',
    'river': 'River Flow',
    'white_noise': 'White Noise',
    'deep_hum': 'Deep Hum',
  };

  Future<void> play(String key) async {
    _currentSoundscape = key;
    try {
      await _player.play(AssetSource('audio/surf_$key.mp3'));
      await _player.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      // Asset may not exist yet
    }
  }

  Future<void> stop() async {
    _currentSoundscape = null;
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
