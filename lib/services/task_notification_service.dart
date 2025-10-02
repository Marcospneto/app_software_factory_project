import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meu_tempo/enums/notification.dart';
import 'package:meu_tempo/models/task.dart';
import 'package:meu_tempo/models/custom_notification.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz;

class TaskNotificationService {
   final FlutterLocalNotificationsPlugin notificationsPlugin;

  TaskNotificationService()
      : notificationsPlugin = FlutterLocalNotificationsPlugin() {
    _initializeNotifications();
    tz.initializeTimeZones();
  }

    Future<void> _initializeNotifications() async {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
      final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
      await notificationsPlugin.initialize(initializationSettings);
    }

   Future<void> scheduleTaskNotification(Task task) async {

     if (task.notification == NotificationEnum.NO_NOTIFICATION) return;

     final notificationTime = _calculateNotificationTime(task);
     if (notificationTime == null) return;

     final customNotification = _createCustomNotification(task);

     await Workmanager().registerOneOffTask(
       'notification_${task.id}_${task.notification?.code}',
       'taskNotification',
       inputData: {
         'id': customNotification.id,
         'title': customNotification.title,
         'body': customNotification.body,
         'payload': customNotification.payload
       },
       initialDelay: notificationTime.difference(DateTime.now()).abs(),
       constraints: Constraints(networkType: NetworkType.notRequired),
       existingWorkPolicy: ExistingWorkPolicy.replace,
     );
   }

   CustomNotification _createCustomNotification(Task task) {
     return CustomNotification(
       id: task.notification?.code ?? 0,
       title: 'Lembrete: ${task.title}',
       body: '${task.notification?.message} para: ${task.observation}',
       payload: 'task|${task.id}',
     );
   }

   DateTime? _calculateNotificationTime(Task task) {
     try {
       if (task.notification == null || task.notification == NotificationEnum.NO_NOTIFICATION) {
         return null;
       }

       final taskDateTime = _parseTaskDateTime(task.date, task.startTime);
       final minutes = task.notification?.minutes ?? 0;

       return taskDateTime.subtract(Duration(minutes: minutes));
     } catch (e) {
       debugPrint('Algo inesperado aconteceu: $e');
       return null;
     }
   }

   DateTime _parseTaskDateTime(String date, String time) {
     final dateParts = date.split('/');
     final timeParts = time.split(':');

     return DateTime(
       int.parse(dateParts[2]),
       int.parse(dateParts[1]),
       int.parse(dateParts[0]),
       int.parse(timeParts[0]),
       int.parse(timeParts[1]),
     );
   }
}
