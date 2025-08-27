import 'package:flutter/material.dart';

enum AlertType { success, warning, error }

class CustomAlert extends StatelessWidget {
  final String title;
  final String message;
  final AlertType type;
  final VoidCallback onOkPressed;

  const CustomAlert({
    Key? key,
    required this.title,
    required this.message,
    required this.type,
    required this.onOkPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    // Define o ícone e a cor com base no tipo do alerta
    switch (type) {
      case AlertType.success:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case AlertType.warning:
        icon = Icons.warning;
        iconColor = Colors.orange;
        break;
      case AlertType.error:
        icon = Icons.error;
        iconColor = Colors.red;
        break;
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(icon, color: iconColor),
          SizedBox(width: 10),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onOkPressed,
          child: Text('OK', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}