import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/custom_textFeild.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> formKey;

  const RegisterForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextfeild(
            hintText: 'Name',
            icon: Icons.person,
            controller: nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Name is required";
              }
              return null;
            },
          ),
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
          CustomTextfeild(
            hintText: "Confrim Password",
            icon: Icons.lock,
            controller: confirmPasswordController,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please confirm your password";
              }
              if (value != passwordController.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
