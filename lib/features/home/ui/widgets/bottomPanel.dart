import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/home/ui/widgets/gameModeButton.dart';
import 'package:flutter_application_1/features/mission/ui/dailyMission.dart';
import 'package:flutter_application_1/features/leaderboard/ui/leaderboardPage.dart';
import 'package:flutter_application_1/features/mission/ui/mission.dart';
import 'package:flutter_application_1/features/leaderboard/ui/Leaderboard.dart';

class BottomPanel extends StatefulWidget {
  const BottomPanel({super.key});

  @override
  State<BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<BottomPanel> {
  int _selectedModeIndex = 0; // 0 = BankCo, 1 = Injera be Wot (coming soon)

  void _onModeTap(int index) {
    if (index == 1) return; // coming soon – no action
    setState(() {
      _selectedModeIndex = index;
    });
    // Optional: navigate or trigger game start for BankCo
    if (index == 0) {
      // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => PokerPage2()));
      print("BankCo selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
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
              title: "BankCo",
              subtitle: "100 chip entry",
              icon: Icons.emoji_events,
              isSelected: _selectedModeIndex == 0,
              onTap: () => _onModeTap(0),
            ),
            const SizedBox(height: 10),
            GameModeButton(
              title: "Injera be Wot",
              subtitle: "Coming Soon",
              icon: Icons.emoji_events,
              isComingSoon: true,
              isSelected: false,
              onTap: null,
            ),
            const SizedBox(height: 10),
            Divider(
              color: AppTheme.primaryGold.withOpacity(0.5),
              thickness: 1.5,
              height: 0,
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
