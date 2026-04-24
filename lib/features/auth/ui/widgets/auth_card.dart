import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final String title;
  final Widget form;
  final String buttonText;
  final VoidCallback onPressed;
  final Widget switchButton;
  static const Color darkBlueBg = Color(0xFF0D1B2A);
  static const Color accentGold = Color(0xFFD4AF37);

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
      color: darkBlueBg.withOpacity(0.9),
      elevation: 6,
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              title,
              style: TextStyle(
                wordSpacing: 0,
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            // Form
            form,
            SizedBox(height: 20),
            // Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGold,
                textStyle: TextStyle(color: Colors.white),
              ),
              onPressed: onPressed,
              child: Text(buttonText),
            ),
            SizedBox(height: 20),
            // Switch Button
            switchButton,
          ],
        ),
      ),
    );
  }
}
