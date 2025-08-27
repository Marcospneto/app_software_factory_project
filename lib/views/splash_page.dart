import 'package:flutter/material.dart';
import 'package:meu_tempo/providers/tips_provider.dart';
import 'package:meu_tempo/services/secure_storage_service.dart';
import 'package:provider/provider.dart';
import '../config/app_routes.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:meu_tempo/services/task_notification_callback.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      _initHive(),
      CouchbaseLiteFlutter.init(),
      dotenv.load(),
      _initWorkManager(),
      _requestNotificationsPermission(),
    ]);

    SecureStorageService.init();
    Intl.defaultLocale = 'pt_BR';

    final tipsProvider = Provider.of<TipsProvider>(context, listen: false);
    await tipsProvider.initialize();

    if (tipsProvider.fetchNewTip()) {
      if (!tipsProvider.loading) {
        await tipsProvider.fetchTip();
        if (mounted) {
          await Navigator.pushNamed(context, AppRoutes.daytip);
        }
      }
    }

    final hasToken = await SecureStorageService().hasToken();
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        hasToken ? AppRoutes.home : AppRoutes.intro,
      );
    }
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    await Hive.openBox('meu_tempo');
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Future<void> _initWorkManager() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  Future<void> _requestNotificationsPermission() async {
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
