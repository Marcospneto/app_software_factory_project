import 'package:flutter/material.dart';
import 'package:meu_tempo/services/auth_service.dart';
import 'package:meu_tempo/services/couchbase_service.dart';
import 'package:meu_tempo/views/month_calendar_page.dart';
import 'package:meu_tempo/widgets/custom_appbar_calendar.dart';
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
  late DateTime _focusedDay;

  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
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
    } catch (e) {
      debugPrint(
          'Algo não saiu como esperado. Por favor, tente novamente em instantes');
    }
  }

  void _onDateChange(DateTime newDate) {
    setState(() {
      _focusedDay = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarCalendar(
        currentDate: _focusedDay,
        onDateChange: (year, month) {
          _onDateChange(DateTime(year, month, 1));
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: MonthCalendarPage(
              focuseDay: _focusedDay,
              onDaySelected: (newDate) {
                _onDateChange(newDate);
              },
            ),
          ),
          CustomMenu(),
        ],
      ),
    );
  }
}
