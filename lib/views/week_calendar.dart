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
import 'package:meu_tempo/widgets/custom_floating_button.dart';
import 'package:meu_tempo/widgets/custom_menu.dart';
import 'package:meu_tempo/widgets/timeline_indicator.dart';

class WeekCalendar extends StatefulWidget {
  final List<DateTime>? selectedDay;
  const WeekCalendar({Key? key, this.selectedDay}) : super(key: key);

  @override
  _WeekCalendarState createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  final TaskRepository taskRepository = getIt<TaskRepository>();
  final UsersService usersService = getIt<UsersService>();
  final TimeCenterRepository timeCenterRepository =
      getIt<TimeCenterRepository>();

  Users? _currentUser;
  Map<int, List<Task>> _tasksByHour = {};
  bool _isLoading = true;
  Set<String> _selectedTasksIds = {};
  bool _hasSelectedCards = false;
  List<DateTime> _currentWeekDays = [];
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    final initialDate = widget.selectedDay?.first ?? DateTime.now();
    setState(() {
      _selectedDate = initialDate;
      _currentWeekDays = _getWeekDays(initialDate);
      _isLoading = true;
    });

    final user = await usersService.getCurrentUser();
    if (!mounted) return;

    if (user == null || user.id == null) {
      print('Erro: Usuário não autenticado.');
      setState(() {
        _isLoading = false;
        _currentUser = null;
        _tasksByHour.clear();
      });
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(initialDate);
    final tasks =
        await taskRepository.getTasksByDateAndUserId(formattedDate, user.id!);
    if (!mounted) return;

    final groupedTasks = _groupTasksByHour(tasks);

    setState(() {
      _currentUser = user;
      _tasksByHour = groupedTasks;
      _isLoading = false;
    });
  }

  void _handleDateSelection(DateTime newDate) {
    if (newDate.day == _selectedDate.day &&
        newDate.month == _selectedDate.month) return;

    setState(() {
      _selectedDate = newDate;
    });
    _fetchTasksForSelectedDate();
  }

  Future<void> _fetchTasksForSelectedDate() async {
    setState(() {
      _isLoading = true;
      _tasksByHour.clear();
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final tasks = await fetchTasksByDate(formattedDate);
    final groupedTasks = _groupTasksByHour(tasks);

    if (mounted) {
      setState(() {
        _tasksByHour = groupedTasks;
        _isLoading = false;
      });
    }
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final sunday = date.subtract(Duration(days: date.weekday % 7));
    return List.generate(7, (index) => sunday.add(Duration(days: index)));
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
    _fetchTasksForSelectedDate();
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
    return Scaffold(
      appBar: _CustomAppBarWithDate(
        dateWidgetHeight: 65,
        customDateWidget: _buildWeekDaysBar(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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

  Widget _buildWeekDaysBar() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _currentWeekDays.length,
      itemBuilder: (context, index) {
        final day = _currentWeekDays[index];
        final isSelected = day.day == _selectedDate.day &&
            day.month == _selectedDate.month &&
            day.year == _selectedDate.year;

        return _CardDate(
          date: day,
          isSelected: isSelected,
          onTap: () => _handleDateSelection(day),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 8),
    );
  }
}

class _CardDate extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CardDate(
      {Key? key, required this.date, required this.isSelected, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMM', 'pt_BR').format(date).toUpperCase();
    final day = DateFormat('d', 'pt_BR').format(date);
    final dayOfWeek = DateFormat('E', 'pt_BR').format(date).toUpperCase();

    final cardColor = isSelected ? MainColor.primaryColor : Colors.white;
    final textColor = isSelected ? Colors.white : MainColor.secondaryColor;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 60,
        height: 65,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(month,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text(day,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text(dayOfWeek,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _CustomAppBarWithDate extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? titleColor;
  final FontWeight? fontWeight;
  final Widget? customDateWidget;
  final double? height;
  final double toolbarHeight;
  final double dateWidgetHeight;
  final bool showBackButton;

  const _CustomAppBarWithDate({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.titleColor,
    this.fontWeight,
    this.customDateWidget,
    this.height,
    this.toolbarHeight = kToolbarHeight,
    this.dateWidgetHeight = 60.0,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Size get preferredSize {
    // Mantemos o cálculo dinâmico da altura, que é mais robusto
    if (height != null) return Size.fromHeight(height!);
    final double extra = customDateWidget != null
        ? dateWidgetHeight + 8
        : 0.0; // Adicionei um pequeno padding
    return Size.fromHeight(toolbarHeight + extra);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundColor != null
            ? null
            : LinearGradient(
                colors: [MainColor.primaryColor, MainColor.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: showBackButton,
            leading: leading,
            actions: actions,
            title: Text(
              title ?? '',
              style: TextStyle(
                color: titleColor ?? Colors.white,
                fontWeight: fontWeight ?? FontWeight.bold,
              ),
            ),
          ),
          if (customDateWidget != null)
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              height: dateWidgetHeight,
              child: Center(child: customDateWidget!),
            ),
        ],
      ),
    );
  }
}
