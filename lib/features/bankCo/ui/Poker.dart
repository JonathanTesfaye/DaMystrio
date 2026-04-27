// ===================== LOGIC SECTION =====================

import 'dart:math';
import 'package:flutter/material.dart';

/// Represents a playing card (only rank + suit, value 2..14)
class CardData {
  final String rank; // "2","3",...,"10","J","Q","K","A"
  final int value; // 2..14
  final String suit; // "♠","♥","♦","♣"

  CardData(this.rank, this.value, this.suit);
}

/// Represents a player (human or AI)
class Player {
  final String name;
  int balance;
  int bet;
  List<CardData> cards;
  String state; // "idle", "turn", "passed", "won", "lost", "broke"
  final bool isAI;

  Player({
    required this.name,
    required this.isAI,
    this.balance = 1000,
    this.bet = 0,
    this.cards = const [],
    this.state = "idle",
  });
}

/// Pure game logic engine (no Flutter UI)
class DaBankCoGame {
  int pot = 0;
  int roundContribution = 100;
  List<Player> players = [];
  String phase = "setup"; // "betting", "round"
  int turnIndex = 0;
  int humanIndex = 3;
  String lastMessage = "Start a new game.";

  final Random _random = Random();
  final VoidCallback onStateChanged; // called after every state mutation

  DaBankCoGame({required this.onStateChanged});

  // ------------------- Public API -------------------
  void startNewGame({int startingPot = 0, int? customRoundContribution}) {
    if (customRoundContribution != null)
      roundContribution = customRoundContribution;
    pot = startingPot;
    players = [
      Player(name: "AI King 1", isAI: true),
      Player(name: "AI King 2", isAI: true),
      Player(name: "AI King 3", isAI: true),
      Player(name: "You", isAI: false),
    ];
    humanIndex = 3;
    phase = "betting";
    turnIndex = 0;
    _applyRoundContribution();
    _autoBetAIPlayers();
    _setMessage("New game started. Place your bet, then press Begin Round.");
    onStateChanged();
  }

  void placeHumanBet(int amount) {
    if (phase != "betting") {
      _setMessage("Betting is closed right now.");
      return;
    }
    final human = players[humanIndex];
    if (human.balance <= 0) {
      _setMessage("You have no chips left.");
      return;
    }
    if (amount <= 0) {
      _setMessage("Enter a valid bet.");
      return;
    }
    if (amount > human.balance) {
      _setMessage("You do not have enough chips.");
      return;
    }
    human.bet = amount;
    _setMessage("Your bet is in. Press Begin Round.");
    onStateChanged();
  }

  void finishBettingAndBegin() {
    if (phase != "betting") {
      _setMessage("The round is already in progress.");
      return;
    }
    final human = players[humanIndex];
    if (human.balance > 0 && human.bet == 0) {
      _setMessage("Place your bet first.");
      return;
    }
    phase = "round";
    turnIndex = 0;
    _resetHandsForRound();
    _startTurn();
  }

  void bankCo() {
    final player = players[turnIndex];
    if (phase != "round" || player.isAI) return;
    _resolvePlay(pot, "bankco");
  }

  void forLess(int amount) {
    final player = players[turnIndex];
    if (phase != "round" || player.isAI) return;
    if (amount <= 0) {
      _setMessage("Enter a valid For Less amount.");
      return;
    }
    _resolvePlay(amount, "less");
  }

  void passTurn() {
    final player = players[turnIndex];
    if (phase != "round" || player.isAI) return;
    player.state = "passed";
    _setMessage("You passed.");
    onStateChanged();
    Future.delayed(const Duration(milliseconds: 1000), () {
      player.cards = [];
      turnIndex++;
      _startTurn();
    });
  }

  // ------------------- Internal Logic -------------------
  CardData _drawCard() {
    const suits = ["♠", "♥", "♦", "♣"];
    const ranks = [
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "10",
      "J",
      "Q",
      "K",
      "A",
    ];
    const values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
    int idx = _random.nextInt(ranks.length);
    return CardData(
      ranks[idx],
      values[idx],
      suits[_random.nextInt(suits.length)],
    );
  }

