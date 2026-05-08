import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo/logic/da_bank_co_controller.dart';
import 'package:flutter_application_1/features/bankCo/logic/da_bank_co_state.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/CompactPlayerInfo.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/actionBubble.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/animatedCentralCard.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/gameBackground.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/navBars/BotTurnBar.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/navBars/HumanTurn.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/navBars/bettingBar.dart';

class BankCoPage extends StatefulWidget {
  const BankCoPage({super.key});

  @override
  State<BankCoPage> createState() => _BankCoPageState();
}

class _BankCoPageState extends State<BankCoPage> {
  late DaBankCoController _controller;

  // Bubble message
  String? _bubbleMessage;
  Timer? _bubbleTimer;
  PointerDirection _bubbleArrowDirection = PointerDirection.up;

  // Betting
  int? _selectedBet;
  final List<int> _betValues = [50, 100, 200, 500];

  @override
  void initState() {
    super.initState();
    _controller = DaBankCoController(onStateChanged: _onGameStateChanged);
    _controller.startNewGame(startingPot: 0, customRoundContribution: 100);
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
  void _bankCo() => _controller.bankCo();
  void _forLess() {
    int amount = _selectedBet ?? 50;
    _controller.forLess(amount);
  }

  void _pass() => _controller.passTurn();

  void _resetGame() {
    _controller.startNewGame(startingPot: 0, customRoundContribution: 100);
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
    final state = _controller.state;
    final human = state.players[state.humanIndex];
    final gameOver = _isGameOver();
    final tableScale = _getTableScale(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
              // Player seats + table
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

              // Centered animated cards for current player
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
                      AnimatedCentralCards(
                        key: ValueKey(
                          'cards_${state.turnIndex}_${state.roundContribution}',
                        ),
                        player: state.players[state.turnIndex],
                      ),
                    ],
                  ),
                ),

              // Bottom panel (game over or action bar)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: gameOver
                    ? _buildGameOverPanel()
                    : _buildBottomActionBar(state, human),
              ),
            ],
          ),
        ),
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

  Widget _buildBottomActionBar(DaBankCoGameState state, DaBankCoPlayer human) {
    if (state.phase == DaBankCoPhase.betting) {
      return BettingBar(
        humanBalance: human.balance,
        betValues: _betValues,
        onBetSelected: _placeBet,
        onBeginRound: _beginRound,
      );
    }

    if (state.phase == DaBankCoPhase.round && _isHumanTurn) {
      return HumanTurnBar(
        onBankCo: _bankCo,
        onForLess: _forLess,
        onPass: _pass,
      );
    }

    if (state.phase == DaBankCoPhase.round && !_isHumanTurn) {
      return const AITurnBar();
    }

    // Fallback (should never normally be shown)
    return ElevatedButton(
      onPressed: _resetGame,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.darkEmerald,
        foregroundColor: AppTheme.primaryGold,
      ),
      child: const Text("New Game"),
    );
  }
}
