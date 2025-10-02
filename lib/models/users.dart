import 'package:meu_tempo/models/profile.dart';

class Users {
  final String? id;
  final String name;
  final String email;
  final String telephone;
  final String password;
  final int idProfile;

  Users({
    this.id,
    required this.name,
    required this.email,
    required this.telephone,
    required this.password,
    required this.idProfile,
  });

  factory Users.fromMap(Map<String, dynamic> data) {
    final profilesList = data['profiles'] as List? ?? [];
    final firstProfileId =
        profilesList.isNotEmpty ? profilesList.first['id'] : 1;

    return Users(
      id: _parseId(data['id']),
      name: data['name'],
      email: data['email'],
      telephone: data['telephone'],
      password: data['password'] as String? ?? '',
      idProfile: Profile.fromValue(firstProfileId).value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'telephone': telephone,
      'password': password,
      'profile': idProfile,
    };
  }

  static String? _parseId(dynamic id) {
    if (id == null) return null;
    return id.toString();
  }

  Users copyWith({
    String? id,
    String? email,
    String? name,
    String? telephone,
  }) {
    return Users(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      telephone: telephone ?? this.telephone,
      password: '',
      idProfile: this.idProfile,
    );
  }
}
