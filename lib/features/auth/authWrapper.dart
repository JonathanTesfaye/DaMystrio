import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ui/loginPage.dart';
import '../home/ui/homePage.dart';

class Authwrapper extends StatelessWidget {
  const Authwrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
