import 'package:flutter/material.dart';
import 'package:meu_tempo/services/auth_service.dart';
import 'package:meu_tempo/services/couchbase_service.dart';
import 'package:meu_tempo/views/intro_page.dart';
import 'package:meu_tempo/widgets/custom_appbar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:meu_tempo/widgets/custom_menu.dart';
import 'package:meu_tempo/services/users_service.dart';

import '../config/application_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  AuthService authService = AuthService();
  late final UsersService usersService = UsersService();
  final couchbaseService = CouchbaseService();

  void initState() {
    super.initState();
    _initializeUserData();
    couchbaseService.startReplication(
      collectionName: ApplicationConstants.collectionUsers,
      onSynced: () {
        _initializeUserData();
      },
    );
    couchbaseService.networkStatusListen();
  }

  Future<void> _initializeUserData() async {
    try {
      await usersService.fetchUserFromToken();
    } catch(e) {
      debugPrint('Algo não saiu como esperado. Por favor, tente novamente em instantes');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ''),
      body: Center(
        child: CustomButton(
            width: 100,
            color: Colors.red,
            text: 'sair',
            onPressed: () async {
              await authService.logout();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => IntroPage()),
                  (Route<dynamic> route) => false);
            }),
      ),
      bottomSheet: CustomMenu(),
    );
  }
}