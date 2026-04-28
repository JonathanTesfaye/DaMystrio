import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/ui/widgets/auth_card.dart';
import 'package:flutter_application_1/features/auth/login_form.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/core/services/auth_service.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'registerPage.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final authService = AuthService();

  void loginUser() {
    if (formKey.currentState!.validate()) {
      print('Form is Valid');
    } else {
      print('Form is Invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ), // ✅ themed gradient
        child: Stack(
          children: [
            // Background image with gradient mask
            Animate(
              child: Image.asset(
                'lib/assets/images/LoginImage.png',
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 1,
                fit: BoxFit.cover,
                color: AppTheme.primaryGold.withOpacity(
                  0.1,
                ), // subtle gold tint
                colorBlendMode: BlendMode.lighten,
              ),
            ).custom(
              builder: (context, value, child) {
                return ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.pureBlack,
                        Colors.transparent,
                      ], // ✅ use theme black
                      stops: const [0.1, 0.4],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: child,
                );
              },
            ),

            // Welcome text (themed)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: 20,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  "Welcome to DaMystrio",
                  style: AppTheme.headingLarge.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ), // ✅ themed
                ),
              ),
            ),

            // Auth card (already uses your theme if updated)
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
                      child: Text(
                        "Create an account",
                        style: AppTheme.bodyText, // ✅ themed
                      ),
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
