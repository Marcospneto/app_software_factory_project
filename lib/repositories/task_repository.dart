import 'package:flutter/cupertino.dart';
import 'package:meu_tempo/config/application_constants.dart';
import 'package:meu_tempo/enums/repeat_frequency.dart';
import 'package:meu_tempo/helpers/date_helper.dart';
import 'package:meu_tempo/models/task.dart';
import 'package:meu_tempo/models/task_query_builder.dart';
import 'package:meu_tempo/services/couchbase_service.dart';
import 'package:meu_tempo/services/users_service.dart';

class TaskRepository {
  final CouchbaseService couchbaseService;
  final userService = UsersService();

  TaskRepository({required this.couchbaseService});

  final collectionName = ApplicationConstants.collectionTasks;

  Future<void> addItem(Task task) async {
    await couchbaseService.add(
      data: task.toMap(),
      collectionName: collectionName,
    );
  }

  Future<List<Task>> fetchAll() async {
    final result = await couchbaseService.fetch(collectionName: collectionName);
    return result.map(Task.fromMap).toList();
  }

  Future<List<Task>> fetchTaskUser(String userId) async {
    final result = await couchbaseService.fetch(
        collectionName: collectionName, filter: "userId = ${userId}");
    return result.map(Task.fromMap).toList();
  }

  Future<List<Task>> searchTasksByTitle(
      String searchText, String idUser) async {
    final formattedSearchText = "'%${searchText.toLowerCase()}%'";

    final whereCondition = '''
    userId = "$idUser"
    AND LOWER(title) LIKE $formattedSearchText
  ''';

    final result = await couchbaseService.fetchWithCustomWhere(
      collectionName: collectionName,
      whereCondition: whereCondition,
    );
    return result.map(Task.fromMap).toList();
  }

