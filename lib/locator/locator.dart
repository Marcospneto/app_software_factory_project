import 'package:get_it/get_it.dart';
import 'package:meu_tempo/config/http_common.dart';
import 'package:meu_tempo/repositories/task_repository.dart';
import 'package:meu_tempo/repositories/time_center_repository.dart';
import 'package:meu_tempo/repositories/users_repository.dart';
import 'package:meu_tempo/services/auth_service.dart';
import 'package:meu_tempo/services/couchbase_service.dart';
import 'package:meu_tempo/services/image_service.dart';
import 'package:meu_tempo/services/recovery_service.dart';
import 'package:meu_tempo/services/secure_storage_service.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:meu_tempo/store/profile_image_store.dart';
import 'package:meu_tempo/store/task_store.dart';
import 'package:meu_tempo/store/user_store.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => CouchbaseService());
  getIt.registerLazySingleton(
      () => UsersRepository(couchbaseService: getIt<CouchbaseService>()));
  getIt.registerLazySingleton(() => AuthService());
  getIt.registerLazySingleton(() => ImageService());
  getIt.registerLazySingleton(() => RecoveryService());
  getIt.registerLazySingleton(() => SecureStorageService());
  getIt.registerLazySingleton(() => HttpCommon(
        authService: getIt<AuthService>(),
        secureStorageService: getIt<SecureStorageService>(),
      ));

  getIt.registerLazySingleton(() => TaskRepository(
        couchbaseService: getIt<CouchbaseService>(),
      ));
  getIt.registerLazySingleton(() => TimeCenterRepository(
        couchbaseService: getIt<CouchbaseService>(),
      ));

  getIt.registerLazySingleton(() => UsersService());

  getIt.registerLazySingleton(() => ProfileImageStore());
  getIt.registerLazySingleton(() => UserStore());
  getIt.registerLazySingleton(() => TaskStore());
}
