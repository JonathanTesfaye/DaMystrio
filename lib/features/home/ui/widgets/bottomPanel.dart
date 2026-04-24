import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/leaderboard/ui/Leaderboard.dart';
import 'package:flutter_application_1/features/home/ui/widgets/gameModeButton.dart';
import 'package:flutter_application_1/features/mission/ui/mission.dart';
import 'package:flutter_application_1/features/mission/ui/dailyMission.dart';
import 'package:flutter_application_1/features/leaderboard/ui/leaderboardPage.dart';

class BottomPanel extends StatelessWidget {
  static const Color darkBlueBg = Color(0xFF0D1B2A);
  static const Color accentGold = Color(0xFFD4AF37);

  const BottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkBlueBg.withOpacity(0.5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Game Mode',
              style: TextStyle(
                color: accentGold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            GameModeButton(
              title: "Unranked",
              subtitle: "no bets",
              icon: Icons.emoji_events,
            ),
            SizedBox(height: 10),
            GameModeButton(
              title: "Tournaments",
              subtitle: "2 Active",
              icon: Icons.emoji_events,
            ),
            SizedBox(height: 10),
            GameModeButton(
              title: "Special Events",
              subtitle: "Club Heritage",
              icon: Icons.event,
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: BoxBorder.all(color: accentGold, width: 2),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DailyMissionPage()),
                );
              },
              child: MissionCard(),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LeaderboardPage()),
                );
              },
              child: LeaderboardCard(),
            ),
          ],
        ),
      ),
    );
  }
}
