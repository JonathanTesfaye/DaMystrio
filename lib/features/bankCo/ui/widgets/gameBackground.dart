import 'package:flutter/material.dart';

class GameBackground extends StatelessWidget {
  final Widget child;
  const GameBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'lib/assets/images/Background.png',
            fit: BoxFit.fitWidth,

            repeat: ImageRepeat.repeat,
          ),
        ),
        child,
      ],
    );
  }
}
