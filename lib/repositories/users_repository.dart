import 'package:meu_tempo/config/application_constants.dart';
import 'package:meu_tempo/services/couchbase_service.dart';
import 'package:meu_tempo/models/users.dart';

class UsersRepository {
  late final CouchbaseService couchbaseService = CouchbaseService();
   final collectionName = ApplicationConstants.collectionUsers;

  Future<void> addUser(Users user) async {
    await couchbaseService.add(
      data: user.toMap(),
      collectionName: collectionName,
    );
  }

  Future<List<Users>> fetchUser(String email) async {
    final result = await couchbaseService.fetch(
      collectionName: collectionName,
      filter: 'email=$email'
    );

    return result.map(Users.fromMap).toList();
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await couchbaseService.edit(collectionName: collectionName, id: id, data: data);
  }
}