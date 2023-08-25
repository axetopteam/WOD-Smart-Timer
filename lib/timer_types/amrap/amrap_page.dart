import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:smart_timer/analytics/analytics_manager.dart';
import 'package:smart_timer/bottom_sheets/time_picker/time_picker.dart';
import 'package:smart_timer/core/context_extension.dart';
import 'package:smart_timer/core/localization/locale_keys.g.dart';
import 'package:smart_timer/routes/router.dart';
import 'package:smart_timer/services/app_properties.dart';
import 'package:smart_timer/timer/timer_state.dart';
import 'package:smart_timer/timer/timer_type.dart';
import 'package:smart_timer/widgets/interval_widget.dart';
import 'package:smart_timer/widgets/timer_setup_scaffold.dart';

import '../../widgets/new_item_transition.dart';
import 'amrap_state.dart';

@RoutePage()
class AmrapPage extends StatefulWidget {
  const AmrapPage({Key? key}) : super(key: key);

  @override
  State<AmrapPage> createState() => _AmrapPageState();
}

class _AmrapPageState extends State<AmrapPage> {
  late final AmrapState amrapState;
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
  SliverAnimatedListState get _animatedList => _listKey.currentState!;
  final _scroolController = ScrollController();

  @override
  void initState() {
    final json = AppProperties().getAmrapSettings();
    amrapState = json != null ? AmrapState.fromJson(json) : AmrapState();
    AnalyticsManager.eventSetupPageOpened.setProperty('timerType', TimerType.amrap.name).commit();

    super.initState();
  }

  @override
  void dispose() {
    final json = amrapState.toJson();
    AppProperties().setAmrapSettings(json);
    _scroolController.dispose();
    AnalyticsManager.eventSetupPageClosed.setProperty('timerType', TimerType.amrap.name).commit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TimerSetupScaffold(
      color: context.color.amrapColor,
      appBarTitle: LocaleKeys.amrap_title.tr(),
      subtitle: LocaleKeys.amrap_description.tr(),
      scrollController: _scroolController,
      onStartPressed: () {
        context.router.push(
          TimerRoute(
            state: TimerState(
              workout: amrapState.workout,
              timerType: TimerType.amrap,
            ),
          ),
        );
      },
      slivers: [
        SliverAnimatedList(
          key: _listKey,
          initialItemCount: amrapState.amrapsCount,
          itemBuilder: _itemBuilder,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(30, 26, 30, 0),
          sliver: SliverToBoxAdapter(
              child: ElevatedButton(
            onPressed: _addNewAmrap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline, size: 20),
                const SizedBox(width: 4),
                Text(LocaleKeys.amrap_add_button_title.tr())
              ],
            ),
          )),
        ),
      ],
    );
  }

  void _addNewAmrap() {
    amrapState.addAmrap();
    _animatedList.insertItem(amrapState.amrapsCount - 1, duration: const Duration(milliseconds: 200));
    Future.delayed(
        const Duration(milliseconds: 200),
        () => _scroolController.animateTo(
              _scroolController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ));

    AnalyticsManager.eventSetupPageNewSetAdded
        .setProperty('timerType', TimerType.amrap.name)
        .setProperty('setsCount', amrapState.amrapsCount)
        .commit();
  }

  Widget _itemBuilder(BuildContext context, int index, Animation<double> animation) {
    return Observer(builder: (ctx) {
      final amrap = amrapState.amraps[index];
      final isLast = index == amrapState.amrapsCount - 1;
      return NewItemTransition(
        animation: animation,
        child: _buildAmrap(
          amrap: amrap,
          isLast: isLast,
          index: index,
        ),
      );
    });
  }

  Widget _buildAmrap({
    required Amrap amrap,
    required bool isLast,
    required index,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${LocaleKeys.amrap_title.tr()} ${index + 1}',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntervalWidget(
                      title: LocaleKeys.work_time.tr(),
                      duration: amrap.workTime,
                      onTap: () async {
                        final selectedTime = await TimePicker.showTimePicker(
                          context,
                          initialDuration: amrap.workTime,
                        );
                        if (selectedTime != null) {
                          amrapState.setWorkTime(index, selectedTime);
                        }
                      }),
                  if (!isLast) const SizedBox(width: 10),
                  if (!isLast)
                    IntervalWidget(
                      title: LocaleKeys.rest_time.tr(),
                      duration: amrap.restTime,
                      canBeUnlimited: false,
                      onTap: () async {
                        final selectedTime = await TimePicker.showTimePicker(
                          context,
                          initialDuration: amrap.restTime,
                        );
                        if (selectedTime != null) {
                          amrapState.setRestTime(index, selectedTime);
                        }
                      },
                    ),
                ],
              ),
              if (amrapState.amrapsCount > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      TextButtonTheme(
                        data: context.buttonThemes.deleteButtonTheme,
                        child: TextButton(
                          onPressed: () {
                            _animatedList.removeItem(
                              index,
                              (context, animation) => NewItemTransition(
                                animation: animation,
                                child: _buildAmrap(
                                  amrap: amrap,
                                  isLast: isLast,
                                  index: index,
                                ),
                              ),
                            );
                            amrapState.deleteAmrap(index);
                            AnalyticsManager.eventSetupPageSetRemoved
                                .setProperty('timerType', TimerType.amrap.name)
                                .setProperty('setsCount', amrapState.amrapsCount)
                                .commit();
                          },
                          child: Row(
                            children: [
                              Text(
                                LocaleKeys.amrap_delete_button_title.tr(args: ['${index + 1}']),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const Divider(thickness: 5, height: 5),
      ],
    );
  }
}
