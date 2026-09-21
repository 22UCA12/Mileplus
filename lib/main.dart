import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'driver_home_page.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  runApp(
    const MilePlusApp(),
  );
}
class MilePlusApp extends StatelessWidget {
  const MilePlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'MilePlus',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor:
          const Color(0xFF08743F),
        ),

        scaffoldBackgroundColor:
        const Color(0xFFF4F8F6),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      home: const SessionChecker(),
    );
  }
}

// ===========================================================
// SESSION CHECKER
// ===========================================================

class SessionChecker extends StatelessWidget {
  const SessionChecker({super.key});

  Future<bool> checkSession() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      'isLoggedIn',
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkSession(),

      builder: (
          context,
          snapshot,
          ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child:
              CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return const DriverHomePage();
        }

        return const LoginPage();
      },
    );
  }
}