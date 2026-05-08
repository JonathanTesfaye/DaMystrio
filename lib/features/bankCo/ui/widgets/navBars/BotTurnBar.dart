import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';

class AITurnBar extends StatelessWidget {
  const AITurnBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          "AI thinking...",
          style: AppTheme.captionGold.copyWith(fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}
