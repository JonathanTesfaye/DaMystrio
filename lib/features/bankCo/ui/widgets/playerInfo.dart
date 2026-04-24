import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlayerInfo extends StatelessWidget {
  final User? user;
  final VoidCallback onLogout;
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color darkBlueBg = Color(0xFF0D1B2A);

  const PlayerInfo({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
        border: Border(bottom: BorderSide(color: accentGold, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: accentGold,
                child: Icon(Icons.person, color: Colors.black),
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.displayName ?? "Player Name",
                style: TextStyle(
                  color: accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.email ?? "Email.com",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                "Chips:  1,250,000",
                style: TextStyle(
                  color: accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(width: 15),
          IconButton(
            onPressed: onLogout,
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
