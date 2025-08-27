import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:meu_tempo/enums/task_priority.dart';
import 'package:path_provider/path_provider.dart';

class UtilService {

  static final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  static String removeMask(String userPhone) {
    return userPhone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String formatarHora(TimeOfDay hora) {
     final horaStr = hora.hour.toString().padLeft(2, '0');
     final minutoStr = hora.minute.toString().padLeft(2, '0');
     return '$horaStr:$minutoStr';
   }
  
  static bool isEndTimeAfterStartTime(String startTime, String endTime) {
     try {
       final startParts = startTime.split(':');
       final endParts = endTime.split(':');

       final start = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
       final end = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));

       final now = DateTime.now();
       final startDateTime = DateTime(now.year, now.month, now.day, start.hour, start.minute);
       final endDateTime = DateTime(now.year, now.month, now.day, end.hour, end.minute);

       return endDateTime.isAfter(startDateTime);
     } catch (_) {
       return false;
     }
   }

  static Color hexToColor(String hex) {
    return Color(int.parse(hex, radix: 16));
  }

  static String colorToHex(Color color) {
    return color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  static Future<File?> convertUint8ListToFile(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/image_$timestamp.jpg';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return file;
    } catch (e) {
      debugPrint('Erro ao converter Uint8List para File: $e');
      return null;
    }
  }

  static String formatMask(String value) {
    return _phoneMaskFormatter.maskText(value);
  }
}