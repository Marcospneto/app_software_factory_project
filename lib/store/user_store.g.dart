// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserStore on _UserStoreBase, Store {
  Computed<String>? _$userNameComputed;

  @override
  String get userName =>
      (_$userNameComputed ??= Computed<String>(() => super.userName,
              name: '_UserStoreBase.userName'))
          .value;

  late final _$currentUserAtom =
      Atom(name: '_UserStoreBase.currentUser', context: context);

  @override
  Users? get currentUser {
    _$currentUserAtom.reportRead();
    return super.currentUser;
  }

  @override
  set currentUser(Users? value) {
    _$currentUserAtom.reportWrite(value, super.currentUser, () {
      super.currentUser = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_UserStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$loadCurrentUserAsyncAction =
      AsyncAction('_UserStoreBase.loadCurrentUser', context: context);

  @override
  Future<void> loadCurrentUser() {
    return _$loadCurrentUserAsyncAction.run(() => super.loadCurrentUser());
  }

  late final _$updateUserAsyncAction =
      AsyncAction('_UserStoreBase.updateUser', context: context);

  @override
  Future<void> updateUser({required String name, required String telephone}) {
    return _$updateUserAsyncAction
        .run(() => super.updateUser(name: name, telephone: telephone));
  }

  late final _$logoutAsyncAction =
      AsyncAction('_UserStoreBase.logout', context: context);

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  @override
  String toString() {
    return '''
currentUser: ${currentUser},
isLoading: ${isLoading},
userName: ${userName}
    ''';
  }
}
