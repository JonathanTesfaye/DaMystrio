import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/home/ui/widgets/gameModeButton.dart';
import 'package:flutter_application_1/features/mission/ui/dailyMission.dart';
import 'package:flutter_application_1/features/leaderboard/ui/leaderboardPage.dart';
import 'package:flutter_application_1/features/mission/ui/mission.dart';
import 'package:flutter_application_1/features/leaderboard/ui/Leaderboard.dart';

class BottomPanel extends StatelessWidget {
  final int selectedModeIndex; // 0 = BankCo, 1 = Injera, 2 = Pass & Play
  final ValueChanged<int> onModeSelected;

  const BottomPanel({
    super.key,
    required this.selectedModeIndex,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryGold.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Game Mode',
              style: AppTheme.headingMedium.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 10),
            GameModeButton(
              title: "BankCo Vs Bot",
              subtitle: "100 chip entry",
              icon: Icons.emoji_events,
              isSelected: selectedModeIndex == 0,
              onTap: () => onModeSelected(0),
            ),
            const SizedBox(height: 10),
            GameModeButton(
              title: "Injera be Wot",
              subtitle: "Coming Soon",
              icon: Icons.emoji_events,
              isComingSoon: true,
              isSelected: selectedModeIndex == 1,
              onTap: () => onModeSelected(1),
            ),
            const SizedBox(height: 10),
            GameModeButton(
              title: "BankCo Pass & Play",
              subtitle: "Local multiplayer",
              icon: Icons.people,
              isSelected: selectedModeIndex == 2,
              onTap: () => onModeSelected(2),
            ),
            const SizedBox(height: 10),
            Divider(
              color: AppTheme.primaryGold.withOpacity(0.5),
              thickness: 1.5,
              height: 0,
            ),
            const SizedBox(height: 10),
            Text(
              'Activities',
              style: AppTheme.headingMedium.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailyMissionPage()),
                );
              },
              child: const MissionCard(),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                );
              },
              child: const LeaderboardCard(),
            ),
          ],
        ),
      ),
    );
  }
}
