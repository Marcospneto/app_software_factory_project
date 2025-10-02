import 'package:flutter/material.dart';

enum SnackBarType { success, error, alert }

void CustomSnackbar(
  BuildContext context, {
  required String message,
  required SnackBarType type,
  required int timeSeconds,
}) {
  Color backgroundColor;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = Colors.green;
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red;
      break;
    case SnackBarType.alert:
      backgroundColor = Colors.amber[800]!;
      break;
  }

  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    duration: Duration(seconds: timeSeconds),
    margin: const EdgeInsets.all(16),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
