import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';

class AuthCard extends StatelessWidget {
  final String title;
  final Widget form;
  final String buttonText;
  final VoidCallback onPressed;
  final Widget switchButton;

  const AuthCard({
    super.key,
    required this.title,
    required this.form,
    required this.buttonText,
    required this.onPressed,
    required this.switchButton,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surface.withOpacity(
        0.7,
      ), // ✅ semi‑transparent dark surface
      elevation: 6,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(title, style: AppTheme.headingLarge.copyWith(fontSize: 30)),
            form,
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: AppTheme.pureBlack,
                textStyle: AppTheme.buttonText,
              ),
              onPressed: onPressed,
              child: Text(buttonText),
            ),
            const SizedBox(height: 20),
            switchButton,
          ],
        ),
      ),
    );
  }
}
