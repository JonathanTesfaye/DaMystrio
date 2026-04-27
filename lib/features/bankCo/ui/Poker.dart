import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/gameState.dart';
import 'package:flutter_application_1/features/bankCo/logic/models/playerModel.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/features/bankCo/logic/gameController.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/gameBackground.dart';
import 'package:flutter_application_1/core/models/cardModel.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/cardWidget.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/playerSeats.dart';

class PokerPage extends StatefulWidget {
  const PokerPage({super.key});

  @override
  State<PokerPage> createState() => _PokerPageState();
}

class _PokerPageState extends State<PokerPage> {
  final List<int?> betOptions = [50, 100, 200, 500, null];

  int? selectedBet;

  Offset dealerStart = const Offset(0, -2);

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final controller = context.read<GameController>();

      controller.init([
        PlayerModel(name: "You", avatar: "avatar", chips: 1000, currentBet: 50),
      ]);

      controller.startRound(); // 🔥 THIS is what starts everything
    });
  }

  // ================= SIZE HELPERS =================
  double get height => MediaQuery.of(context).size.height;
  double get width => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    final player = controller.state.players.isNotEmpty
        ? controller.state.players[controller.state.currentPlayerIndex]
        : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 10,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              mini: true,
              backgroundColor: Colors.blueGrey.withOpacity(0.7),
              child: const Icon(Icons.arrow_back, color: Colors.amber),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              "Chips: ${player?.chips ?? 0}",
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: SizedBox.expand(
        child: GameBackground(
          child: Stack(
            children: [
              // ================= TABLE =================
              Positioned(
                top: height * 0.05,
                left: -100,
                right: -100,
                child: Center(
                  child: SizedBox(
                    width: width * 2,
                    height: height,
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            'lib/assets/images/Game Background 2.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        // ===== PLAYERS =====
                        const Align(
                          alignment: Alignment(-0.6, -0.47),
                          child: PlayerSeat(
                            playerName: "Liu Che",
                            balance: "1,250,000",
                            avatarPath: 'assets/images/avatar1.png',
                          ),
                        ),
                        const Align(
                          alignment: Alignment(0.6, -0.47),
                          child: PlayerSeat(
                            playerName: "Scipio",
                            balance: "1,000,000",
                            avatarPath: 'assets/images/avatar2.png',
                          ),
                        ),
                        const Align(
                          alignment: Alignment(0, -0.82),
                          child: PlayerSeat(
                            playerName: "Arthur",
                            balance: "900,000",
                            avatarPath: 'assets/images/avatar3.png',
                          ),
                        ),
                        const Align(
                          alignment: Alignment(-0.58, 0.6),
                          child: PlayerSeat(
                            playerName: "QSH",
                            balance: "2,000,000",
                            avatarPath: 'assets/images/avatar2.png',
                          ),
                        ),
                        const Align(
                          alignment: Alignment(0.585, 0.6),
                          child: PlayerSeat(
                            playerName: "STP",
                            balance: "1,500,000",
                            avatarPath: 'assets/images/avatar2.png',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= PLAYER CARDS =================
              Positioned(
                top: height * 0.2,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    SizedBox(
                      width: width,
                      height: height * 0.4,
                      child: Stack(
                        children: player == null
                            ? []
                            : player.cards.asMap().entries.map((entry) {
                                final index = entry.key;
                                final card = entry.value;

                                final isDealt = controller.state.dealCards;
                                final isReveal =
                                    controller.state.phase ==
                                        GamePhase.reveal ||
                                    controller.state.phase == GamePhase.result;

                                return AnimatedPositioned(
                                  duration: const Duration(milliseconds: 500),
                                  top: isDealt ? height * 0.15 : height * 2,
                                  left: isDealt
                                      ? (width / 2 - 50) + (index * 50)
                                      : (width / -20),
                                  curve: Curves.easeOut,
                                  child: AnimatedOpacity(
                                    opacity: isDealt ? 1 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: CardWidget(
                                      key: ValueKey(
                                        '${card.value}-${card.suit}-$index',
                                      ),
                                      card: card,
                                      isFaceUp: isReveal,
                                    ),
                                  ),
                                );
                              }).toList(),
                      ),
                    ),

                    // ================= THIRD CARD =================
                    if (controller.thirdCard != null)
                      AnimatedSlide(
                        offset: controller.state.showThirdCard
                            ? const Offset(0, -1)
                            : const Offset(0, 2),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        child: CardWidget(
                          key: ValueKey(
                            '${controller.thirdCard!.value}-${controller.thirdCard!.suit}',
                          ),
                          card: controller.thirdCard!,
                          isFaceUp:
                              controller.state.phase == GamePhase.reveal ||
                              controller.state.phase == GamePhase.result,
                        ),
                      ),

                    // ================= RESULT =================
                    Text(
                      controller.state.message,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ================= ACTION BUTTONS =================
              if (controller.state.phase == GamePhase.decision)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 10,
                        children: betOptions.map((bet) {
                          final value =
                              bet ??
                              controller
                                  .state
                                  .players[controller.state.currentPlayerIndex]
                                  .chips;

                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedBet = value;
                              });
                            },
                            child: Text(bet == null ? "Max" : "$bet"),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: controller.takeThirdCard,
                        child: const Text("Take"),
                      ),
                      ElevatedButton(
                        onPressed: controller.pass,
                        child: const Text("Pass"),
                      ),
                      ElevatedButton(
                        onPressed: () => controller.forLess(selectedBet ?? 50),
                        child: const Text("Less"),
                      ),
                    ],
                  ),
                ),

              // ================= NEXT ROUND =================
              if (controller.state.phase == GamePhase.result)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: ElevatedButton(
                    onPressed: controller.beginRound,
                    child: const Text("Play Again"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
