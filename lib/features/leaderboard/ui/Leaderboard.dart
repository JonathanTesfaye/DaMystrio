import 'package:flutter/material.dart';

class LeaderboardCard extends StatelessWidget {
  static const Color darkBlueBg = Color(0xFF0D1B2A);
  static const Color accentGold = Color(0xFFD4AF37);
  const LeaderboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: accentGold),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.leaderboard, color: accentGold),
          SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Daily Leaderboard",
                style: TextStyle(
                  color: accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "1st - Player123 (1,250,000)",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "2nd - Player456 (900,000)",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
