import 'package:flutter/material.dart';

enum TaskPriority {
  SIMPLE(1, 'Simples', Colors.blueGrey),
  EXPRESS(2, 'Rápida', Colors.indigo),
  URGENT(3, 'Urgente', Colors.orangeAccent),
  URGENTE_URGENT(4, 'Super Urgente', Colors.red);

  final int value;
  final String label;
  final Color color;

  const TaskPriority(this.value, this.label, this.color);

  static TaskPriority? fromString(String value) {
    try {
      return TaskPriority.values.firstWhere(
            (e) => e.name == value.toUpperCase() ||
            e.label.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  String get name => toString().split('.').last;
}