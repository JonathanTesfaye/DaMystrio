import 'package:flutter/material.dart';
import '../../core/theme/appTheme.dart';

class CustomTextfeild extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextfeild({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        style: AppTheme.bodyText, // ✅ use themed text color
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.primaryGold), // ✅ gold icon
          hintText: hintText,
          hintStyle: AppTheme.bodyText.copyWith(
            color: AppTheme.offWhite.withOpacity(0.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // ✅ consistent radius
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.primaryGold.withOpacity(0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryGold, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.surface,
        ),
      ),
    );
  }
}
