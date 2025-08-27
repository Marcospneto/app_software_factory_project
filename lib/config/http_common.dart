import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:meu_tempo/services/auth_service.dart';
import 'package:meu_tempo/services/secure_storage_service.dart';
class HttpCommon {
  final String _baseUrl = dotenv.get('BASE_URL');
  final AuthService? _authService;
  final SecureStorageService? _secureStorageService;

  HttpCommon({AuthService? authService, SecureStorageService? secureStorageService})
      : _authService = authService,
        _secureStorageService = secureStorageService;

  Future<http.Response> get(String endpoint, {Map<String, String>? queryParams, bool useAuth = false}) async {
    return _makeRequest('GET', endpoint, queryParams: queryParams, useAuth: useAuth);
  }

  Future<http.Response> post(String endpoint,
      {Map<String, String>? queryParams, Map<String, dynamic>? body, bool useAuth = false}) async {
    return _makeRequest('POST', endpoint, queryParams: queryParams, body: body, useAuth: useAuth);
  }

  Future<http.Response> put(String endpoint,
      {Map<String, String>? queryParams, Map<String, dynamic>? body, bool useAuth = false}) async {
    return _makeRequest('PUT', endpoint, queryParams: queryParams, body: body, useAuth: useAuth);
  }

  Future<http.Response> delete(String endpoint, {bool useAuth = false}) async {
    return _makeRequest('DELETE', endpoint, useAuth: useAuth);
  }

  Future<http.Response> _makeRequest(String method, String endpoint,
      {Map<String, String>? queryParams, Map<String, dynamic>? body, bool useAuth = false}) async {
        
    Uri uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // Adiciona autenticação se necessário
    if (useAuth && _secureStorageService != null) {
      String? token = await _secureStorageService.accessToken;
      debugPrint('Token encontrado no storage: $token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    http.Response response;
    switch (method) {
      case 'POST':
        response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      case 'GET':
      default:
        response = await http.get(uri, headers: headers);
    }

    return _handleResponse(response, method, uri, headers, body);
  }

  Future<http.Response> _handleResponse(http.Response response, String method, Uri uri,
      Map<String, String> headers, Map<String, dynamic>? body) async {
    if (response.statusCode == 401 && _authService != null && _secureStorageService != null) {
      // Se o token expirou, tenta renovar
      await _authService.refreshToken();
      String? newToken = await _secureStorageService.accessToken;
      if (newToken != null && newToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $newToken';

        // Refaz a requisição com o novo token
        return _makeRequest(method, uri.path, queryParams: uri.queryParameters, body: body, useAuth: true);
      }
    }

    return response;
  }
}