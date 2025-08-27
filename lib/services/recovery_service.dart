import 'package:meu_tempo/config/http_common.dart';
import 'package:http/http.dart' as httpPackage;
import 'package:meu_tempo/services/secure_storage_service.dart';

class RecoveryService {
  late final HttpCommon http;

  RecoveryService() {
    final secureStorageService = SecureStorageService();
    http = HttpCommon(secureStorageService: secureStorageService);
  }

  Future<httpPackage.Response> alterPassword(Map<String, dynamic> data) async {
    return await http.put('/auth/recovery', body: data);
  }

  Future<httpPackage.Response> changePassword(Map<String, dynamic> data) async {
    return await http.put('/auth/alter-password', body: data, useAuth: true);
  }
}
