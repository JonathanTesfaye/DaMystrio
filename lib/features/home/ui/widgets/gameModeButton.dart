import 'package:flutter/material.dart';

class GameModeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const GameModeButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
