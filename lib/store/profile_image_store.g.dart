// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_image_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProfileImageStore on _ProfileImageStoreBase, Store {
  late final _$imageAtom =
      Atom(name: '_ProfileImageStoreBase.image', context: context);

  @override
  File? get image {
    _$imageAtom.reportRead();
    return super.image;
  }

  @override
  set image(File? value) {
    _$imageAtom.reportWrite(value, super.image, () {
      super.image = value;
    });
  }

  late final _$loadImageAsyncAction =
      AsyncAction('_ProfileImageStoreBase.loadImage', context: context);

  @override
  Future<void> loadImage({required dynamic email}) {
    return _$loadImageAsyncAction.run(() => super.loadImage(email: email));
  }

  late final _$uploadProfileImageAsyncAction = AsyncAction(
      '_ProfileImageStoreBase.uploadProfileImage',
      context: context);

  @override
  Future<void> uploadProfileImage(
      {required File imageFile, required String email}) {
    return _$uploadProfileImageAsyncAction.run(
        () => super.uploadProfileImage(imageFile: imageFile, email: email));
  }

  late final _$_ProfileImageStoreBaseActionController =
      ActionController(name: '_ProfileImageStoreBase', context: context);

  @override
  void setImage(File? newImage) {
    final _$actionInfo = _$_ProfileImageStoreBaseActionController.startAction(
        name: '_ProfileImageStoreBase.setImage');
    try {
      return super.setImage(newImage);
    } finally {
      _$_ProfileImageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearImage() {
    final _$actionInfo = _$_ProfileImageStoreBaseActionController.startAction(
        name: '_ProfileImageStoreBase.clearImage');
    try {
      return super.clearImage();
    } finally {
      _$_ProfileImageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
image: ${image}
    ''';
  }
}
