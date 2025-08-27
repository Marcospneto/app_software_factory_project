import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as httpPackage;
import 'package:meu_tempo/config/http_common.dart';
import 'package:meu_tempo/config/local_database.dart';
import 'package:meu_tempo/services/secure_storage_service.dart';
import 'package:meu_tempo/services/util_service.dart';

class AuthService {
  final _http = HttpCommon();
  final SecureStorageService _storageService = SecureStorageService();
  String? _accessToken;
  LocalDatabase localDatabase = LocalDatabase();

  bool get isAuthenticated => _accessToken != null;

  Future<httpPackage.Response> authenticate(
      String email, String password) async {
    final data = {"email": email, "password": password};

    final response = await _http.post('/auth/login', body: data);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data["accessToken"];
      await _storageService.saveTokens(
          data["accessToken"], data["refreshToken"]);
    } else {
      debugPrint("Falha no login");
    }

    return response;
  }

  Future<void> logout() async {
    _accessToken = null;
    localDatabase.clearHivelogout();
    await _storageService.clearTokens();
  }

  Future<void> refreshToken() async {
    String? refreshToken = await _storageService.refreshToken;
    if (refreshToken == null) {
      logout();
      return;
    }

    final data = {
      "refreshToken": refreshToken,
    };

    final response = await _http.post('/auth/refresh', body: data);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data["accessToken"];
      await _storageService.saveTokens(
          data["accessToken"], data["refreshToken"]);
    } else {
      logout();
    }
  }
}
