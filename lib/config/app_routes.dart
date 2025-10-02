import 'package:flutter/material.dart';
import 'package:meu_tempo/views/about_page.dart';
import 'package:meu_tempo/views/alter_password.dart';
import 'package:meu_tempo/views/day_calendar_page.dart';
import 'package:meu_tempo/views/edit/edit_profile_page.dart';
import 'package:meu_tempo/views/home_page.dart';
import 'package:meu_tempo/views/intro_page.dart';
import 'package:meu_tempo/views/login_page.dart';
import 'package:meu_tempo/views/daytip_page.dart';
import 'package:meu_tempo/views/code_page.dart';
import 'package:meu_tempo/views/recovery/recovery_email_page.dart';
import 'package:meu_tempo/views/recovery/recovery_password_page.dart';
import 'package:meu_tempo/views/search_task_page.dart';
import 'package:meu_tempo/views/settings_page.dart';
import 'package:meu_tempo/views/signin_page.dart';
import 'package:meu_tempo/views/splash_page.dart';
import 'package:meu_tempo/views/task_page.dart';
import 'package:meu_tempo/views/time_center_page.dart';
import 'package:meu_tempo/views/synthetic_report_page.dart';
import 'package:meu_tempo/views/analytical_report_page.dart';
import 'package:meu_tempo/views/week_calendar.dart';

class AppRoutes {
  static const String intro = "/";
  static const String signin = "/signin";
  static const String login = "/login";
  static const String daytip = "/daytip";
  static const String recoveryEmail = "/recovery-email";
  static const String code = "/recovery-code";
  static const String recoveryPassword = "/recovery-password";
  static const String home = "/home";
  static const String editProfile = "/edit-profile";
  static const String task = "/task";
  static const String timerCenter = "/timer-center";
  static const String settingsPage = "/settings";
  static const String splash = "/splash";
  static const String syntheticReport = "/synthetic-report";
  static const String analyticalReport = "/analytical-report";
  static const String searchTask = "search-task";
  static const String alterPassword = "alter-password";
  static const String about = "/about";
  static const String dayCalendar = "/day-calendar";
  static const String weekCalendar = "/week-calendar";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case intro:
        return MaterialPageRoute(builder: (_) => const IntroPage());
      case signin:
        return MaterialPageRoute(builder: (_) => const SigninPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case daytip:
        return MaterialPageRoute(builder: (_) => const DaytipPage());
      case recoveryEmail:
        return MaterialPageRoute(builder: (_) => RecoveryEmailPage());
      case code:
        return MaterialPageRoute(
            builder: (_) => RecoveryCodePage(), settings: settings);
      case recoveryPassword:
        return MaterialPageRoute(
            builder: (_) => RecoveryPasswordPage(), settings: settings);
      case home:
        return MaterialPageRoute(
            builder: (_) => HomePage(), settings: settings);
      case editProfile:
        return MaterialPageRoute(builder: (_) => EditProfilePage());
      case task:
        return MaterialPageRoute(builder: (_) => TaskPage());
      case timerCenter:
        return MaterialPageRoute(
            builder: (_) => TimeCenterPage(), settings: settings);
      case settingsPage:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case syntheticReport:
        return MaterialPageRoute(builder: (_) => SyntheticReportPage());
      case analyticalReport:
        return MaterialPageRoute(builder: (_) => AnalyticalReportPage());
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case searchTask:
        return MaterialPageRoute(builder: (_) => const SearchTaskPage());
      case alterPassword:
        return MaterialPageRoute(builder: (_) => const AlterPassword());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      case dayCalendar:
        return MaterialPageRoute(
            builder: (_) => DayCalendarPage(selectedDay: DateTime.now()));
      case weekCalendar:
        return MaterialPageRoute(
            builder: (_) => WeekCalendar(selectedDay: [DateTime.now()]));
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
                  body: Center(
                    child: Text('Página não encontrada'),
                  ),
                ));
    }
  }
}
