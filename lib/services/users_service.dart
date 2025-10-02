import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meu_tempo/config/http_common.dart';
import 'package:meu_tempo/locator/locator.dart';
import 'package:meu_tempo/models/users.dart';
import 'package:meu_tempo/repositories/users_repository.dart';
import 'package:meu_tempo/services/secure_storage_service.dart';
import 'package:meu_tempo/services/util_service.dart';
import 'package:http/http.dart' as httpPackage;
import 'package:jwt_decode/jwt_decode.dart';

class UsersService {
  final SecureStorageService secureStorageService = getIt<SecureStorageService>();
  final http = getIt<HttpCommon>();
  final UsersRepository usersRepository = getIt<UsersRepository>();

  Future<httpPackage.Response> createUser(Users user) async {
    var data = {
      "name": user.name,
      "email": user.email,
      "telephone": UtilService.removeMask(user.telephone),
      "password": user.password,
      "idProfile": user.idProfile
    };

    return await http.post('/users', body: data);
  }

  Future<Users?> getCurrentUser() async {
    try {
      final accessToken = await secureStorageService.accessToken;
      final payload = Jwt.parseJwt(accessToken);
      final email = payload['sub'];
      final localUser = await usersRepository.fetchUser(email);

      return localUser.first;
    } catch (e) {
      debugPrint('Algo inesperado aconteceu. Tente novamente mais tarde!');
      return null;
    }
  }

  Future<void> fetchUserFromToken() async {
    try {
      final accessToken = await secureStorageService.accessToken;
      final payload = Jwt.parseJwt(accessToken);
      final email = payload['sub'];
      final localUser = await usersRepository.fetchUser(email);
      
      if (localUser.isEmpty) {
        final userApi = await _fetchUserFromApi(email);
        await usersRepository.addUser(userApi);
      }
    } catch (e) {
      debugPrint('Erro ao buscar usuário: $e');
    }
  }

Future<Users> _fetchUserFromApi(String email) async {
    try {
      final response = await http.get('/users/$email', useAuth: true);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        return Users.fromMap(data);
      } else {
        throw Exception('Falha ao buscar usuário.');
      }
    } catch (e) {
      throw Exception('Falha na requisição: $e');
    }
  }

  Future<void> updateUser(String? id, String email, String name, String telephone) async {
    try {
      final body = {
        'name': name,
        'telephone': telephone,
      };

      final response = await http.put(
        '/users/$email',
        body: body,
        useAuth: true,
      );

      await usersRepository.updateUser(id!, {
        'name': name,
        'telephone': telephone,
      });

      if (response.statusCode != 204) {
        throw Exception('Erro ao atualizar o usuário. Código: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar o usuário: $e');
    }
  }
}
