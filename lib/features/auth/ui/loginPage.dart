import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/ui/widgets/auth_card.dart';
import 'package:flutter_application_1/features/auth/login_form.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/core/services/auth_service.dart';
import 'registerPage.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final authService = AuthService();
  static const Color darkBlueBg = Color(0xFF0D1B2A);

  void loginUser() {
    if (formKey.currentState!.validate()) {
      print('Form is Valid');
    } else {
      print('Form is Invalid');
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: darkBlueBg,
        child: Stack(
          children: [
            //Background
            Animate(
              child: Image.asset(
                'lib/assets/images/PokerCoin.png',
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 1,
                fit: BoxFit.cover,
              ),
            ).custom(
              builder: (context, value, child) {
                return ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent],
                      stops: [0.1, 0.4],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: child,
                );
              },
            ),

            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    "Welcome to DaMystrio",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),

            //UI
            Container(
              margin: const EdgeInsets.fromLTRB(0, 80, 0, 0),
              color: Colors.transparent,
              child: Center(
                child: SingleChildScrollView(
                  child: AuthCard(
                    title: 'Login',
                    form: LoginForm(
                      emailController: emailController,
                      passwordController: passwordController,
                      formKey: formKey,
                    ),
                    buttonText: 'Login',
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final error = await authService.login(
                          emailController.text,
                          passwordController.text,
                        );
                        if (error != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        } else {
                          print('Login successful');
                        }
                      }
                    },
                    switchButton: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      child: const Text("Create an account"),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
