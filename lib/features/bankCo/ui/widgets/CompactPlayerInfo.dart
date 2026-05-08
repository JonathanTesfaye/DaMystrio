import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo/logic/da_bank_co_state.dart';

class CompactPlayerInfo extends StatelessWidget {
  final DaBankCoPlayer player;
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
      case 4:
        return 'assets/images/avatar2.png';
      default:
        return 'assets/images/avatar1.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isHuman = !player.isAI;
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: isHuman
          ? [info, const SizedBox(height: 6), avatar]
          : [avatar, const SizedBox(height: 6), info],
    );
  }
}
