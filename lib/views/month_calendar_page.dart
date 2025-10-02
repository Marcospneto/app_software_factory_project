import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/locator/locator.dart';
import 'package:meu_tempo/store/task_store.dart';
import 'package:meu_tempo/views/day_calendar_page.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthCalendarPage extends StatefulWidget {
  final DateTime focuseDay;
  final Function(DateTime) onDaySelected;

  const MonthCalendarPage(
      {super.key, required this.focuseDay, required this.onDaySelected});

  @override
  State<MonthCalendarPage> createState() => _MonthCalendarPageState();
}

class _MonthCalendarPageState extends State<MonthCalendarPage> {
  final TaskStore _taskStore = getIt<TaskStore>();
  late DateTime _focusedMonth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _focusedMonth = widget.focuseDay;
    _loadTasksForMonth(_focusedMonth);
  }

  Future<void> _loadTasksForMonth(DateTime month) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _taskStore.fetchTasksByMonth(month);
      _focusedMonth = month;
    } catch (e) {
      print('Erro ao carregar tarefas do mês: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant MonthCalendarPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focuseDay.month != oldWidget.focuseDay.month ||
        widget.focuseDay.year != oldWidget.focuseDay.year) {
      _loadTasksForMonth(widget.focuseDay);
    }
  }

  Widget _buildDayCell({
    required BuildContext context,
    required DateTime day,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    final grayBorder = BorderSide(color: Colors.grey.shade300, width: 1.0);
    final isSaturday = day.weekday == DateTime.saturday;
    final dateString =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    final status = _taskStore.taskStatusPerDay[dateString];
    final bool existsTask = status?.tasksExist ?? false;
    final bool isComplete = status?.allTasksCompleted ?? false;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: grayBorder,
          right: isSaturday ? BorderSide.none : grayBorder,
        ),
      ),
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0, top: 6.0, right: 4.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${day.day}',
                  style: textStyle ?? const TextStyle(color: Colors.black87),
                ),
                if (!_taskStore.isLoading)
                  Observer(builder: (_) {
                    final status = _taskStore.taskStatusPerDay[dateString];
                    final bool existsTask = status?.tasksExist ?? false;
                    final bool isComplete = status?.allTasksCompleted ?? false;

                    return _StatusCircle(
                      isComplete: isComplete,
                      existsTask: existsTask,
                    );
                  }),
              ],
            ),
            Observer(builder: (_) {
              final tasksOfDay = _taskStore.monthlyTasks
                  .where((task) => task.date == dateString)
                  .take(3)
                  .toList();
              return Column(
                children: tasksOfDay.map((task) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: _CardTask(
                      title: task.title,
                      color: task.timeCenters.color,
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  final List<String> _daysOfWeek = [
    'DOM',
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SÁB'
  ];

  @override
  Widget build(BuildContext context) {
    final grayBorder = BorderSide(color: Colors.grey.shade300, width: 1.0);

    return Stack(
      children: [
        Observer(
          builder: (_) {
            return Column(
              children: [
                Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    border: Border(top: grayBorder, bottom: grayBorder),
                  ),
                  child: Row(
                    children: _daysOfWeek.map((day) {
                      final isLastDay = day == _daysOfWeek.last;
                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                                right:
                                    isLastDay ? BorderSide.none : grayBorder),
                          ),
                          alignment: Alignment.center,
                          child: Text(day,
                              style: const TextStyle(color: Colors.black87)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Calendário
                Expanded(
                  child: TableCalendar(
                    shouldFillViewport: true,
                    locale: 'pt_BR',
                    focusedDay: widget.focuseDay,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    calendarFormat: CalendarFormat.month,
                    headerVisible: false,
                    daysOfWeekVisible: false,
                    availableGestures: AvailableGestures.none,
                    onDaySelected: (selectedDay, focusedDay) {
                      widget.onDaySelected(selectedDay);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DayCalendarPage(
                            selectedDay: selectedDay,
                          ),
                        ),
                      );
                    },
                    selectedDayPredicate: (day) {
                      return isSameDay(widget.focuseDay, day);
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return _buildDayCell(context: context, day: day);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return _buildDayCell(
                          context: context,
                          day: day,
                          backgroundColor: Colors.blue.shade100,
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return _buildDayCell(context: context, day: day);
                      },
                      outsideBuilder: (context, day, focusedDay) {
                        return _buildDayCell(
                          context: context,
                          day: day,
                          textStyle: TextStyle(color: Colors.grey.shade400),
                        );
                      },
                    ),
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(),
                      todayDecoration: BoxDecoration(),
                      defaultDecoration: BoxDecoration(),
                      weekendDecoration: BoxDecoration(),
                      outsideDecoration: BoxDecoration(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

class _StatusCircle extends StatelessWidget {
  final bool isComplete;
  final bool existsTask;

  const _StatusCircle(
      {super.key, required this.isComplete, required this.existsTask});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: !existsTask
              ? Colors.grey.shade300
              : isComplete
                  ? Colors.green
                  : Colors.red),
    );
  }
}

class _CardTask extends StatelessWidget {
  final String title;
  final Color color;

  const _CardTask({
    required this.title,
    required this.color,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
