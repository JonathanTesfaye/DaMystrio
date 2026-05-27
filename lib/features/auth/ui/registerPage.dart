import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/authService.dart';
import 'package:flutter_application_1/features/auth/ui/widgets/auth_card.dart';
import 'package:flutter_application_1/features/auth/register_form.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'loginPage.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            // Background image with gradient mask
            Animate(
              child: Image.asset(
                'lib/assets/images/RegisterImage.png',
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 1,
                fit: BoxFit.cover,
                color: AppTheme.primaryGold.withOpacity(0.1),
                colorBlendMode: BlendMode.lighten,
              ),
            ).custom(
              builder: (context, value, child) {
                return ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.pureBlack, Colors.transparent],
                    stops: const [0.1, 0.8],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: child,
                );
              },
            ),
            // Auth Card Container
            Container(
              margin: const EdgeInsets.fromLTRB(0, 100, 0, 0),
              color: Colors.transparent,
              child: Center(
                child: SingleChildScrollView(
                  child: AuthCard(
                    title: "Register",
                    form: RegisterForm(
                      formKey: formKey,
                      nameController: nameController,
                      emailController: emailController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                    ),
                    buttonText: "Create Account",
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final error = await authService.register(
                          emailController.text,
                          passwordController.text,
                          nameController.text,
                        );
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Registration failed: $error"),
                            ),
                          );
                        } else {
                          print('Register Successful');
                          // ✅ Pop back to LoginPage – the StreamBuilder in main.dart
                          // will automatically show DemoPage because the user is logged in.
                          if (context.mounted) Navigator.pop(context);
                        }
                      }
                    },
                    switchButton: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        "Already have an account? Login",
                        style: AppTheme.bodyText,
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
