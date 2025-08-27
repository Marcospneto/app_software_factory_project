import 'dart:async';
import 'package:cbl/cbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meu_tempo/config/application_constants.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CouchbaseService {
  AsyncDatabase? database;
  AsyncReplicator? replicator;
  StreamSubscription<List<ConnectivityResult>>? networkConnection;
  final _scope = ApplicationConstants.scope;

  Future<void> init() async {
    Database.log.console.level = LogLevel.verbose;
    database ??= await Database.openAsync('database');

    await database?.createIndex(
      'idx_idUser',
      IndexBuilder.valueIndex(
        [ValueIndexItem.property('idUser')],
      ),
    );
  }

  Future<void> startReplication({
    required String collectionName,
    required Function() onSynced,
  }) async {
    await init();
    final usernameEnv = dotenv.get('USERNAME');
    final publicConnectionUrlEnv = dotenv.get('PUBLIC_CONNECTION_URL');
    final passwordEnv = dotenv.get('PASSWORD');
    final channelEnv = ApplicationConstants.channel;

    final collection = await database?.createCollection(
      collectionName,
      _scope,
    );

    if (collection != null) {
      final replicatorConfig = ReplicatorConfiguration(
        target: UrlEndpoint(
          Uri.parse(publicConnectionUrlEnv),
        ),
        authenticator: BasicAuthenticator(
          username: usernameEnv,
          password: passwordEnv,
        ),
        continuous: true,
        replicatorType: ReplicatorType.pushAndPull,
        enableAutoPurge: true,
      );
      replicatorConfig.addCollection(
        collection,
        CollectionConfiguration(
          channels: [channelEnv],
        ),
      );
      replicator = await Replicator.createAsync(replicatorConfig);
      replicator?.addChangeListener(
        (change) {
          if (change.status.error != null) {
            debugPrint('Erro na replicação: ${change.status.error}');
          }
          if (change.status.activity == ReplicatorActivityLevel.idle) {
            debugPrint('ocorreu uma sincronização');
            onSynced();
          }
        },
      );
      await replicator?.start();
    }
  }

  void networkStatusListen() {
    networkConnection = Connectivity().onConnectivityChanged.listen(
      (events) {
        if (events.contains(ConnectivityResult.none)) {
          debugPrint('Sem conexão com a internet');
          replicator?.stop();
        } else {
          debugPrint('Conectado com a internet');
          replicator?.start();
        }
      },
    );
  }

  Future<bool> add({
    required Map<String, dynamic> data,
    required String collectionName,
  }) async {
    final collection = await database?.createCollection(
      collectionName,
      _scope,
    );

    if (collection != null) {
      final id = data['id'] ?? Uuid().v4();
      final document = MutableDocument.withId(id, data);
      return await collection.saveDocument(document);
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> fetch({
    required String collectionName,
    String? filter,
  }) async {
    await init();
    await database?.createCollection(collectionName, _scope);
    final queryString = '''
    SELECT META().id, *
    FROM $_scope.$collectionName
    ${filter != null ? 'WHERE ${_parseFilter(filter)}' : ''}
    ''';

    final query = await database?.createQuery(queryString);
    final result = await query?.execute();
    final results = await result?.allResults();
    
    return results?.map((e) {
          final data = e.toPlainMap();
          return {
            'id': e.string('id'),
            ...(data[collectionName] as Map<String, dynamic>)
          };
        }).toList() ??
        [];
  }

  Future<List<Map<String, dynamic>>> fetchWithCustomWhere({
    required String collectionName,
    required String whereCondition,
  }) async {
    await init();
    await database?.createCollection(collectionName, _scope);

    final queryString = '''
    SELECT META().id, *
    FROM $_scope.$collectionName
    WHERE $whereCondition
  ''';

    final query = await database?.createQuery(queryString);
    final result = await query?.execute();
    final results = await result?.allResults();

    return results?.map((e) {
          final data = e.toPlainMap();
          return {
            'id': e.string('id'),
            ...(data[collectionName] as Map<String, dynamic>)
          };
        }).toList() ??
        [];
  }

  Future<bool> edit({
    required String collectionName,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final collection = await database?.createCollection(
      collectionName,
      _scope,
    );
    if (collection != null) {
      final doc = await collection.document(id);
      if (doc != null) {
        final mutableDoc = doc.toMutable();
        data.forEach(
          (key, value) {
            mutableDoc.setValue(value, key: key);
          },
        );
        final result = await collection.saveDocument(mutableDoc);
        return result;
      }
    }
    return false;
  }

  Future<bool> delete({
    required String collectionName,
    required String id,
  }) async {
    final collection = await database?.createCollection(
      collectionName,
      _scope,
    );
    if (collection != null) {
      final doc = await collection.document(id);
      if (doc != null) {
        final result = await collection.deleteDocument(doc);
        return result;
      }
    }
    return false;
  }

  String _parseFilter(String filter) {
    final parts = filter.split('=');
    if (parts.length == 2) {
      final field = parts[0].trim();
      final value = parts[1].trim().replaceAll('"', '');
      return '$field = "$value"';
    }
    return filter;
  }
}
