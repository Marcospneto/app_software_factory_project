import 'package:flutter/cupertino.dart';
import 'package:meu_tempo/config/application_constants.dart';
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

  Future<List<Task>> searchTasksByTitle(String searchText, String idUser) async {
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

  Future<bool> hasShieldTaskAtDateTime({
    required String userId,
    required String date,
    required String startTime,
    required endTime,
  }) async {
    final allTasks = await fetchTaskUser(userId);
    for (var task in allTasks) {
      if (task.shieldedTask == true &&
          task.date == date &&
          task.userId == userId) {
        final taskStart = _parseTime(task.startTime);
        final taskEnd = _parseTime(task.endTime);
        final inputStart = _parseTime(startTime);
        final inputEndTime = _parseTime(endTime);

        final isOverlap =
            inputStart.isBefore(taskEnd) && inputEndTime.isAfter(taskStart);

        if (isOverlap) return true;
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

    final whereCondition = "META().id IN ${tasksIds.map((id) => "'$id'").toList()}";

    final result = await couchbaseService.fetchWithCustomWhere(
      collectionName: collectionName,
      whereCondition: whereCondition,
    );

    return result.map(Task.fromMap).toList();
  }
}
