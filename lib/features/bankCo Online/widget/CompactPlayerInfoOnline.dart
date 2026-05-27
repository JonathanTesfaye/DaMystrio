import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo%20Online/logic/OnlineMatchState.dart';

class CompactPlayerInfo extends StatelessWidget {
  final OnlinePlayer? player;
  final int? seatIndex;
  final bool isCurrentTurn;
  final bool isReady;
  final void Function(String rank, String suit)? onCardTap;

  const CompactPlayerInfo({
    super.key,
    this.player,
    this.seatIndex,
    required this.isCurrentTurn,
    this.isReady = false,
    this.onCardTap,
  });

  String _getAvatarPath(int index) {
    switch (index) {
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
    // Placeholder (no player)
    if (player == null) {
      final seatIdx = seatIndex ?? 0;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isCurrentTurn
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryGold.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: ClipOval(
              child: Container(
                width: 70,
                height: 70,
                color: AppTheme.surface.withOpacity(0.5),
                child: Image.asset(
                  _getAvatarPath(seatIdx),
                  fit: BoxFit.cover,
                  color: Colors.grey,
                  colorBlendMode: BlendMode.saturation,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.person_outline, color: Colors.grey, size: 35),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.pureBlack.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Waiting...",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      );
    }

    // Real player
    final avatar = Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
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
                _getAvatarPath(player!.seatIndex),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person, color: AppTheme.primaryGold, size: 35),
              ),
            ),
          ),
        ),
        if (player!.balance <= 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "ELIMINATED",
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        if (isReady)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
          ),
      ],
    );

    // Info column with constrained width and tooltip for long names
    final info = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.pureBlack.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: player!.name,
              child: Text(
                player!.name,
                style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "Chips: ${player!.balance}",
              style: AppTheme.captionGold.copyWith(fontSize: 12),
            ),
            Text(
              "Bait: ${player!.bet}",
              style: AppTheme.bodyText.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [avatar, const SizedBox(height: 6), info],
    );
  }
}
