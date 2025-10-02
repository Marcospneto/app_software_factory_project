import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';

class CustomAlertDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    if (Navigator.of(context).mounted) {
      bool? result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(backgroundColor: Colors.white),
                child: Text("Não", style: TextStyle(color: MainColor.primaryColor),),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MainColor.secondaryColor,
                ),
                child: Text("Sim", style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        },
      );
      return result ?? false;
    } else {
      return false;
    }
  }
}