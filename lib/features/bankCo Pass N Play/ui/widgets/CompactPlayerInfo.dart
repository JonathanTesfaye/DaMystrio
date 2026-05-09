import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/logic/da_bank_co_PnP_state.dart';

class CompactPlayerInfo extends StatelessWidget {
  final PnPPlayer player;
  final bool isCurrentTurn;

  const CompactPlayerInfo({
    super.key,
    required this.player,
    required this.isCurrentTurn,
  });

  String _getAvatarPath() {
    switch (player.seatIndex) {
      case 0:
        return 'assets/images/avatar1.png';
      case 1:
        return 'assets/images/avatar2.png';
      case 2:
        return 'assets/images/avatar3.png';
      case 3:
        return 'assets/images/avatar2.png';
      default:
        return 'assets/images/avatar1.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.8),
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: ClipOval(
        child: Container(
          width: 70,
          height: 70,
          color: AppTheme.surface,
          child: Image.asset(
            _getAvatarPath(),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, color: AppTheme.primaryGold, size: 35);
            },
          ),
        ),
      ),
    );
    final info = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.pureBlack.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            player.name,
            style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            "Chips: ${player.balance}",
            style: AppTheme.captionGold.copyWith(fontSize: 12),
          ),
          Text(
            "Bait: ${player.bet}",
            style: AppTheme.bodyText.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
    // For pass-and-play, we don't have AI vs human distinction, always show info below avatar?
    // Original had isHuman logic, but here all are human, so we can just show info below avatar.
    // But to match layout, we'll put info below avatar for all.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [avatar, const SizedBox(height: 6), info],
    );
  }
}