  void _applyRoundContribution() {
    for (var p in players) {
      int amount = min(roundContribution, p.balance);
      p.balance -= amount;
      pot += amount;
      if (amount < roundContribution) p.state = "lost";
    }
  }

  void _autoBetAIPlayers() {
    for (int i = 0; i < 3; i++) {
      var ai = players[i];
      if (ai.balance <= 0) {
        ai.bet = 0;
        ai.state = "broke";
        continue;
      }
      int minBet = 25;
      int maxBet = min(150, ai.balance);
      ai.bet = minBet + _random.nextInt(maxBet - minBet + 1);
    }
    onStateChanged();
  }

  void _resetHandsForRound() {
    for (var p in players) {
      p.cards = [];
      p.state = p.balance > 0 ? "idle" : "broke";
    }
  }

  void _startTurn() {
    if (turnIndex >= players.length) {
      _startNextBettingRound();
      return;
    }
    var player = players[turnIndex];
    if (player.balance <= 0) {
      player.state = "broke";
      _setMessage("${player.name} has no chips and passes.");
      onStateChanged();
      Future.delayed(const Duration(milliseconds: 800), () {
        turnIndex++;
        _startTurn();
      });
      return;
    }
    // Deal two cards
    player.cards = [_drawCard(), _drawCard()];
    player.state = "turn";
    int low = min(player.cards[0].value, player.cards[1].value);
    int high = max(player.cards[0].value, player.cards[1].value);
    _setMessage("${player.name}'s turn. Range: $low - $high");
    onStateChanged();

    if (player.isAI) {
      Future.delayed(const Duration(milliseconds: 1200), _aiTakeTurn);
    } else {
      _setMessage("Your turn: Bank Co, For Less, or Pass.");
    }
  }

  void _resolvePlay(int riskAmount, String mode) {
    var player = players[turnIndex];
    if (phase != "round" || player.cards.length != 2) return;
    int actualRisk = min(riskAmount, player.balance);
    CardData third = _drawCard();
    player.cards.add(third);
    int a = player.cards[0].value;
    int b = player.cards[1].value;
    int c = third.value;
    int low = min(a, b);
    int high = max(a, b);
    bool between = (c > low && c < high);

    if (between) {
      if (mode == "bankco") {
        int wonPot = pot;
        player.balance += wonPot;
        pot = 0;
        player.state = "won";
        _setMessage(
          "${player.name} called Bank Co and won the entire pot ($wonPot chips)!",
        );
        onStateChanged();
        // Bank Co win ends the round immediately
        Future.delayed(
          const Duration(milliseconds: 1800),
          () => _startNextBettingRound(),
        );
        return;
      } else {
        // "less"
        player.balance += actualRisk;
        pot -= actualRisk;
        if (pot < 0) pot = 0;
        player.state = "won";
        _setMessage("${player.name} wins $actualRisk chips!");
      }
    } else {
      player.balance -= actualRisk;
      pot += actualRisk;
      player.state = "lost";
      _setMessage("${player.name} loses $actualRisk chips.");
    }
    onStateChanged();
    Future.delayed(const Duration(milliseconds: 1800), () {
      player.cards = [];
      turnIndex++;
      _startTurn();
    });
  }

