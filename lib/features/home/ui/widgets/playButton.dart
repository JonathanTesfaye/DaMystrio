import 'package:flutter/material.dart';

class PlayButton extends StatelessWidget {
  final VoidCallback onPressed;
  static const Color darkBlueBg = Color(0xFF0D1B2A);

  const PlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 10,
        backgroundColor: darkBlueBg,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: const Text(
        "PLAY NOW",
        style: TextStyle(
          color: Colors.amber,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}
