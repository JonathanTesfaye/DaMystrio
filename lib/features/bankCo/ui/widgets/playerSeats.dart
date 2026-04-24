import 'package:flutter/material.dart';

class PlayerSeat extends StatelessWidget {
  final String playerName;
  final String balance;
  final String avatarPath; // optional image
  final double size;

  const PlayerSeat({
    super.key,
    required this.playerName,
    required this.balance,
    required this.avatarPath,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: size / 2, backgroundImage: AssetImage(avatarPath)),
        const SizedBox(height: 5),
        Text(
          playerName,
          style: const TextStyle(color: Colors.amber, fontSize: 12),
        ),
        Text(
          balance,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}
