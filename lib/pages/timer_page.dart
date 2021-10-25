import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:smart_timer/application/application_theme.dart';
import 'package:smart_timer/models/round.dart';
import 'package:smart_timer/stores/timer_status.dart';
import 'package:smart_timer/utils/string_utils.dart';
import 'package:wakelock/wakelock.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late final Round workout;

  // AudioPlayer audioPlayer = AudioPlayer();
  final player = AudioPlayer();
  late Duration? duration;
  late final ReactionDisposer reactionDispose;

  @override
  void initState() {
    Wakelock.enable();

    workout = Provider.of<Round>(context, listen: false);
    reactionDispose = reaction<Duration>(
      (reac) {
        return workout.currentTime;
      },
      (rest) async {
        // if ((workout.currentInterval.isCountdown && rest.inSeconds == 3) ||
        //     (!workout.currentInterval.isCountdown && workout.currentInterval.duration != null && rest == workout.currentInterval.duration! - const Duration(seconds: 3))) {
        //   await player.play();
        //   await player.pause();
        //   player.seek(const Duration(milliseconds: 0));
        // }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();

    player.stop();
    reactionDispose();
    super.dispose();
  }

  Future<void> initAudio() async {
    duration = await player.setAsset('assets/sounds/countdown2.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initAudio(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Timer'),
            foregroundColor: AppColors.white,
          ),
          body: SizedBox(
            width: double.infinity,
            child: Observer(
              builder: (ctx) => workout.status == TimerStatus.done
                  ? const Center(
                      child: Text('Finish', style: AppFonts.header),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Observer(
                        //   builder: (_) => Text(
                        //     'Set: ${workout.setIndex + 1}/${workout.setsCount}',
                        //     style: AppFonts.header2,
                        //   ),
                        // ),
                        // Observer(
                        //   builder: (_) => Text(
                        //     'Round: ${workout.roundIndex + 1}/${workout.roundsCount}',
                        //     style: AppFonts.header2,
                        //   ),
                        // ),
                        Observer(
                          builder: (_) => Text(
                            'Interval: ${workout.intervalIndex + 1}/${workout.intervalsCount}',
                            style: AppFonts.header2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Observer(
                        //   builder: (_) => Text(
                        //     workout.currentType.desc,
                        //     style: AppFonts.header2,
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                        Observer(
                          builder: (_) => Text(
                            durationToString2(workout.currentTime),
                            style: const TextStyle(
                              fontSize: 52,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Observer(builder: (ctx) {
                          Icon icon;
                          void Function() onPressed;
                          switch (workout.status) {
                            case TimerStatus.stop:
                              icon = const Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: Colors.blueAccent,
                              );
                              onPressed = workout.start;
                              break;
                            case TimerStatus.run:
                              icon = const Icon(
                                Icons.pause,
                                size: 40,
                                color: Colors.blueAccent,
                              );
                              onPressed = workout.pause;
                              break;
                            case TimerStatus.pause:
                              icon = const Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: Colors.blueAccent,
                              );
                              onPressed = workout.start;
                              break;
                            case TimerStatus.done:
                              icon = const Icon(
                                Icons.restart_alt,
                                size: 40,
                                color: Colors.blueAccent,
                              );
                              onPressed = workout.start;
                              break;
                          }
                          return IconButton(
                            onPressed: onPressed,
                            icon: icon,
                          );
                        }),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
