import 'package:meu_tempo/helpers/date_helper.dart';

class TaskQueryBuilder {
  final String userId;
  String? priority;
  String? timeCenter;
  String? dateFilter;
  DateTime? customDate;
  DateTime? startDate;
  DateTime? endDate;

  TaskQueryBuilder({required this.userId});

  TaskQueryBuilder withPriority(String? priority) {
    this.priority = priority;
    return this;
  }

  TaskQueryBuilder withTimeCenter(String? timeCenter) {
    this.timeCenter = timeCenter;
    return this;
  }

  TaskQueryBuilder withDateFilter(String? dateFilter) {
    this.dateFilter = dateFilter;
    return this;
  }

  TaskQueryBuilder withCustomDate(DateTime? date) {
    this.customDate = date;
    return this;
  }

  TaskQueryBuilder withPersonalized(DateTime? startDate, DateTime? endDate) {
    this.startDate = startDate;
    this.endDate = endDate;
    return this;
  }

  String build() {
    final conditions = <String>['userId = "$userId"'];

    if (priority != null && priority!.isNotEmpty) {
      conditions.add('priority = "${priority!}"');
    }

    if (timeCenter != null &&
        timeCenter!.isNotEmpty &&
        !["Este mês", "Esta semana", "Hoje", "Ontem", "Personalizado"].contains(timeCenter)) {
      conditions.add('timeCenters.name = "$timeCenter"');
    }

    _addDateConditions(conditions);

    return conditions.join(' AND ');
  }

  void _addDateConditions(List<String> conditions) {
    if (dateFilter == null || dateFilter!.isEmpty) return;

    final filter = dateFilter!.toLowerCase();
    final now = DateHelper.today;

    if (filter == 'esta semana') {
      final firstDate = DateHelper.getFirstDayOfWeek(now);
      final lastDate = firstDate.add(const Duration(days: 6));
      _addDateRangeCondition(conditions, firstDate, lastDate);
    } else if (filter == 'este mês') {
      final firstDate = DateHelper.getFirstDayOfMonth(now);
      final lastDate = DateHelper.getLastDayOfMonth(now);
      _addDateRangeCondition(conditions, firstDate, lastDate);
    } else if (filter == 'hoje') {
      conditions.add('date = "${DateHelper.formatDateSave(now)}"');
    } else if (filter == 'ontem') {
      final yesterday = now.subtract(const Duration(days: 1));
      conditions.add('date = "${DateHelper.formatDate(yesterday)}"');
    } else if (customDate != null) {
      conditions.add('date = "${DateHelper.formatDate(customDate!)}"');
    } else if (filter == 'personalizado' && startDate != null && endDate != null) {
      _addDateRangeCondition(conditions, startDate!, endDate!);
    }
  }

  void _addDateRangeCondition(List<String> conditions, DateTime start, DateTime end) {
    conditions.add('date >= "${DateHelper.formatDateSave(start)}"');
    conditions.add('date <= "${DateHelper.formatDateSave(end)}"');
  }
}