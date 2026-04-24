import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/custom_textFeild.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextfeild(
            hintText: 'Email',
            icon: Icons.email,
            controller: emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email is required";
              }
              return null;
            },
          ),
          CustomTextfeild(
            hintText: 'Password',
            icon: Icons.lock,
            controller: passwordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password is required";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
