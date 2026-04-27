import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/cardModel.dart';
import 'package:flutter_application_1/features/bankCo/da_bank_co_controller.dart';
import 'package:flutter_application_1/features/bankCo/da_bank_co_state.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/cardWidget.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/gameBackground.dart';

class PokerPage2 extends StatefulWidget {
  const PokerPage2({super.key});

  @override
  State<PokerPage2> createState() => _PokerPageState2();
}

class _PokerPageState2 extends State<PokerPage2> {
  late DaBankCoController _controller;

  // Messages for the central action bubble
  String? _bubbleMessage;
  Timer? _bubbleTimer;
  PointerDirection _bubbleArrowDirection = PointerDirection.up;

  // Animation flags for human player's cards
  bool _dealFirst = false;
  bool _dealSecond = false;
  bool _dropThirdCard = false;
  bool _revealFirst = false;
  bool _revealSecond = false;

  // Betting state
  int? _selectedBet;
  final List<int> _betValues = [50, 100, 200, 500];

  @override
  void initState() {
    super.initState();
    _controller = DaBankCoController(onStateChanged: _onGameStateChanged);
    _controller.startNewGame(startingPot: 0, customRoundContribution: 100);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetAndAnimateHumanCards();
    });
  }

  void _onGameStateChanged() {
    if (!mounted) return;

    final state = _controller.state;
    if (state.phase == DaBankCoPhase.round) {
      final currentPlayer = state.players[state.turnIndex];
      _bubbleArrowDirection = _seatIndexToDirection(currentPlayer.seatIndex);
    }

    final newMsg = state.lastMessage;
    if (newMsg.isNotEmpty && newMsg != "Start a new game.") {
      _showBubbleMessage(newMsg);
    }

    setState(() {});
  }

  void _showBubbleMessage(String msg) {
    _bubbleTimer?.cancel();
    setState(() {
      _bubbleMessage = msg;
    });
    _bubbleTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _bubbleMessage = null;
        });
      }
    });
  }

  PointerDirection _seatIndexToDirection(int seatIndex) {
    switch (seatIndex) {
      case 0:
        return PointerDirection.left;
      case 1:
        return PointerDirection.right;
      case 2:
        return PointerDirection.up;
      case 4:
        return PointerDirection.down;
      default:
        return PointerDirection.up;
    }
  }

  void _resetAndAnimateHumanCards() {
    setState(() {
      _dealFirst = false;
      _dealSecond = false;
      _revealFirst = false;
      _revealSecond = false;
      _dropThirdCard = false;
    });
    Future.delayed(
      const Duration(milliseconds: 300),
      () => setState(() => _dealFirst = true),
    );
    Future.delayed(
      const Duration(milliseconds: 800),
      () => setState(() => _revealFirst = true),
    );
    Future.delayed(
      const Duration(milliseconds: 900),
      () => setState(() => _dealSecond = true),
    );
    Future.delayed(
      const Duration(milliseconds: 1400),
      () => setState(() => _revealSecond = true),
    );
  }

  void _placeBet(int amount) {
    _controller.placeHumanBet(amount);
    setState(() => _selectedBet = amount);
  }

  void _beginRound() {
    _controller.finishBettingAndBegin();
  }

  void _bankCo() {
    _controller.bankCo();
    setState(() => _dropThirdCard = false);
    Future.delayed(
      const Duration(milliseconds: 100),
      () => setState(() => _dropThirdCard = true),
    );
  }

  void _forLess() {
    int amount = _selectedBet ?? 50;
    _controller.forLess(amount);
    setState(() => _dropThirdCard = false);
    Future.delayed(
      const Duration(milliseconds: 100),
      () => setState(() => _dropThirdCard = true),
    );
  }

  void _pass() {
    _controller.passTurn();
    setState(() => _dropThirdCard = false);
  }

  void _resetRound() {
    _controller.startNewGame(startingPot: 0, customRoundContribution: 100);
    _resetAndAnimateHumanCards();
    setState(() {
      _selectedBet = null;
    });
  }

  bool get _isHumanTurn =>
      _controller.state.phase == DaBankCoPhase.round &&
      _controller.state.turnIndex == _controller.state.humanIndex;

  double get height => MediaQuery.of(context).size.height;
  double get width => MediaQuery.of(context).size.width;

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final human = state.players[state.humanIndex];
    final currentPlayer =
        state.phase == DaBankCoPhase.round &&
            state.turnIndex < state.players.length
        ? state.players[state.turnIndex]
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Pot: ${state.pot}",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Contribution: ${state.roundContribution}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 56),
          ],
        ),
      ),
      body: SizedBox.expand(
        child: GameBackground(
          child: Stack(
            children: [
              // ---------- Player Seats (circular avatars, only chips & bait) ----------
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
                            'lib/assets/images/PlayerTable.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        // AI 1 - Top seat (Arthur)
                        Align(
                          alignment: const Alignment(0, -0.82),
                          child: CompactPlayerInfo(
                            player: state.players[2],
                            isCurrentTurn:
                                state.phase == DaBankCoPhase.round &&
                                state.turnIndex == 2,
                          ),
                        ),
                        // AI 2 - Left-top (Liu Che)
                        Align(
                          alignment: const Alignment(-0.6, -0.47),
                          child: CompactPlayerInfo(
                            player: state.players[0],
                            isCurrentTurn:
                                state.phase == DaBankCoPhase.round &&
                                state.turnIndex == 0,
                          ),
                        ),
                        // AI 3 - Right-top (Scipio)
                        Align(
                          alignment: const Alignment(0.6, -0.47),
                          child: CompactPlayerInfo(
                            player: state.players[1],
                            isCurrentTurn:
                                state.phase == DaBankCoPhase.round &&
                                state.turnIndex == 1,
                          ),
                        ),
                        // Human - Bottom center
                        Align(
                          alignment: const Alignment(0, 0.5),
                          child: CompactPlayerInfo(
                            player: human,
                            isCurrentTurn: _isHumanTurn,
                          ),
                        ),
                        // Decorative seats (hidden)
                        const Align(
                          alignment: Alignment(-0.58, 0.6),
                          child: SizedBox.shrink(),
                        ),
                        const Align(
                          alignment: Alignment(0.585, 0.6),
                          child: SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ---------- Central Game Area (cards + action bubble) ----------
              if (state.phase == DaBankCoPhase.round && currentPlayer != null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_bubbleMessage != null)
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: ActionBubble(
                            message: _bubbleMessage!,
                            pointerDirection: _bubbleArrowDirection,
                          ),
                        ),
                      const SizedBox(height: 20),
                      _buildCentralCards(currentPlayer),
                    ],
                  ),
                ),

              // ---------- Bottom Navigation Bar (dynamic) ----------
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: _buildBottomNavBar(state, human),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(DaBankCoGameState state, DaBankCoPlayer human) {
    // Betting phase
    if (state.phase == DaBankCoPhase.betting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Bet button with dropdown
            PopupMenuButton<int>(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  "Bet",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onSelected: (value) => _placeBet(value),
              itemBuilder: (context) => [
                ..._betValues.map(
                  (v) => PopupMenuItem(value: v, child: Text("$v chips")),
                ),
                PopupMenuItem(
                  value: human.balance,
                  child: Text("Max (${human.balance})"),
                ),
              ],
            ),
            // Begin Round button
            ElevatedButton(
              onPressed: _beginRound,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              child: const Text(
                "Begin Round",
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        ),
      );
    }

    // Round phase – human turn
    if (state.phase == DaBankCoPhase.round && _isHumanTurn) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navButton("Bank Co", Colors.green[700]!, _bankCo),
            _navButton("For Less", Colors.orange[700]!, _forLess),
            _navButton("Pass", Colors.red[700]!, _pass),
          ],
        ),
      );
    }

    // If round phase but not human turn, show a message or nothing
    if (state.phase == DaBankCoPhase.round && !_isHumanTurn) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Text(
            "AI thinking...",
            style: TextStyle(color: Color.fromARGB(179, 246, 228, 39)),
          ),
        ),
      );
    }

    // Fallback (result phase or idle) – show restart button
    return ElevatedButton(
      onPressed: _resetRound,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
      child: const Text("New Game"),
    );
  }

  Widget _navButton(String label, Color bgColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: bgColor),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildCentralCards(DaBankCoPlayer player) {
    final cards = player.cards;
    if (cards.isEmpty) return const SizedBox.shrink();

    final bool isHuman = !player.isAI;
    final bool hasThird = cards.length == 3;
    final firstCard = cards[0];
    final secondCard = cards[1];
    final thirdCard = hasThird ? cards[2] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.shade300, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: isHuman ? (_dealFirst ? 1 : 0) : 1,
                duration: const Duration(milliseconds: 300),
                child: CardWidget(
                  card: firstCard,
                  isFaceUp: isHuman ? _revealFirst : true,
                ),
              ),
              const SizedBox(width: 16),
              AnimatedOpacity(
                opacity: isHuman ? (_dealSecond ? 1 : 0) : 1,
                duration: const Duration(milliseconds: 300),
                child: CardWidget(
                  card: secondCard,
                  isFaceUp: isHuman ? _revealSecond : true,
                ),
              ),
            ],
          ),
          if (hasThird) ...[
            const SizedBox(height: 16),
            AnimatedSlide(
              offset: isHuman
                  ? (_dropThirdCard ? Offset.zero : const Offset(0, 2))
                  : Offset.zero,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: CardWidget(card: thirdCard!, isFaceUp: true),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------- Player Info with Circular Avatar (no container border) ----------
class CompactPlayerInfo extends StatelessWidget {
  final DaBankCoPlayer player;
  final bool isCurrentTurn;

  const CompactPlayerInfo({
    super.key,
    required this.player,
    required this.isCurrentTurn,
  });

  // Map seat index to avatar asset (you can replace with your actual image paths)
  String _getAvatarPath() {
    switch (player.seatIndex) {
      case 0:
        return 'assets/images/avatar1.png';
      case 1:
        return 'assets/images/avatar2.png';
      case 2:
        return 'assets/images/avatar3.png';
      case 4:
        return 'assets/images/avatar2.png';
      default:
        return 'assets/images/avatar1.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular avatar with glowing border when active
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isCurrentTurn
                ? [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.8),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage(_getAvatarPath()),
            backgroundColor: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          player.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Chips: ${player.balance}",
          style: const TextStyle(color: Colors.amber, fontSize: 12),
        ),
        Text(
          "Bait: ${player.bet}",
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

// ---------- Action Bubble with Arrow (unchanged) ----------
class ActionBubble extends StatelessWidget {
  final String message;
  final PointerDirection pointerDirection;

  const ActionBubble({
    super.key,
    required this.message,
    required this.pointerDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.amber, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildArrow(),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    IconData arrow;
    switch (pointerDirection) {
      case PointerDirection.up:
        arrow = Icons.arrow_upward;
        break;
      case PointerDirection.down:
        arrow = Icons.arrow_downward;
        break;
      case PointerDirection.left:
        arrow = Icons.arrow_back;
        break;
      case PointerDirection.right:
        arrow = Icons.arrow_forward;
        break;
    }
    return Icon(arrow, color: Colors.amber, size: 20);
  }
}

enum PointerDirection { up, down, left, right }
