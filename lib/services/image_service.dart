import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hive/hive.dart';
import 'package:meu_tempo/config/http_common.dart';
import 'package:meu_tempo/locator/locator.dart';
import 'package:meu_tempo/services/util_service.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final http = getIt<HttpCommon>();

  Future<void> uploadImage({required File imageFile, required String email}) async {
    try {
      if (imageFile != null) {
        await deleteAllLocalImagens();
        await deleteImageApi(email: email);
        await _saveImageLocal(imageFile);
        await _saveImageApi(imageFile: imageFile, email: email);
        debugPrint('Upload realizado com sucesso!');
      }
    } catch (e) {
      debugPrint('Não foi possível realizar o upload');
    }
  }

  Future<void> _saveImageLocal(File imageFile) async {
    try {
      final compressedBytes = await compressImage(imageFile);
      if (compressedBytes != null) {
        final box = await Hive.openBox('imageBox');
        await deleteAllLocalImagens();
        await box.put(
            'image_${DateTime.now().millisecondsSinceEpoch}', compressedBytes);
        debugPrint('Imagem salva com sucesso');
      } else {
        debugPrint('Falha ao comprimir a imagem');
      }
    } catch (e) {
      debugPrint('Erro ao salvar imagem no hive: $e');
    }
  }

  Future<void> _saveImageApi({required File imageFile, required String email}) async {
    try {
      final compressedBytes = await compressImage(imageFile);
      if (compressedBytes != null) {
        final imageBase64 = base64Encode(compressedBytes);
        var data = {
          'image': imageBase64,
        };

        final response = await http.post('/users/image/$email/upload', body: data, useAuth: true);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('Requisição enviada e processada com sucesso pela API!');
        } else {
          debugPrint('A API retornou um erro:');
          debugPrint('Status Code: ${response.statusCode}');
          debugPrint('Corpo da Resposta: ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Falha ao enviar a requisição');
    }
  }

  Future<File?> loadProfileImage({required String email}) async {
    final imageLocal = await _getImageLocal();
    if (imageLocal != null) {
      return imageLocal;
    } else {
      final imageApi = await _getImageApi(email: email);
      if (imageApi != null) {
        _saveImageLocal(imageApi);
        return imageApi;
      }
      return null;
    }
  }

  Future<File?> _getImageLocal() async {
    final imageKeys = await _getAllImageKeys();
    if (imageKeys.isNotEmpty) {
      final latestImageKeys = imageKeys.last;
      final imageBytes = await _getImageFromHive(latestImageKeys);
      if (imageBytes != null) {
        final imageFile = await UtilService.convertUint8ListToFile(imageBytes);
        return imageFile;
      }
    }

    return null;
  }

  Uint8List? _getImageFromHive(String key) {
    try {
      final box = Hive.box('imageBox');
      final imageData = box.get(key);
      return imageData is Uint8List ? imageData : null;
    } catch (e) {
      debugPrint('Erro ao recuperar imagem: $e');
      return null;
    }
  }

  Future<File?> _getImageApi({required String email}) async {
    try {
      final response = await http.get('/users/image/$email', useAuth: true);
      if (response != null && response.statusCode == 200) {
        final imageBytes = base64Decode(response.body);

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/profile_image_$email.jpg');
        await file.writeAsBytes(imageBytes);
        debugPrint('Imagem da api baixada');
        return file;
      } else {
        debugPrint('Falha ao buscar imagem da API. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao buscar imagem na API: $e');
      return null;
    }
  }

  Future<List<String>> _getAllImageKeys() async {
    final box = await Hive.openBox('imageBox');
    return box.keys.cast<String>().toList();
  }

  Future<void> deleteAllLocalImagens() async {
    try {
      final box = await Hive.openBox('imageBox');
      await box.clear();
      debugPrint('Todas as imagens locais foram removidas do Hive');
    } catch (e) {
      debugPrint('Erro ao deletar imagens locais: $e');
      throw Exception('Falha ao remover imagens locais');
    }
  }

  Future<void> deleteImageApi({required String email}) async {
    await http.delete('/users/image/$email', useAuth: true);
  }

  Future<Uint8List?> compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 600,
        minHeight: 600,
        quality: 70,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
      debugPrint('Erro ao comprimir imagem: $e');
      return null;
    }
  }
}