  Future<List<Task>> searchTasks({
    required String userId,
    String? priority,
    String? timeCenter,
    String? dateFilter,
    DateTime? customDate,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = TaskQueryBuilder(userId: userId)
        .withPriority(priority)
        .withTimeCenter(timeCenter)
        .withDateFilter(dateFilter)
        .withCustomDate(customDate)
        .withPersonalized(startDate, endDate)
        .build();

    final result = await couchbaseService.fetchWithCustomWhere(
      collectionName: collectionName,
      whereCondition: query,
    );

    return result.map(Task.fromMap).toList();
  }

  Future<bool> deleteItem(String id) async {
    await couchbaseService.delete(
      collectionName: collectionName,
      id: id,
    );
    return true;
  }

  Future<bool> deleteMultipleTasks(Set<String> taskIds) async {
    try {
      bool allSuccess = true;
      for (final id in taskIds) {
        final success = await couchbaseService.delete(
          collectionName: collectionName,
          id: id,
        );
        if (!success) {
          allSuccess = false;
        }
      }
      return allSuccess;
    } catch (e) {
      debugPrint('Erro ao excluir múltiplas tarefas: $e');
      return false;
    }
  }

  Future<bool> hasShieldTaskAtDateTime({
    required String userId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    final shieldedTasksOnDate = await fetchShieldedTasksByDate(userId, date);

    if (shieldedTasksOnDate.isEmpty) {
      return false;
    }

    final inputStart = _parseTime(startTime);
    final inputEndTime = _parseTime(endTime);

    for (var task in shieldedTasksOnDate) {
      final taskStart = _parseTime(task.startTime);
      final taskEnd = _parseTime(task.endTime);

      final bool isOverlap =
          inputStart.isBefore(taskEnd) && inputEndTime.isAfter(taskStart);

      if (isOverlap) {
        return true;
      }
    }

    return false;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  Future<bool> hasTasksWithTimeCenter(String timeCenter) async {
    try {
      final user = await userService.getCurrentUser();
      if (user == null) return false;

      final allTasks = await fetchTaskUser(user.id.toString());
      return allTasks.any((task) => task.timeCenters.name == timeCenter);
    } catch (e) {
      debugPrint('Erro ao verificar tarefas com centro de tempo: $e');
      return false;
    }
  }

  Future<bool> completeMultipleTasks(Set<String> taskIds) async {
    try {
      bool allSuccess = true;

      for (final id in taskIds) {
        final success = await couchbaseService.edit(
          collectionName: collectionName,
          id: id,
          data: {'completed': true},
        );

        if (!success) {
          allSuccess = false;
        }
      }

      return allSuccess;
    } catch (e) {
      debugPrint('Erro ao completar múltiplas tarefas: $e');
      return false;
    }
  }

  Future<bool> reactivateTask(Set<String> taskIds) async {
    try {
      bool allSuccess = true;

      for (final id in taskIds) {
        final success = await couchbaseService.edit(
          collectionName: collectionName,
          id: id,
          data: {'completed': false},
        );

        if (!success) {
          allSuccess = false;
        }
      }

      return allSuccess;
    } catch (e) {
      debugPrint('Erro ao completar múltiplas tarefas: $e');
      return false;
    }
  }

  Future<bool> moveTask(Set<String> taskIds, String date) async {
    try {
      bool allSuccess = true;
      final parsedDate = DateHelper.parseDate(date);

      for (final id in taskIds) {
        final success = await couchbaseService.edit(
          collectionName: collectionName,
          id: id,
          data: {'date': DateHelper.formatDateSave(parsedDate)},
        );

        if (!success) {
          allSuccess = false;
        }
      }

      return allSuccess;
    } catch (e) {
      debugPrint('Erro ao completar múltiplas tarefas: $e');
      return false;
    }
  }

  Future<List<Task>> getTasksByIds(Set<String> tasksIds) async {
    if (tasksIds.isEmpty) return [];

    final whereCondition =
        "META().id IN ${tasksIds.map((id) => "'$id'").toList()}";

    final result = await couchbaseService.fetchWithCustomWhere(
      collectionName: collectionName,
      whereCondition: whereCondition,
    );

    return result.map(Task.fromMap).toList();
  }

  Future<List<Task>> getTasksByDate(String date) async {
    final whereCondition = "date = '$date'";
    try {
      final result = await couchbaseService.fetchWithCustomWhere(
        collectionName: collectionName,
        whereCondition: whereCondition,
      );
      return result.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      print('Erro ao buscar tarefas por data: $e');
      return [];
    }
  }

  Future<List<Task>> getTasksByDateAndUserId(String date, String userId) async {
    final whereCondition = "date = '$date' AND userId = '$userId'";
    try {
      final result = await couchbaseService.fetchWithCustomWhere(
        collectionName: collectionName,
        whereCondition: whereCondition,
      );
      return result.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      print('Erro ao buscar tarefas por data: $e');
      return [];
    }
  }

  Future<List<Task>> fetchShieldedTasksByDate(
      String userId, String date) async {
    final selectDate = DateHelper.parseDate(date);
    final dateFormat = DateHelper.formatDateSave(selectDate);
    final filter =
        "userId = '$userId' AND date = '$dateFormat' AND shieldedTask = true";

    final result = await couchbaseService.fetch(
      collectionName: collectionName,
      filter: filter,
    );
    return result.map(Task.fromMap).toList();
  }

  Future<List<Task>> fetchTasksByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final allUserTasks = await fetchTaskUser(userId);
      final List<Task> expandedTasks = [];

      for (final task in allUserTasks) {
        if (task.repeatFrequency == RepeatFrequency.DOES_NOT_REPEAT.message) {
          final taskDate = DateHelper.parseDateSaved(task.date);
          if (_isDateInRange(taskDate, startDate, endDate)) {
            expandedTasks.add(task);
          }
        } else {
          final occurrences = _expandRecurringTask(task, startDate, endDate);
          expandedTasks.addAll(occurrences);
        }
      }

      return expandedTasks;
    } catch (e) {
      debugPrint('Erro ao buscar tarefas por intervalo: $e');
      return [];
    }
  }

  bool _isDateInRange(DateTime date, DateTime startDate, DateTime endDate) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(endDate.add(const Duration(days: 1)));
  }

  List<Task> _expandRecurringTask(
      Task task, DateTime startDate, DateTime endDate) {
    final List<Task> occurrences = [];
    final taskDate = DateHelper.parseDateSaved(task.date);

    if (task.repeatFrequency == RepeatFrequency.DOES_NOT_REPEAT.message ||
        taskDate.isAfter(endDate)) {
      return [task];
    }

    if (_isDateInRange(taskDate, startDate, endDate)) {
      occurrences.add(task);
    }

    switch (RepeatFrequency.values.firstWhere(
        (e) => e.message == task.repeatFrequency,
        orElse: () => RepeatFrequency.DOES_NOT_REPEAT)) {
      case RepeatFrequency.DAILY:
        _expandDaily(task, taskDate, startDate, endDate, occurrences);
        break;
      case RepeatFrequency.WEEKLY:
        _expandWeekly(task, taskDate, startDate, endDate, occurrences);
        break;
      case RepeatFrequency.MONTHLY:
        _expandMonthly(task, taskDate, startDate, endDate, occurrences);
        break;
      default:
        break;
    }

    return occurrences;
  }

