import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:smart_timer/sdk/models/protos/afap/afap_extension.dart';
import 'package:smart_timer/sdk/models/protos/afap_settings/afap_settings.pb.dart';
import 'package:smart_timer/sdk/models/workout_interval_type.dart';
import 'package:smart_timer/sdk/sdk_service.dart';

import '../timer_settings_interface.dart';

export 'package:smart_timer/sdk/models/protos/afap/afap_extension.dart';

part 'afap_state.g.dart';

class AfapState = AfapStateBase with _$AfapState implements TimerSettingsInterface;

abstract class AfapStateBase with Store {
  AfapStateBase({List<Afap>? afaps}) : afaps = ObservableList.of(afaps ?? [AfapX.defaultValue]);

  final type = TimerType.afap;

  ObservableList<Afap> afaps;

  @computed
  int get afapsCount => afaps.length;

  @action
  void setTimeCap(int afapIndex, Duration duration) {
    if (afapIndex < 0 || afapIndex >= afapsCount) return;

    afaps[afapIndex] = afaps[afapIndex].copyWithNewValue(timeCap: duration);
  }

  @action
  void setRestTime(int afapIndex, Duration duration) {
    if (afapIndex < 0 || afapIndex >= afapsCount) return;

    afaps[afapIndex] = afaps[afapIndex].copyWithNewValue(restTime: duration);

    if (afapIndex == afapsCount - 2) {
      afaps[afapIndex + 1] = afaps[afapIndex + 1].copyWithNewValue(restTime: duration);
    }
  }

  @action
  void setNoTimeCap(int afapIndex, bool noTimeCap) {
    if (afapIndex < 0 || afapIndex >= afapsCount) return;

    afaps[afapIndex] = afaps[afapIndex].copyWithNewValue(noTimeCap: noTimeCap);
  }

  @action
  void addAfap() {
    final lastAfapCopy = afaps.last.copyWithNewValue();
    afaps.add(lastAfapCopy);
  }

  @action
  void deleteAfap(int afapIndex) {
    afaps.removeAt(afapIndex);
  }

  Future<void> saveToFavorites({required String name, required String description}) async {
    return GetIt.I<SdkService>().addToFavorite(
      settings: settings,
      name: name,
      description: description,
    );
  }

  @computed
  Workout get workout {
    final List<Interval> intervals = [];

    for (int i = 0; i < afapsCount; i++) {
      final afap = afaps[i];
      final isLast = afapsCount > 1 && i == afapsCount - 1;
      final workInterval = afap.noTimeCap
          ? InfiniteInterval(type: IntervalType.work, isLast: isLast)
          : TimeCapInterval(
              timeCap: afap.timeCap,
              type: IntervalType.work,
              isLast: isLast,
            );
      final restInterval = FiniteInterval(duration: afap.restTime, type: IntervalType.rest);
      intervals.addAll([
        workInterval,
        if (i != afapsCount - 1) restInterval,
      ]);
    }
    return Workout(intervals: intervals, description: _despriptionSolver);
  }

  @computed
  WorkoutSettings get settings => WorkoutSettings(afap: AfapSettings(afaps: afaps));

  String _despriptionSolver(int index) {
    final afapIndex = index ~/ 2;
    return 'AFAP ${afapIndex + 1}/$afapsCount';
  }
}
