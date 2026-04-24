import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/gameBackground.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/playerSeats.dart';

class TablePlayer {
  final String name;
  final String balance;
  final String avatar;
  final Alignment alignment;
  TablePlayer({
    required this.name,
    required this.balance,
    required this.avatar,
    required this.alignment,
  });
}

class GameTable extends StatelessWidget {
  final double height;
  final double width;

  GameTable({super.key, required this.height, required this.width});

  final List<TablePlayer> players = [
    TablePlayer(
      name: 'Player 1',
      balance: '1000',
      avatar: 'lib/assets/images/avatar1.png',
      alignment: Alignment(0.6, -0.47),
    ),
    TablePlayer(
      name: 'Player 2',
      balance: '1500',
      avatar: 'lib/assets/images/avatar2.png',
      alignment: Alignment((0), -0.82),
    ),
    TablePlayer(
      name: 'Player 3',
      balance: '2000',
      avatar: 'lib/assets/images/avatar3.png',
      alignment: Alignment(-0.58, 0.6),
    ),
    TablePlayer(
      name: 'Player 4',
      balance: '2500',
      avatar: 'lib/assets/images/avatar4.png',
      alignment: Alignment(0.585, 0.6),
    ),
    TablePlayer(
      name: 'Player 5',
      balance: '3000',
      avatar: 'lib/assets/images/avatar4.png',
      alignment: Alignment(-0.58, -0.45),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      child: Stack(
        children: [
          Positioned(
            top: height * 0.05,
            left: -100,
            right: -100,
            child: Center(
              child: SizedBox(
                width: width * 2,
                height: height * 1,
                child: Stack(
                  children: [
                    // Table
                    Center(
                      child: Image.asset(
                        'lib/assets/images/PlayerTable.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Player Seats
                    ...players.map((players) {
                      return Align(
                        alignment: players.alignment,
                        child: PlayerSeat(
                          playerName: players.name,
                          balance: players.balance,
                          avatarPath: players.avatar,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
