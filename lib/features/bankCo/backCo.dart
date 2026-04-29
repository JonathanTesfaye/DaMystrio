import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/cardModel.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
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

  // Bubble message
  String? _bubbleMessage;
  Timer? _bubbleTimer;
  PointerDirection _bubbleArrowDirection = PointerDirection.up;

  // Betting
  int? _selectedBet;
  final List<int> _betValues = [50, 100, 200, 500];

  // Animation flags (reset each turn)
  bool _firstCardVisible = false;
  bool _firstCardFaceUp = false;
  bool _secondCardVisible = false;
  bool _secondCardFaceUp = false;
  bool _thirdCardDropped = false;

  // Track current turn to detect changes
  int _currentTurnIndex = -1;
  int _currentCardCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = DaBankCoController(onStateChanged: _onGameStateChanged);
    _controller.startNewGame(startingPot: 0, customRoundContribution: 100);
  }

  void _onGameStateChanged() {
    if (!mounted) return;
    final state = _controller.state;

    // Update bubble message and direction
    if (state.phase == DaBankCoPhase.round) {
      final currentPlayer = state.players[state.turnIndex];
      _bubbleArrowDirection = _seatIndexToDirection(currentPlayer.seatIndex);
    }
    final newMsg = state.lastMessage;
    if (newMsg.isNotEmpty && newMsg != "Start a new game.") {
      _showBubbleMessage(newMsg);
    }

    // Handle turn changes and card additions BEFORE building UI
    if (state.phase == DaBankCoPhase.round) {
      final int turnIdx = state.turnIndex;
      final int cardCount = state.players[turnIdx].cards.length;

      // Check if turn changed
      if (turnIdx != _currentTurnIndex) {
        // New turn: reset animation and start fresh
        _resetAnimation();
        _currentTurnIndex = turnIdx;
        _currentCardCount = cardCount;
        if (cardCount >= 2) {
          _startTurnAnimation();
        }
      } else if (cardCount != _currentCardCount) {
        // Same turn, but card count changed (third card added)
        _currentCardCount = cardCount;
        if (cardCount == 3 && !_thirdCardDropped) {
          _animateThirdCard();
        }
      }
    } else {
      // Not in round phase: reset tracking
      _resetAnimation();
      _currentTurnIndex = -1;
      _currentCardCount = 0;
    }

    // Finally, rebuild UI
    setState(() {});
  }

  void _resetAnimation() {
    _firstCardVisible = false;
    _firstCardFaceUp = false;
    _secondCardVisible = false;
    _secondCardFaceUp = false;
    _thirdCardDropped = false;
  }

  void _startTurnAnimation() {
    // First card appears face down
    _firstCardVisible = true;
    _firstCardFaceUp = false;
    // Second card not visible yet
    _secondCardVisible = false;
    _secondCardFaceUp = false;

    // Schedule flip of first card after 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _firstCardFaceUp = true);
      }
    });

    // Show second card (face down) after 600ms
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _secondCardVisible = true;
          _secondCardFaceUp = false;
        });
      }
    });

    // Flip second card after 900ms
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _secondCardFaceUp = true);
      }
    });
  }

  void _animateThirdCard() {
    // Delay slightly to let the third card appear
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _thirdCardDropped = true);
      }
    });
  }

  void _showBubbleMessage(String msg) {
    _bubbleTimer?.cancel();
    setState(() => _bubbleMessage = msg);
    _bubbleTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _bubbleMessage = null);
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

  void _placeBet(int amount) {
    _controller.placeHumanBet(amount);
    setState(() => _selectedBet = amount);
  }

  void _beginRound() => _controller.finishBettingAndBegin();

  void _bankCo() {
    _controller.bankCo();
  }

  void _forLess() {
    int amount = _selectedBet ?? 50;
    _controller.forLess(amount);
  }

  void _pass() => _controller.passTurn();

  void _resetGame() {
    _controller.startNewGame(startingPot: 0, customRoundContribution: 100);
    _resetAnimation();
    _currentTurnIndex = -1;
    _currentCardCount = 0;
    setState(() => _selectedBet = null);
  }

  bool get _isHumanTurn =>
      _controller.state.phase == DaBankCoPhase.round &&
      _controller.state.turnIndex == _controller.state.humanIndex;

  bool _isGameOver() {
    final human = _controller.state.players[_controller.state.humanIndex];
    if (human.balance <= 0) return true;
    if (_controller.state.phase == DaBankCoPhase.betting &&
        human.balance < _controller.state.roundContribution) {
      return true;
    }
    return false;
  }

  double get height => MediaQuery.of(context).size.height;
  double get width => MediaQuery.of(context).size.width;
  double _getTableScale(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double originalTableWidth = screenWidth * 2;
    double desiredTableWidth = 600.0;
    return desiredTableWidth / originalTableWidth;
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double tableScale = _getTableScale(context);
    final state = _controller.state;
    final human = state.players[state.humanIndex];
    final gameOver = _isGameOver();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.primaryGold,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Pot: ${state.pot}",
              style: AppTheme.captionGold.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Contribution: ${state.roundContribution}",
              style: AppTheme.bodyText.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      body: SizedBox.expand(
        child: GameBackground(
          child: Stack(
            children: [
              // Player seats
              Positioned(
                left: -100,
                right: -100,
                child: Center(
                  child: Transform.scale(
                    scale: tableScale,
                    child: SizedBox(
                      width: width * 2,
                      height: height,
                      child: Stack(
                        children: [
                          Center(
                            child: Image.asset(
                              'lib/assets/images/GameTableTraditional .png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Align(
                            alignment: const Alignment(0, -0.82),
                            child: CompactPlayerInfo(
                              player: state.players[2],
                              isCurrentTurn:
                                  state.phase == DaBankCoPhase.round &&
                                  state.turnIndex == 2,
                            ),
                          ),
                          Align(
                            alignment: const Alignment(-0.75, 0.15),
                            child: CompactPlayerInfo(
                              player: state.players[0],
                              isCurrentTurn:
                                  state.phase == DaBankCoPhase.round &&
                                  state.turnIndex == 0,
                            ),
                          ),
                          Align(
                            alignment: const Alignment(0.75, 0.15),
                            child: CompactPlayerInfo(
                              player: state.players[1],
                              isCurrentTurn:
                                  state.phase == DaBankCoPhase.round &&
                                  state.turnIndex == 1,
                            ),
                          ),
                          Align(
                            alignment: const Alignment(0, 0.8),
                            child: CompactPlayerInfo(
                              player: human,
                              isCurrentTurn: _isHumanTurn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Centered cards (animated) for current player
              if (state.phase == DaBankCoPhase.round &&
                  state.turnIndex < state.players.length)
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
                      _buildAnimatedCentralCards(
                        state.players[state.turnIndex],
                      ),
                    ],
                  ),
                ),

              // Bottom navigation or game over
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: gameOver
                    ? _buildGameOverPanel()
                    : _buildBottomNavBar(state, human),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== Added ValueKey to each CardWidget ==========
  Widget _buildAnimatedCentralCards(DaBankCoPlayer player) {
    final cards = player.cards;
    if (cards.isEmpty) return const SizedBox.shrink();

    final bool isCurrentTurn =
        (player == _controller.state.players[_controller.state.turnIndex]);
    final bool animate =
        isCurrentTurn &&
        (_firstCardVisible || _secondCardVisible || _thirdCardDropped);

    final firstCard = cards[0];
    final secondCard = cards[1];
    final hasThird = cards.length == 3;
    final thirdCard = hasThird ? cards[2] : null;

    // Unique key based on player name and current turn index to force fresh widget
    final String turnKey = '${player.name}_$_currentTurnIndex';

    return Container(
      key: ValueKey('container_$turnKey'),
      margin: const EdgeInsets.symmetric(horizontal: 100),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.pureBlack.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.primaryGold, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First card with unique key
              AnimatedOpacity(
                opacity: animate ? (_firstCardVisible ? 1.0 : 0.0) : 1.0,
                duration: const Duration(milliseconds: 200),
                child: CardWidget(
                  key: ValueKey('first_$turnKey'),
                  card: firstCard,
                  isFaceUp: animate ? _firstCardFaceUp : true,
                ),
              ),
              const SizedBox(width: 16),
              // Second card with unique key
              AnimatedOpacity(
                opacity: animate ? (_secondCardVisible ? 1.0 : 0.0) : 1.0,
                duration: const Duration(milliseconds: 200),
                child: CardWidget(
                  key: ValueKey('second_$turnKey'),
                  card: secondCard,
                  isFaceUp: animate ? _secondCardFaceUp : true,
                ),
              ),
            ],
          ),
          if (hasThird) ...[
            const SizedBox(height: 16),
            AnimatedSlide(
              offset: (animate && _thirdCardDropped)
                  ? Offset.zero
                  : const Offset(0, 2),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: CardWidget(
                key: ValueKey('third_$turnKey'),
                card: thirdCard!,
                isFaceUp: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameOverPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.pureBlack.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGold, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "GAME OVER",
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.highlightGold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "You have no chips left or cannot afford the contribution.",
            style: AppTheme.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: AppTheme.pureBlack,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              "START NEW GAME",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(DaBankCoGameState state, DaBankCoPlayer human) {
    if (state.phase == DaBankCoPhase.betting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.pureBlack.withOpacity(0.85),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: AppTheme.primaryGold.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PopupMenuButton<int>(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Bet",
                  style: AppTheme.buttonText.copyWith(color: AppTheme.offWhite),
                ),
              ),
              onSelected: _placeBet,
              itemBuilder: (context) => [
                ..._betValues.map(
                  (v) => PopupMenuItem(
                    value: v,
                    child: Text("$v chips", style: AppTheme.bodyText),
                  ),
                ),
                PopupMenuItem(
                  value: human.balance,
                  child: Text(
                    "Max (${human.balance})",
                    style: AppTheme.bodyText,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _beginRound,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: AppTheme.pureBlack,
              ),
              child: const Text("Begin Round"),
            ),
          ],
        ),
      );
    }

    if (state.phase == DaBankCoPhase.round && _isHumanTurn) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.pureBlack.withOpacity(0.85),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: AppTheme.primaryGold.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navButton("Bank Co", AppTheme.emeraldGreen, _bankCo),
            _navButton("For Less", AppTheme.highlightGold, _forLess),
            _navButton("Pass", AppTheme.lose, _pass),
          ],
        ),
      );
    }

    if (state.phase == DaBankCoPhase.round && !_isHumanTurn) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            "AI thinking...",
            style: AppTheme.captionGold.copyWith(fontWeight: FontWeight.normal),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: _resetGame,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.darkEmerald,
        foregroundColor: AppTheme.primaryGold,
      ),
      child: const Text("New Game"),
    );
  }

  Widget _navButton(String label, Color bgColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: AppTheme.pureBlack,
        textStyle: AppTheme.buttonText.copyWith(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(label),
    );
  }
}

// ------------------------------------------------------------
// CompactPlayerInfo and ActionBubble (unchanged)
// ------------------------------------------------------------
class CompactPlayerInfo extends StatelessWidget {
  final DaBankCoPlayer player;
  final bool isCurrentTurn;

  const CompactPlayerInfo({
    super.key,
    required this.player,
    required this.isCurrentTurn,
  });

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
    final bool isHuman = !player.isAI;
    final avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.8),
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: ClipOval(
        child: Container(
          width: 70,
          height: 70,
          color: AppTheme.surface,
          child: Image.asset(
            _getAvatarPath(),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, color: AppTheme.primaryGold, size: 35);
            },
          ),
        ),
      ),
    );
    final info = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.pureBlack.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            player.name,
            style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            "Chips: ${player.balance}",
            style: AppTheme.captionGold.copyWith(fontSize: 12),
          ),
          Text(
            "Bait: ${player.bet}",
            style: AppTheme.bodyText.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: isHuman
          ? [info, const SizedBox(height: 6), avatar]
          : [avatar, const SizedBox(height: 6), info],
    );
  }
}

// =============== Display player info with avatar on the table, with highlight for current turn ===============
class ActionBubble extends StatelessWidget {
  final String message;
  final PointerDirection pointerDirection;

  const ActionBubble({
    super.key,
    required this.message,
    required this.pointerDirection,
  });

  TextStyle _getMessageStyle() {
    if (message.contains('won') || message.contains('wins')) {
      return AppTheme.captionGold.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.win,
      );
    } else if (message.contains('loses') || message.contains('lost')) {
      return AppTheme.captionGold.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.lose,
      );
    } else {
      return AppTheme.captionGold.copyWith(fontSize: 12);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.pureBlack.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.primaryGold, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildArrow(),
          const SizedBox(width: 12),
          Flexible(
            child: Text(message, style: _getMessageStyle(), softWrap: true),
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
    return Icon(arrow, color: AppTheme.primaryGold, size: 20);
  }
}

enum PointerDirection { up, down, left, right }
