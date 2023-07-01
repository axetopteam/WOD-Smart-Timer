import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smart_timer/bottom_sheets/time_picker/timer_picker_state.dart';
import 'package:smart_timer/core/context_extension.dart';

final minutesList = List.generate(60, (index) => index);
final secondsList = List.generate(12, (index) => 5 * index);

class TimePicker extends StatefulWidget {
  static Future<Duration?> showTimePicker(
    BuildContext context, {
    Duration? initialDuration,
  }) {
    return showCupertinoModalBottomSheet<Duration?>(
      context: context,
      topRadius: const Radius.circular(20),
      builder: (ctx) => TimePicker(
        initialDuration: initialDuration ?? Duration.zero,
      ),
    );
  }

  const TimePicker({
    Key? key,
    required this.initialDuration,
  }) : super(key: key);

  final Duration initialDuration;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late final FixedExtentScrollController _minutesController;
  late final FixedExtentScrollController _secondsController;

  late final TimerPickerState state;

  @override
  void initState() {
    state = TimerPickerState(
      initialDuration: widget.initialDuration,
      minutesList: minutesList,
      secondsList: List.generate(12, (index) => 5 * index),
    );

    _minutesController = FixedExtentScrollController(initialItem: state.minutesIndex!);
    _secondsController = FixedExtentScrollController(initialItem: state.secondsIndex!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final safeOffset = mq.viewPadding;
    final bottomPadding = max(safeOffset.bottom, 34.0);

    return Container(
      height: mq.size.height * 0.8,
      decoration: BoxDecoration(
        color: context.color.bottomSheetBackgroundColor,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Work',
            style: context.textTheme.headline3,
          ),
          const Spacer(),
          Expanded(
            flex: 8,
            child: Row(
              children: [
                Expanded(
                  child: Observer(builder: (context) {
                    return CupertinoPicker(
                      useMagnifier: true,
                      magnification: 1,
                      diameterRatio: 20,
                      scrollController: _minutesController,
                      selectionOverlay: Center(
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.15),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Text(
                              'm',
                              style: context.textTheme.headline4,
                            ),
                          ),
                        ),
                      ),
                      onSelectedItemChanged: (value) {
                        state.minutesIndex = value;
                      },
                      itemExtent: 70,
                      children: state.minutesList
                          .map(
                            (minutes) => Center(
                              child: Text(
                                '$minutes',
                                textAlign: TextAlign.center,
                                style: context.textTheme.headline4,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }),
                ),
                Observer(builder: (context) {
                  return Expanded(
                    child: CupertinoPicker(
                      useMagnifier: true,
                      magnification: 1,
                      diameterRatio: 20,
                      scrollController: _secondsController,
                      selectionOverlay: Center(
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.15),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 44),
                            child: Text(
                              's',
                              style: context.textTheme.headline4,
                            ),
                          ),
                        ),
                      ),
                      onSelectedItemChanged: (value) {
                        state.secondsIndex = value;
                      },
                      itemExtent: 70,
                      children: state.secondsList
                          .map(
                            (seconds) => Center(
                              child: Text(
                                '$seconds',
                                textAlign: TextAlign.center,
                                style: context.textTheme.headline4,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButtonTheme(
              data: context.buttonThemes.popupButtonTheme,
              child: ElevatedButton(
                child: const Text(
                  'Confirm Time',
                ),
                onPressed: () {
                  final Duration? duration;
                  final minutes = state.minutes;
                  final seconds = state.seconds;
                  if (minutes != null && seconds != null) {
                    duration = Duration(minutes: minutes, seconds: seconds);
                  } else {
                    duration = null;
                  }

                  Navigator.of(context).pop(duration);
                },
              ),
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}