  void _aiTakeTurn() {
    var player = players[turnIndex];
    if (!player.isAI || phase != "round") return;
    if (player.balance <= 0) {
      player.state = "broke";
      _setMessage("${player.name} has no chips and passes.");
      onStateChanged();
      Future.delayed(const Duration(milliseconds: 800), () {
        player.cards = [];
        turnIndex++;
        _startTurn();
      });
      return;
    }
    int a = player.cards[0].value;
    int b = player.cards[1].value;
    int gap = (a - b).abs() - 1;
    if (gap <= 0) {
      player.state = "passed";
      _setMessage("${player.name} passed.");
      onStateChanged();
      Future.delayed(const Duration(milliseconds: 1000), () {
        player.cards = [];
        turnIndex++;
        _startTurn();
      });
      return;
    }
    double roll = _random.nextDouble();
    if (gap >= 6 && roll < 0.35) {
      _resolvePlay(pot, "bankco");
    } else if (gap >= 3 && roll < 0.75) {
      int lessAmount = (pot * 0.25).floor().clamp(25, player.balance);
      _resolvePlay(lessAmount, "less");
    } else {
      player.state = "passed";
      _setMessage("${player.name} passed.");
      onStateChanged();
      Future.delayed(const Duration(milliseconds: 1000), () {
        player.cards = [];
        turnIndex++;
        _startTurn();
      });
    }
  }

  void _startNextBettingRound() {
    phase = "betting";
    turnIndex = 0;
    for (var p in players) {
      p.bet = 0;
      p.cards = [];
      p.state = p.balance > 0 ? "idle" : "broke";
    }
    _applyRoundContribution();
    _autoBetAIPlayers();
    _setMessage(
      "New round. Everyone contributed to the pot. Place your bet, then press Begin Round.",
    );
    onStateChanged();
  }

  void _setMessage(String msg) {
    lastMessage = msg;
    debugPrint("[DaBankCo] $msg");
  }
}

// ===================== UI SECTION =====================

class PokerPage extends StatefulWidget {
  const PokerPage({super.key});

  @override
  State<PokerPage> createState() => _DaBankCoScreenState();
}

class _DaBankCoScreenState extends State<PokerPage> {
  late DaBankCoGame _game;
  final TextEditingController _betController = TextEditingController(
    text: "50",
  );
  final TextEditingController _lessController = TextEditingController(
    text: "25",
  );

