import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/locator/locator.dart';
import 'package:meu_tempo/models/task.dart';
import 'package:meu_tempo/models/users.dart';
import 'package:meu_tempo/repositories/task_repository.dart';
import 'package:meu_tempo/repositories/time_center_repository.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:meu_tempo/widgets/custom_appbar.dart';
import 'package:meu_tempo/widgets/custom_floating_button.dart'; // Import this
import 'package:meu_tempo/widgets/custom_menu.dart';
import 'package:meu_tempo/widgets/timeline_indicator.dart';

class DayCalendarPage extends StatefulWidget {
  final DateTime? selectedDay;

  const DayCalendarPage({
    Key? key,
    this.selectedDay,
  }) : super(key: key);

  @override
  _DayCalendarPageState createState() => _DayCalendarPageState();
}

class _DayCalendarPageState extends State<DayCalendarPage> {
  final TaskRepository taskRepository = getIt<TaskRepository>();
  final UsersService usersService = getIt<UsersService>();
  final TimeCenterRepository timeCenterRepository =
      getIt<TimeCenterRepository>();
  Users? _currentUser;

  Map<int, List<Task>> _tasksByHour = {};
  bool _isLoading = true;

  Set<String> _selectedTasksIds = {};
  bool _hasSelectedCards = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _clearSelection() {
    setState(() {
      _selectedTasksIds.clear();
      _hasSelectedCards = false;
    });
  }

  void _updateSelectionState() {
    setState(() {
      _hasSelectedCards = _selectedTasksIds.isNotEmpty;
    });
  }

  void _onCardSelectionChanged(String taskId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedTasksIds.add(taskId);
      } else {
        _selectedTasksIds.remove(taskId);
      }
      _updateSelectionState();
    });
  }

  void _onTasksModified() {
    _clearSelection();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _tasksByHour.clear();
      });
    }

    await _loadUser();

    final dateToFetch = widget.selectedDay ?? DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(dateToFetch);

    final tasks = await fetchTasksByDate(formattedDate);
    final groupedTasks = _groupTasksByHour(tasks);

    if (mounted) {
      setState(() {
        _tasksByHour = groupedTasks;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUser() async {
    final user = await usersService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Map<int, List<Task>> _groupTasksByHour(List<Task> tasks) {
    final Map<int, List<Task>> grouped = {};
    for (final task in tasks) {
      try {
        final hour = int.parse(task.startTime.split(':')[0]);
        if (grouped[hour] == null) {
          grouped[hour] = [];
        }
        grouped[hour]!.add(task);
      } catch (e) {
        debugPrint('Erro ao parsear a hora da tarefa: ${task.startTime}');
      }
    }
    grouped.forEach((hour, taskList) {
      taskList.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
    return grouped;
  }

  Future<List<Task>> fetchTasksByDate(String date) async {
    if (_currentUser?.id == null) {
      print('Erro: Usuário não autenticado ou ID do usuário é nulo.');
      return [];
    }

    try {
      final tasks =
          await taskRepository.getTasksByDateAndUserId(date, _currentUser!.id!);
      return tasks;
    } catch (e) {
      print('Erro ao buscar tarefas: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    String dayOfWeek = '';
    String monthName = '';
    int? dayNumber;

    if (widget.selectedDay != null) {
      dayOfWeek = DateFormat('EEEE', 'pt_BR').format(widget.selectedDay!);
      monthName = DateFormat('MMMM', 'pt_BR').format(widget.selectedDay!);
      dayNumber = widget.selectedDay!.day;
    }

    return Scaffold(
      appBar: CustomAppBar(
        height: 90,
        customDateWidget: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Container(
            width: 165,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${monthName.toUpperCase()}',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: MainColor.secondaryColor),
                  ),
                  Text(
                    '${dayNumber}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MainColor.secondaryColor),
                  ),
                  Text(
                    '${dayOfWeek.toUpperCase()}',
                    style: TextStyle(
                        fontSize: 10,
                        color: MainColor.secondaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: 24,
              itemBuilder: (context, index) {
                final hour = index;
                final hourLabel = hour.toString().padLeft(2, '0') + ':00';
                final tasksForHour = _tasksByHour[hour] ?? [];
                return TimelineIndicator(
                  hour: hourLabel,
                  tasks: tasksForHour,
                  selectedTaskIds: _selectedTasksIds,
                  onSelectionChanged: _onCardSelectionChanged,
                );
              },
            ),
      floatingActionButton: _hasSelectedCards
          ? CustomFloatingButton(
              selectedTaskIds: _selectedTasksIds,
              onTasksModified: _onTasksModified,
            )
          : null,
      bottomNavigationBar: CustomMenu(),
    );
  }
}
