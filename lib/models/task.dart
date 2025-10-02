import 'package:meu_tempo/enums/notification.dart';
import 'package:meu_tempo/enums/repeat_frequency.dart';
import 'package:meu_tempo/enums/task_priority.dart';
import 'package:meu_tempo/helpers/date_helper.dart';
import 'package:meu_tempo/models/time_center.dart';

class Task {
  final String? id;
  final String title;
  final TimeCenter timeCenters;
  final TaskPriority? priority;
  final String date;
  final bool? shieldedTask;
  final String startTime;
  final String endTime;
  final RepeatFrequency? repeatFrequency;
  final List<int>? repeatDays;
  final NotificationEnum? notification;
  final String? observation;
  final String userId;
  final bool completed;

  Task({
    this.id,
    required this.title,
    required this.timeCenters,
    this.priority,
    required this.date,
    this.shieldedTask,
    required this.startTime,
    required this.endTime,
    this.repeatFrequency,
    this.repeatDays,
    this.notification,
    this.observation,
    required this.userId,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    final dateFormat = DateHelper.parseDate(date);
    final dateSave = DateHelper.formatDateSave(dateFormat);

    return {
      'id': id,
      'title': title,
      'timeCenters': timeCenters.toMap(),
      'priority': priority?.label,
      'date': dateSave,
      'shieldedTask': shieldedTask,
      'startTime': startTime,
      'endTime': endTime,
      'repeatFrequency': repeatFrequency?.name,
      'repeatDays': repeatDays,
      'notification': notification?.name,
      'observation': observation,
      'userId': userId,
      'completed': completed,
    };
  }

  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      title: data['title'],
      timeCenters: TimeCenter.fromMap(data['timeCenters']),
      date: data['date'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      priority: TaskPriority.fromString(data['priority']),
      repeatFrequency: RepeatFrequency.fromString(data['repeatFrequency']),
      repeatDays: data['repeatDays'] != null
          ? List<int>.from(data['repeatDays'])
          : null,
      notification: NotificationEnum.fromString(data['notification']),
      observation: data['observation'] ?? '',
      shieldedTask: data['shieldedTask'] ?? false,
      userId: data['userId'] ?? '',
      completed: data['completed'] ?? false,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    TimeCenter? timeCenters,
    TaskPriority? priority,
    String? date,
    bool? shieldedTask,
    String? startTime,
    String? endTime,
    RepeatFrequency? repeatFrequency,
    List<int>? repeatDays,
    NotificationEnum? notification,
    String? observation,
    String? userId,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      timeCenters: timeCenters ?? this.timeCenters,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      shieldedTask: shieldedTask ?? this.shieldedTask,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
      repeatDays: repeatDays ?? this.repeatDays,
      notification: notification ?? this.notification,
      observation: observation ?? this.observation,
      userId: userId ?? this.userId,
      completed: completed ?? this.completed,
    );
  }
}