  @override
  void initState() {
    super.initState();
    _game = DaBankCoGame(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    // Auto-start a new game when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _game.startNewGame(startingPot: 0, customRoundContribution: 100);
    });
  }

  @override
  void dispose() {
    _betController.dispose();
    _lessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06080D),
      appBar: AppBar(
        title: const Text(
          'Da Bank Co',
          style: TextStyle(color: Color(0xFFD7B15B)),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD7B15B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Setup row (round contribution + starting pot)
              _buildSetupRow(),
              const SizedBox(height: 20),
              // Game table (visual representation)
              _buildTable(),
              const SizedBox(height: 20),
              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupRow() {
    return Card(
      color: const Color(0xFF111822),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(
                  text: _game.roundContribution.toString(),
                ),
                decoration: const InputDecoration(
                  labelText: 'Round Contribution',
                  labelStyle: TextStyle(color: Color(0xFFD7B15B)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  int? contrib = int.tryParse(val);
                  if (contrib != null && contrib > 0)
                    _game.roundContribution = contrib;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: _game.pot.toString()),
                decoration: const InputDecoration(
                  labelText: 'Starting Pot',
                  labelStyle: TextStyle(color: Color(0xFFD7B15B)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {},
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD7B15B),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                int? pot = int.tryParse(
                  _betController.text,
                ); // crude; better to use separate controller
                _game.startNewGame(
                  startingPot: pot ?? 0,
                  customRoundContribution: _game.roundContribution,
                );
              },
              child: const Text('Start New Game'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      constraints: const BoxConstraints(minHeight: 500),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [Color(0xFF0D7A3B), Color(0xFF063D1F)],
        ),
        borderRadius: BorderRadius.circular(90),
        border: Border.all(color: const Color(0xFFD7B15B), width: 6),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 18),
        ],
      ),
      child: Stack(
        children: [
          // Center panel: pot + range + message
          Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.18),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pot: ${_game.pot} chips',
                    style: const TextStyle(
                      color: Color(0xFFF0D79A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_game.phase == "round" &&
                      _game.turnIndex < _game.players.length)
                    Text(
                      'Range: ${_getPlayerRange()}',
                      style: const TextStyle(color: Color(0xFFF4E5BF)),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _game.lastMessage,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Seats (positioned absolutely)
          _buildSeat(
            0,
            alignment: Alignment.topCenter,
            offset: const Offset(0, 20),
          ),
          _buildSeat(
            1,
            alignment: Alignment.centerLeft,
            offset: const Offset(20, 0),
          ),
          _buildSeat(
            2,
            alignment: Alignment.centerRight,
            offset: const Offset(-20, 0),
          ),
          _buildSeat(
            3,
            alignment: Alignment.bottomCenter,
            offset: const Offset(0, -20),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(
    int index, {
    required Alignment alignment,
    required Offset offset,
  }) {
    if (index >= _game.players.length) return const SizedBox.shrink();
    final player = _game.players[index];
    final isTurn = (_game.phase == "round" && _game.turnIndex == index);
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isTurn ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                player.isAI ? Icons.person : Icons.person_outline,
                color: const Color(0xFFD7B15B),
                size: 32,
              ),
              Text(
                player.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${player.balance} chips',
                style: const TextStyle(
                  color: Color(0xFFD7B15B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getStatusText(player),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              // Show cards
              if (player.cards.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: player.cards
                      .map((card) => _cardWidget(card))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardWidget(CardData card) {
    final isRed = card.suit == "♥" || card.suit == "♦";
    return Container(
      width: 40,
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${card.rank}${card.suit}',
          style: TextStyle(
            color: isRed ? Colors.red : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _getStatusText(Player p) {
    if (p.bet > 0) return "Bet: ${p.bet}";
    if (p.state == "passed") return "Passed";
    if (p.state == "won") return "Won";
    if (p.state == "lost") return "Lost";
    if (p.state == "broke") return "No chips";
    if (p.state == "turn") return "Playing";
    return "";
  }

  String _getPlayerRange() {
    if (_game.turnIndex >= _game.players.length) return "";
    final player = _game.players[_game.turnIndex];
    if (player.cards.length < 2) return "";
    final low = min(player.cards[0].value, player.cards[1].value);
    final high = max(player.cards[0].value, player.cards[1].value);
    return "$low to $high";
  }

  Widget _buildActionButtons() {
    if (_game.phase == "betting") {
      return Card(
        color: const Color(0xFF111822),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Wrap(
                spacing: 10,
                children: [50, 100, 200, 500].map((bet) {
                  return ElevatedButton(
                    onPressed: () => _betController.text = bet.toString(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                    child: Text(bet.toString()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _betController,
                      decoration: const InputDecoration(
                        labelText: "Bet",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      int? bet = int.tryParse(_betController.text);
                      if (bet != null) _game.placeHumanBet(bet);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD7B15B),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Place Your Bet"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _game.finishBettingAndBegin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: const Text(
                  "Begin Round",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_game.phase == "round") {
      final isHumanTurn =
          (_game.turnIndex < _game.players.length &&
          !_game.players[_game.turnIndex].isAI);
      return Card(
        color: const Color(0xFF111822),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 20,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isHumanTurn ? _game.bankCo : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD7B15B),
                  foregroundColor: Colors.black,
                ),
                child: const Text("Bank Co", style: TextStyle(fontSize: 16)),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _lessController,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              ElevatedButton(
                onPressed: isHumanTurn
                    ? () {
                        int? amount = int.tryParse(_lessController.text);
                        if (amount != null) _game.forLess(amount);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                ),
                child: const Text("For Less", style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: isHumanTurn ? _game.passTurn : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                ),
                child: const Text("Pass", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      );
    } else {
      // result phase (or idle)
      return Card(
        color: const Color(0xFF111822),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _game.finishBettingAndBegin(),
            child: const Text("Play Again", style: TextStyle(fontSize: 18)),
          ),
        ),
      );
    }
  }
}
