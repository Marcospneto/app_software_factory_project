
import 'package:meu_tempo/models/bar_chart_data.dart';
import 'package:meu_tempo/models/pie_chart_data.dart';
import 'package:meu_tempo/repositories/task_repository.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:meu_tempo/services/couchbase_service.dart';
import 'package:flutter/material.dart';
import 'package:meu_tempo/enums/period_type.dart';

class ReportService {
  final _userService = UsersService();
  final CouchbaseService couchbaseService;
  late final TaskRepository taskRepository;
  
  ReportService() : couchbaseService = CouchbaseService() {
    taskRepository = TaskRepository(couchbaseService: couchbaseService);
  }

  Future<List<CustomPieChartData>> fetchTasksPieChart({
    PeriodType? periodType,
    DateTime? start,
    DateTime? end,
  }) async {
    final user = await _userService.getCurrentUser();
   
    if (user == null) return [];
    
    final allTasks = await taskRepository.fetchTaskUser(user.id!);
    
    if (periodType == null) {
      final completedTasks = allTasks.where((task) => task.completed).toList();
      final Map<String, int> timeCenterCounts = {};

      for (var task in completedTasks) {
        final timeCenterName = task.timeCenters.name;
        timeCenterCounts[timeCenterName] = (timeCenterCounts[timeCenterName] ?? 0) + 1;
      }

      if (timeCenterCounts.isNotEmpty) {
        final int total = timeCenterCounts.values.fold(0, (sum, count) => sum + count);
        final pieData = timeCenterCounts.entries.map((entry) {
          final index = timeCenterCounts.keys.toList().indexOf(entry.key);
          final double percentage = (entry.value / total) * 100;
        
          return CustomPieChartData(
            title: entry.key, 
            value: percentage, 
            color: Colors.primaries[index % Colors.primaries.length],
          );
        }).toList();
        
        return pieData;
      }
    }

    final range = _getDateRangeFromPeriodType(periodType!, start: start, end: end);
    if (range == null) return [];

    final from = range.start;
    final to = range.end;

    
    final filteredTask = allTasks.where((task) {
      if (!task.completed) return false;

      final parts = task.date.split('-');
      if (parts.length != 3) return false;
      final taskDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      return taskDate.isAtSameMomentAs(from) ||
        taskDate.isAfter(from) && taskDate.isBefore(to);
    }).toList();

    final Map<String, int> timeCenterCounts = {};
    for (var task in filteredTask) {
      final name = task.timeCenters.name;
      timeCenterCounts[name] = (timeCenterCounts[name] ?? 0) + 1;
    }
    
    final total = timeCenterCounts.values.fold(0, (sum, count) => sum + count);
    
    final pieData = timeCenterCounts.entries.map((entry) {
      final index = timeCenterCounts.keys.toList().indexOf(entry.key);
      final double percentage = (entry.value / total) * 100;

      return CustomPieChartData(
        title: entry.key,
        value: percentage,
        color: Colors.primaries[index % Colors.primaries.length],
      );
    }).toList();
    
    return pieData;
  }

  Future<List<CustomBarChartData>> fetchTasksBarChart({
    PeriodType? periodType,
    DateTime? start,
    DateTime? end,
  }) async {
    final user = await _userService.getCurrentUser();
   
    if (user == null) return [];
    
    final allTasks = await taskRepository.fetchTaskUser(user.id!);

    final range = _getDateRangeFromPeriodType(periodType!, start: start, end: end);

    if (range == null) return [];

    final from = range.start;
    final to = range.end;

    final filteredTasks = allTasks.where((task) {
      final parts = task.date.split('-');
      
      if (parts.length != 3) return false;
      final taskDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return taskDate.isAtSameMomentAs(from) ||
        taskDate.isAfter(from) && taskDate.isBefore(to);
    }).toList();
    
    final Map<String, List<bool>> timeCenterStatusMap = {};

    for (var task in filteredTasks) {
      final center = task.timeCenters.name.trim();
      final isCompleted = task.completed;

      if (!timeCenterStatusMap.containsKey(center)) {
        timeCenterStatusMap[center] = [];
      }
      timeCenterStatusMap[center]!.add(isCompleted);
    }

    final List<CustomBarChartData> result = [];

    timeCenterStatusMap.forEach((categoria, statusList) {
      final total = statusList.length;
      final completed = statusList.where((s) => s).length;
      final double completedPercent = total > 0 ? completed / total : 0;
      final double notCompletedPercent = 1 - completedPercent;
      
      result.add(
        CustomBarChartData(
          categoria: categoria, 
          realizadoPercentual: completedPercent, 
          totalTarefas: total.toDouble(), 
          tarefasRealizadas: completed.toString(), 
          naoRealizadoPercentual: notCompletedPercent.toDouble(),
        ),
      );
    });
    return result;
  }

  DateTimeRange? _getDateRangeFromPeriodType(PeriodType periodType, {DateTime? start, DateTime? end}) {
    final now = DateTime.now();
    late DateTime from;
    late DateTime to;

    switch (periodType) {
      case PeriodType.dia:
        from = DateTime(now.year, now.month, now.day, 0, 0, 0);
        to = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case PeriodType.semana:
        from = now.subtract(Duration(days: 6));
        to = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case PeriodType.mes:
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case PeriodType.periodo:
        if (start == null || end == null) return null;
        from = DateTime(start.year, start.month, start.day, 0, 0, 0);
        to = DateTime(end.year, end.month, end.day, 23, 59, 59);
        break;
    }
    return DateTimeRange(start: from, end: to);
  }
}