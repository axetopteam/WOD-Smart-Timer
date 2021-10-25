import 'package:mobx/mobx.dart';
import 'package:smart_timer/models/interval.dart';
import 'package:smart_timer/models/interval_type.dart';
import 'package:smart_timer/models/round.dart';
// import 'package:smart_timer/models/set.dart';
// import 'package:smart_timer/models/workout.dart';

part 'amrap.g.dart';

class Amrap = AmrapBase with _$Amrap;

abstract class AmrapBase with Store {
  @observable
  var workTime = Interval(
    duration: const Duration(minutes: 10),
    type: IntervalType.work,
  );

  // @computed
  // Workout get workout {
  //   final round = Round(ObservableList.of([workTime]));
  //   List<Round> rounds = [round];
  //   // return Workout.withCountdownInterval(rounds);
  //   return Workout(
  //     [
  //       WorkoutSet(ObservableList.of([round]))
  //     ],
  //   );
  // }

  @action
  void setWorkTime(Duration duration) {
    workTime = Interval(
      duration: duration,
      type: IntervalType.work,
    );
  }
}
