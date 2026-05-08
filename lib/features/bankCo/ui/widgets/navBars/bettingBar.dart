import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';

class BettingBar extends StatelessWidget {
  final int humanBalance;
  final List<int> betValues;
  final void Function(int amount) onBetSelected;
  final VoidCallback onBeginRound;

  const BettingBar({
    super.key,
    required this.humanBalance,
    required this.betValues,
    required this.onBetSelected,
    required this.onBeginRound,
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
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PopupMenuButton<int>(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Bet",
                style: AppTheme.buttonText.copyWith(color: AppTheme.offWhite),
              ),
            ),
            onSelected: onBetSelected,
            itemBuilder: (context) => [
              ...betValues.map(
                (v) => PopupMenuItem(
                  value: v,
                  child: Text("$v chips", style: AppTheme.bodyText),
                ),
              ),
              PopupMenuItem(
                value: humanBalance,
                child: Text("Max ($humanBalance)", style: AppTheme.bodyText),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onBeginRound,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: AppTheme.pureBlack,
            ),
            child: const Text("Begin Round"),
          ),
        ],
      ),
    );
  }
}