  void _expandDaily(Task task, DateTime taskDate, DateTime startDate,
      DateTime endDate, List<Task> occurrences) {
    DateTime currentDate = taskDate.add(const Duration(days: 1));

    while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
      if (_isDateInRange(currentDate, startDate, endDate)) {
        final newTask = task.copyWith(
          id: '${task.id}_${DateHelper.formatDateSave(currentDate)}',
          date: DateHelper.formatDateSave(currentDate),
        );
        occurrences.add(newTask);
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    currentDate = taskDate.subtract(const Duration(days: 1));
    while (currentDate.isAfter(startDate.subtract(const Duration(days: 1)))) {
      if (_isDateInRange(currentDate, startDate, endDate)) {
        final newTask = task.copyWith(
          id: '${task.id}_${DateHelper.formatDateSave(currentDate)}',
          date: DateHelper.formatDateSave(currentDate),
        );
        occurrences.add(newTask);
      }
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
  }

  void _expandWeekly(Task task, DateTime taskDate, DateTime startDate,
      DateTime endDate, List<Task> occurrences) {
    bool isWeekday(DateTime date) {
      return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
    }

    DateTime currentDate = taskDate.add(const Duration(days: 1));
    while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
      if (isWeekday(currentDate) &&
          _isDateInRange(currentDate, startDate, endDate)) {
        final newTask = task.copyWith(
          id: '${task.id}_${DateHelper.formatDateSave(currentDate)}',
          date: DateHelper.formatDateSave(currentDate),
        );
        occurrences.add(newTask);
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    currentDate = taskDate.subtract(const Duration(days: 1));
    while (currentDate.isAfter(startDate.subtract(const Duration(days: 1)))) {
      if (isWeekday(currentDate) &&
          _isDateInRange(currentDate, startDate, endDate)) {
        final newTask = task.copyWith(
          id: '${task.id}_${DateHelper.formatDateSave(currentDate)}',
          date: DateHelper.formatDateSave(currentDate),
        );
        occurrences.add(newTask);
      }
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    if (!occurrences.any((t) => t.date == task.date) && isWeekday(taskDate)) {
      if (_isDateInRange(taskDate, startDate, endDate)) {
        occurrences.add(task);
      }
    }
  }

  void _expandMonthly(Task task, DateTime taskDate, DateTime startDate,
      DateTime endDate, List<Task> occurrences) {
    DateTime currentDate =
        DateTime(taskDate.year, taskDate.month + 1, taskDate.day);

    while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
      final lastDayOfMonth =
          DateTime(currentDate.year, currentDate.month + 1, 0).day;
      final day =
          taskDate.day <= lastDayOfMonth ? taskDate.day : lastDayOfMonth;

      final adjustedDate = DateTime(currentDate.year, currentDate.month, day);

      if (_isDateInRange(adjustedDate, startDate, endDate)) {
        final newTask = task.copyWith(
          id: '${task.id}_${DateHelper.formatDateSave(adjustedDate)}',
          date: DateHelper.formatDateSave(adjustedDate),
        );
        occurrences.add(newTask);
      }

      currentDate =
          DateTime(currentDate.year, currentDate.month + 1, taskDate.day);
    }

    currentDate = DateTime(taskDate.year, taskDate.month - 1, taskDate.day);
    while (currentDate.isAfter(startDate.subtract(const Duration(days: 1)))) {
      final lastDayOfMonth =
          DateTime(currentDate.year, currentDate.month + 1, 0).day;
      final day =
          taskDate.day <= lastDayOfMonth ? taskDate.day : lastDayOfMonth;

      final adjustedDate = DateTime(currentDate.year, currentDate.month, day);

      if (_isDateInRange(adjustedDate, startDate, endDate)) {
        final newTask = task.copyWith(
          id: '${task.id}_${DateHelper.formatDateSave(adjustedDate)}',
          date: DateHelper.formatDateSave(adjustedDate),
        );
        occurrences.add(newTask);
      }

      currentDate =
          DateTime(currentDate.year, currentDate.month - 1, taskDate.day);
    }
  }
}
