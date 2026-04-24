import 'package:flutter/material.dart';

class MissionCard extends StatelessWidget {
  static const Color darkBlueBg = Color(0xFF0D1B2A);
  static const Color accentGold = Color(0xFFD4AF37);

  const MissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: accentGold),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle, color: accentGold),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Daily Mission: Complete your profile (+2500)",
              style: TextStyle(color: accentGold, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
