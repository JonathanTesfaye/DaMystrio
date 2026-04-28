import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  final List<Map<String, dynamic>> _players = const [
    {'rank': 1, 'name': 'Arthur', 'chips': 1250000},
    {'rank': 2, 'name': 'Liu Che', 'chips': 980000},
    {'rank': 3, 'name': 'Scipio', 'chips': 875000},
    {'rank': 4, 'name': 'Jonathan', 'chips': 650000},
    {'rank': 5, 'name': 'Makeda', 'chips': 510000},
    {'rank': 6, 'name': 'Zewditu', 'chips': 430000},
    {'rank': 7, 'name': 'Tewodros', 'chips': 290000},
    {'rank': 8, 'name': 'Haile', 'chips': 175000},
    {'rank': 9, 'name': 'Yodit', 'chips': 95000},
    {'rank': 10, 'name': 'Eleni', 'chips': 42000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.richBlack,
      appBar: AppBar(
        title: Text('Leaderboard', style: AppTheme.headingMedium),
        centerTitle: true,
        backgroundColor: AppTheme.pureBlack,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.primaryGold,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: _players.length,
          itemBuilder: (context, index) {
            final player = _players[index];
            final rank = player['rank'] as int;
            final isTop3 = rank <= 3;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isTop3
                      ? AppTheme.primaryGold
                      : AppTheme.primaryGold.withOpacity(0.3),
                  width: isTop3 ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                leading: SizedBox(width: 60, child: _buildRankIcon(rank)),
                title: Text(
                  player['name'],
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: AppTheme.primaryGold,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${player['chips']}',
                      style: AppTheme.captionGold.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRankIcon(int rank) {
    if (rank == 1) {
      return Row(
        children: [
          Icon(Icons.emoji_events, color: AppTheme.primaryGold, size: 28),
          const SizedBox(width: 8),
          Text(
            '#1',
            style: AppTheme.captionGold.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (rank == 2) {
      return Row(
        children: [
          Icon(Icons.emoji_events, color: AppTheme.highlightGold, size: 24),
          const SizedBox(width: 8),
          Text('#2', style: AppTheme.bodyText.copyWith(fontSize: 16)),
        ],
      );
    } else if (rank == 3) {
      return Row(
        children: [
          Icon(Icons.emoji_events, color: AppTheme.emeraldGreen, size: 22),
          const SizedBox(width: 8),
          Text('#3', style: AppTheme.bodyText.copyWith(fontSize: 16)),
        ],
      );
    } else {
      return Row(
        children: [
          const SizedBox(width: 12),
          Text('#$rank', style: AppTheme.bodyText.copyWith(fontSize: 16)),
        ],
      );
    }
  }
}
