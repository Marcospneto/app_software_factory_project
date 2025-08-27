
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:meu_tempo/locator/locator.dart';
import 'package:meu_tempo/models/users.dart';
import 'package:meu_tempo/services/auth_service.dart';
import 'package:meu_tempo/services/image_service.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:meu_tempo/store/profile_image_store.dart';
import 'package:mobx/mobx.dart';

part 'user_store.g.dart';

class UserStore = _UserStoreBase with _$UserStore;

abstract class _UserStoreBase with Store {
  final UsersService _usersService = getIt<UsersService>();
  final ImageService _imageService = getIt<ImageService>();
  final AuthService _authService = getIt<AuthService>();
  final ProfileImageStore _profileImageStore = getIt<ProfileImageStore>();

  @observable
  Users? currentUser;
  @observable
  bool isLoading = false;

  @computed
  String get userName => currentUser?.name ?? 'Carregando...';

  @action
  Future<void> loadCurrentUser() async {
    isLoading = true;
    try {
      final user = await _usersService.getCurrentUser();
      if (user != null) {
        currentUser = user;
      }
    } catch (e) {
      print('Erro ao carregar usuário: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> updateUser({required String name, required String telephone}) async {
    if (currentUser == null) return;
    isLoading = true;
    try {
      await _usersService.updateUser(
          currentUser!.id,
          currentUser!.email,
          name,
          telephone
      );

      currentUser = currentUser!.copyWith(name: name, telephone: telephone);
    } catch (e) {
      debugPrint('Erro ao atualizar usuário: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> logout() async {
    await _authService.logout();
    currentUser = null;
    _profileImageStore.clearImage();
  }
}