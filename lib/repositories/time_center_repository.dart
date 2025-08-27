import 'package:meu_tempo/config/application_constants.dart';
import 'package:meu_tempo/models/time_center.dart';
import 'package:meu_tempo/services/couchbase_service.dart';

class TimeCenterRepository {
  final CouchbaseService couchbaseService;

  TimeCenterRepository({required this.couchbaseService});

  final collectionName = ApplicationConstants.collectionTimeCenters;

  Future<void> addItem(TimeCenter timeCenter) async {
    await couchbaseService.add(
      data: timeCenter.toMap(),
      collectionName: collectionName,
    );
  }

  Future<List<TimeCenter>> fetchIdUser(String idUser) async {
    final result = await couchbaseService.fetch(
        collectionName: collectionName, filter: 'idUser=$idUser');
    return result.map(TimeCenter.fromMap).toList();
  }

  Future<bool> deleteItem(String id) async {
    await couchbaseService.delete(collectionName: collectionName, id: id);
    return true;
  }

  Future<void> updateTimeCenterOrder(List<TimeCenter> timeCenters) async {
    for (final timeCenter in timeCenters) {
      await couchbaseService.add(
        data: timeCenter.toMap(),
        collectionName: collectionName,
      );
    }
  }
}
