import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalDatabase {
  Future<void> saveData(dynamic data, String key) async {
    final box = await Hive.box('meu_tempo');
    await box.put(key, data);
  }

  Future<dynamic> getData(String key) async {
    final box = await Hive.box('meu_tempo');
    return box.get(key);
  }

  Future<void> clearHivelogout() async {
    final knownBoxes = [
      'meu_tempo',
      'imageBox',
    ];

    for (String boxName in knownBoxes) {
      try {
        final box = await Hive.openBox(boxName);

        if (box.isOpen) {
          await box.close();
        }

        await Hive.deleteBoxFromDisk(boxName);
        debugPrint('Box "$boxName" apagado completamente do aparelho');
      } catch (e) {
        debugPrint('Erro ao apagar o box "$boxName": $e');
      }

      debugPrint('Processo de limpeza dos box concluído');
    }
  }
}
