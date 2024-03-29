import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:help_find_the_missing/firebase_options.dart';
import 'package:help_find_the_missing/screens/home_screen.dart';
import 'package:help_find_the_missing/screens/welcome_screen.dart';
import 'package:help_find_the_missing/screens/add_report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        AddReportScreen.id: (context) => AddReportScreen(),
      },
    );
  }
}
