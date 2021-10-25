// import 'package:flutter/material.dart';
// import 'package:smart_timer/application/application_theme.dart';
// // import 'package:smart_timer/models/workout.dart';
// import 'package:smart_timer/utils/string_utils.dart';

// class WorkoutDesc extends StatelessWidget {
//   const WorkoutDesc(this.workout, {Key? key}) : super(key: key);
//   final Workout workout;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: workout.sets.asMap().keys.map((setIndex) {
//                 final set = workout.sets[setIndex];
//                 return Container(
//                   decoration: BoxDecoration(border: Border.all()),
//                   margin: const EdgeInsets.only(bottom: 8),
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Set $setIndex:',
//                         style: AppFonts.header2,
//                       ),
//                       ...set.rounds.asMap().keys.map((roundIndex) {
//                         final round = set.rounds[roundIndex];
//                         return Column(
//                           children: [
//                             Text(
//                               'round $roundIndex:',
//                               style: AppFonts.header2,
//                             ),
//                             ...round.intervals.map(
//                               (interval) => Text(
//                                 'Interval: ${durationToString2(interval.duration!)}',
//                                 style: AppFonts.header2,
//                               ),
//                             ),
//                             const Divider(
//                               color: AppColors.gray50,
//                             ),
//                           ],
//                         );
//                       }),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
