import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/auth/ui/loginPage.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/features/bankCo/ui/Poker.dart';
import 'package:flutter_application_1/features/auth/authWrapper.dart';
import 'package:flutter_application_1/features/home/ui/homePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomePage(),
    );
  }
}
