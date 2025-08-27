import 'package:flutter/material.dart';
import 'package:meu_tempo/services/util_service.dart';

class TimeCenter {
  final String? id;
  final String name;
  final Color color;
  final int order;
  final String idUser;

  TimeCenter({this.id, required this.name, required this.color,  required this.order, required this.idUser});

  TimeCenter copyWith({String? id, String? name, Color? color, int? order, String? idUser}) {
    return TimeCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      order: order ?? this.order,
      idUser: idUser ?? this.idUser
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': UtilService.colorToHex(color),
      'order': order,
      'idUser': idUser
    };
  }

  factory TimeCenter.fromMap(Map<String, dynamic> data) {
    return TimeCenter(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      color: UtilService.hexToColor(data['color']),
      order: data['order'],
      idUser: data['idUser']
    );
  }

  static TimeCenter empty() => TimeCenter(
    id: '',
    name: '',
    color: Colors.transparent,
    order: 0,
    idUser: '',
  );
}
