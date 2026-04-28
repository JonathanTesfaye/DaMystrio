import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';

class PlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 10,
        // Use theme's primary gold as background
        backgroundColor: AppTheme.primaryGold,
        // Text color will be onPrimary (black) automatically from theme,
        // but we can force it for safety
        foregroundColor: AppTheme.pureBlack,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Optional: add a subtle gold gradient
        shadowColor: AppTheme.primaryGold.withOpacity(0.4),
      ),
      onPressed: onPressed,
      child: Text(
        "PLAY NOW",
        style: AppTheme.buttonText.copyWith(
          fontSize: 24, // preserve larger size
          letterSpacing: 2,
        ),
      ),
    );
  }
}
