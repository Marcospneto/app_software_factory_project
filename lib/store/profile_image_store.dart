import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:meu_tempo/locator/locator.dart';
import 'package:meu_tempo/services/image_service.dart';
import 'package:meu_tempo/store/user_store.dart';
import 'package:mobx/mobx.dart';

part 'profile_image_store.g.dart';

class ProfileImageStore = _ProfileImageStoreBase with _$ProfileImageStore;

abstract class _ProfileImageStoreBase with Store {
  final ImageService imageService = getIt<ImageService>();

  @observable
  File? image;

  @action
  void setImage(File? newImage) {
    image = newImage;
  }

  @action
  void clearImage() {
    image = null;
  }

  @action
  Future<void> loadImage({required email}) async {
    final image = await imageService.loadProfileImage(email: email);
    setImage(image);
  }

  @action
  Future<void> uploadProfileImage({required File imageFile, required String email}) async {
    try {
      await imageService.uploadImage(imageFile: imageFile, email: email);
      setImage(imageFile);
      debugPrint("Imagem de perfil atualizada com sucesso.");
    } catch (e) {
      debugPrint("Erro ao atualizar imagem de perfil: $e");
    }
  }
}
