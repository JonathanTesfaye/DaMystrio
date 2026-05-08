import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';

class HumanTurnBar extends StatelessWidget {
  final VoidCallback onBankCo;
  final VoidCallback onForLess;
  final VoidCallback onPass;

  const HumanTurnBar({
    super.key,
    required this.onBankCo,
    required this.onForLess,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.pureBlack.withOpacity(0.85),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: AppTheme.primaryGold.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navButton("Bank Co", AppTheme.emeraldGreen, onBankCo),
          _navButton("For Less", AppTheme.highlightGold, onForLess),
          _navButton("Pass", AppTheme.lose, onPass),
        ],
      ),
    );
  }

  Widget _navButton(String label, Color bgColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: AppTheme.pureBlack,
        textStyle: AppTheme.buttonText.copyWith(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(label),
    );
  }
}
