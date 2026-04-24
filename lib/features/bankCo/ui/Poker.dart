import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/gameBackground.dart';
import 'package:flutter_application_1/core/models/cardModel.dart';
import 'package:flutter_application_1/core/models/gameState.dart';
import 'package:flutter_application_1/core/services/gameServices.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/cardWidget.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/playerSeats.dart';

class PokerPage extends StatefulWidget {
  PokerPage({super.key});

  @override
  State<PokerPage> createState() => _PokerPageState();
}

class _PokerPageState extends State<PokerPage> {
  final GameService gameService = GameService();
  final List<int?> betOptions = [50, 100, 200, 500, null];

  late GameState gameState;

  bool dealFirst = false;
  bool dealSecond = false;
  bool dropThirdCard = false;
  bool revealSecond = false;
  bool revealFirst = false;
  bool canBet(int bet) {
    return bet <= gameState.playerChips;
  }

  int? selectedBet;

  Offset dealerStart = Offset(0, -2);

  @override
  void initState() {
    super.initState();
    gameService.initializeDeck();
    gameState = GameState(
      playerCards: gameService.dealTwoCards(),
      phase: GamePhase.dealing,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 1800), () {
        setState(() {
          gameState = gameState.copyWith(phase: GamePhase.decision);
        });
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          dealFirst = true;
        });
      });
      Future.delayed(Duration(milliseconds: 800), () {
        setState(() {
          revealFirst = true;
        });
      });

      Future.delayed(Duration(milliseconds: 900), () {
        setState(() {
          dealSecond = true;
        });
      });

      Future.delayed(Duration(milliseconds: 1800), () {
        setState(() {
          revealSecond = true;
        });
      });
    });
  }

  // Third Card Animation logic
  void takeThirdCard() {
    final third = gameService.drawThirdCard();

    setState(() {
      gameState = gameState.copyWith(thirdCard: third, phase: GamePhase.reveal);
      dropThirdCard = false;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        dropThirdCard = true;
      });
    });
    Future.delayed(Duration(milliseconds: 600), () {
      bool win = gameService.isWin(
        gameState.playerCards[0],
        gameState.playerCards[1],
        third,
      );
      int newChips = gameState.playerChips;

      if (win) {
        newChips += gameState.currentBet;
      } else {
        newChips -= gameState.currentBet;
      }

      setState(() {
        gameState = gameState.copyWith(
          phase: GamePhase.result,
          result: newChips <= 0
              ? "Game Over"
              : (win ? "You Win!" : "You Lose!"),
          playerChips: newChips < 0 ? 0 : newChips,
        );
      });
    });
  }

  // Pass Turn
  void passRound() {
    setState(() {
      gameState = gameState.copyWith(
        phase: GamePhase.result,
        result: "You Passed",
        thirdCard: null,
      );
      dropThirdCard = false;
    });
  }

  // Half your Bet
  void playForLess() {
    setState(() {
      gameState = gameState.copyWith(
        currentBet: (gameState.currentBet / 2).toInt(),
      );
    });
    takeThirdCard();
  }

  // Logic to allow to play again
  void resetRound() {
    gameService.initializeDeck();
    setState(() {
      gameState = gameState.copyWith(
        playerCards: gameService.dealTwoCards(),
        thirdCard: null,
        phase: GamePhase.dealing,
        result: "",
        currentBet: gameState.playerChips >= 100 ? 100 : gameState.playerChips,
      );
      selectedBet = null;
      dealFirst = false;
      dealSecond = false;
      revealFirst = false;
      revealSecond = false;
      dropThirdCard = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          dealFirst = true;
        });
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          revealFirst = true;
        });
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        setState(() {
          dealSecond = true;
        });
      });
      Future.delayed(const Duration(milliseconds: 1400), () {
        setState(() {
          revealSecond = true;
        });
      });
      Future.delayed(const Duration(milliseconds: 1800), () {
        setState(() {
          gameState = gameState.copyWith(phase: GamePhase.decision);
        });
      });
    });
  }

  double get height => MediaQuery.of(context).size.height;
  double get width => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              "Chips:${gameState.playerChips}",
              style: TextStyle(
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
              // Table + Seats
              Positioned(
                top: height * 0.05,
                left: -100,
                right: -100,
                child: Center(
                  child: Container(
                    width: width * 2,
                    height: height * 1,
                    child: Stack(
                      children: [
                        // Playing table
                        Center(
                          child: Image.asset(
                            'lib/assets/images/Game Background 2.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        //Player seats around table
                        // Left top player
                        Align(
                          alignment: Alignment(-0.6, -0.47),
                          child: const PlayerSeat(
                            playerName: "Liu Che",
                            balance: "1,250,000",
                            avatarPath: 'assets/images/avatar1.png',
                          ),
                        ),

                        // Right top player
                        Align(
                          alignment: Alignment(0.6, -0.47),
                          child: PlayerSeat(
                            playerName: "Scipio",
                            balance: "1,000,000",
                            avatarPath: 'assets/images/avatar2.png',
                          ),
                        ),

                        // Top player
                        Align(
                          alignment: Alignment(0, -0.82),
                          child: PlayerSeat(
                            playerName: "Arthur",
                            balance: "900,000",
                            avatarPath: 'assets/images/avatar3.png',
                          ),
                        ),

                        // Left bottom Person
                        Align(
                          alignment: Alignment(-0.58, 0.6),
                          child: PlayerSeat(
                            playerName: "QSH",
                            balance: "2,000,000",
                            avatarPath: 'assets/images/avatar2.png',
                          ),
                        ),

                        //Right Person 2
                        Align(
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

              // playing cards (2 cards)
              Positioned(
                top: height * 0.2,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width,
                      height: height * 0.4,
                      child: Stack(
                        children: gameState.playerCards.asMap().entries.map((
                          entry,
                        ) {
                          int index = entry.key;
                          CardModel card = entry.value;

                          bool isDealt = index == 0 ? dealFirst : dealSecond;
                          bool isReveal = index == 0
                              ? revealFirst
                              : revealSecond;

                          return AnimatedPositioned(
                            top: isDealt ? height * 0.15 : height * 2,
                            left: isDealt
                                ? (width / 2 - 50) + (index * 50)
                                : (width / -20),

                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            child: AnimatedOpacity(
                              opacity: isDealt ? 1 : 0,
                              duration: Duration(milliseconds: 300),
                              child: isDealt
                                  ? CardWidget(
                                      key: ValueKey(
                                        '${card.value}-${card.suit}-$index',
                                      ),
                                      card: card,
                                      isFaceUp: isReveal,
                                    )
                                  : SizedBox(width: 40, height: 60),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // THIRD CARD
                    if (gameState.thirdCard != null)
                      AnimatedSlide(
                        offset: dropThirdCard ? Offset(0, -1) : Offset(0, 2),
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        child: CardWidget(
                          key: ValueKey(
                            '${gameState.thirdCard!.value}-${gameState.thirdCard!.suit}-third',
                          ),
                          card: gameState.thirdCard!,
                          isFaceUp:
                              gameState.phase == GamePhase.reveal ||
                              gameState.phase == GamePhase.result,
                        ),
                      ),

                    // RESULT
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.rectangle,
                      ),
                      child: Text(
                        gameState.result,
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Game Action Buttons
              if (gameState.phase == GamePhase.decision)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // bet options
                      Wrap(
                        spacing: 10,
                        children: betOptions.map((bet) {
                          final isMax = bet == null;
                          final betValue = isMax ? gameState.playerChips : bet;
                          final isEnabled = betValue <= gameState.playerChips;
                          final isSelected = selectedBet == betValue;
                          return ElevatedButton(
                            onPressed: isEnabled
                                ? () {
                                    setState(() {
                                      selectedBet = betValue;
                                      gameState = gameState.copyWith(
                                        currentBet: betValue,
                                      );
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.green
                                  : isEnabled
                                  ? (isMax ? Colors.blue[900] : Colors.blue)
                                  : Colors.grey,
                              foregroundColor: isSelected
                                  ? Colors.black
                                  : Colors.amber,
                              side: isSelected
                                  ? BorderSide(color: Colors.yellow, width: 2)
                                  : null,
                            ),
                            child: Text(
                              isMax ? "Max" : "$betValue",
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      // Take third card
                      ElevatedButton(
                        onPressed: takeThirdCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Take",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Pass third card
                      ElevatedButton(
                        onPressed: passRound,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Pass",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Play for less
                      ElevatedButton(
                        onPressed: playForLess,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Less",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Reset Round
              if (gameState.phase == GamePhase.result &&
                  gameState.playerChips > 0)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: resetRound,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Play again",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Game Over - Reset Button
              if (gameState.phase == GamePhase.result &&
                  gameState.playerChips <= 0)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        "No Chips Left!",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            gameState = GameState(
                              playerCards: gameService.dealTwoCards(),
                              phase: GamePhase.dealing,
                              playerChips: 1000,
                            );
                            selectedBet = null;

                            // reset animations
                            dealFirst = false;
                            dealSecond = false;
                            revealFirst = false;
                            revealSecond = false;
                            dropThirdCard = false;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                setState(() => dealFirst = true);
                              },
                            );

                            Future.delayed(
                              const Duration(milliseconds: 800),
                              () {
                                setState(() => revealFirst = true);
                              },
                            );

                            Future.delayed(
                              const Duration(milliseconds: 900),
                              () {
                                setState(() => dealSecond = true);
                              },
                            );

                            Future.delayed(
                              const Duration(milliseconds: 1400),
                              () {
                                setState(() => revealSecond = true);
                              },
                            );

                            Future.delayed(
                              const Duration(milliseconds: 1800),
                              () {
                                setState(() {
                                  gameState = gameState.copyWith(
                                    phase: GamePhase.decision,
                                  );
                                });
                              },
                            );
                          });
                        },
                        child: Text("Restart Game"),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
