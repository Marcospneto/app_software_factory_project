
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum _SecureStorageKeys {
  accessToken, refreshToken
}

class SecureStorageService {
  static late final FlutterSecureStorage _secureStorage;
  static void init() => _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked)
  );

  Future<String> get accessToken async => await _secureStorage.read(key: _SecureStorageKeys.accessToken.name) ?? '';
  
  Future<bool> hasToken() => _secureStorage.containsKey(key: _SecureStorageKeys.accessToken.name);
  
  Future<void> clearTokens() async => await _secureStorage.deleteAll();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _SecureStorageKeys.accessToken.name, value: accessToken);
    await _secureStorage.write(key: _SecureStorageKeys.refreshToken.name, value: refreshToken);
  }

  Future<String?> get refreshToken async => await _secureStorage.read(key: _SecureStorageKeys.refreshToken.name) ?? '';

}