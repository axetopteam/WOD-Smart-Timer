import 'package:audioplayers/audioplayers.dart';
// import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioPlayer audioPlayer = AudioPlayer();
  late final AudioCache player;

  Future<void> initialize() async {
    player = AudioCache(prefix: 'assets/sounds/', fixedPlayer: audioPlayer);
    await player.loadAll(['countdown2.mp3', 'last_round.mp3', 'half_time.mp3']);
  }

  Future<void> playCountdown() async {
    await player.play('countdown2.mp3');
  }

  Future<void> playLastRound() async {
    await player.play('last_round.mp3');
  }

  Future<void> playHalfTime() async {
    if (audioPlayer.state == PlayerState.PLAYING) return;
  }

  Future<void> stop() async {
    await audioPlayer.stop();
  }

  Future<void> pause() async {
    await audioPlayer.pause();
  }

  Future<void> resume() async {
    await audioPlayer.resume();
  }

  Future<void> dispose() async {
    await player.clearAll();
    await audioPlayer.dispose();
  }
}
