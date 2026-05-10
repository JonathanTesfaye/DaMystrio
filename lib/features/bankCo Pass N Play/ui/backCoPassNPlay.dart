import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/logic/da_bank_co_PnP_controller.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/logic/da_bank_co_PnP_state.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/widgets/CompactPlayerInfo.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/widgets/actionBubble.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/widgets/animatedCentralCard.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/widgets/gameBackground.dart';

class PassNPlayPage extends StatefulWidget {
  const PassNPlayPage({super.key});

  @override
  State<PassNPlayPage> createState() => _PassNPlayPageState();
}

class _PassNPlayPageState extends State<PassNPlayPage> {
  late PnPController _controller;
  bool _isSetupDialogShowing = false;

  String? _bubbleMessage;
  Timer? _bubbleTimer;
  PointerDirection _bubbleArrowDirection = PointerDirection.up;

  final List<int> _betValues = [50, 100, 200, 500];
  int? _selectedBet;

  @override
  void initState() {
    super.initState();
    _controller = PnPController(onStateChanged: _onGameStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isSetupDialogShowing) {
        _showPlayerSetupDialog();
      }
    });
  }

  void _onGameStateChanged() {
    if (!mounted) return;
    final state = _controller.state;

    if (state.phase == GamePhase.round && state.players.isNotEmpty) {
      final currentPlayer = state.currentPlayer;
      _bubbleArrowDirection = _seatIndexToDirection(currentPlayer.seatIndex);
    }
    final newMsg = state.lastMessage;
    if (newMsg.isNotEmpty && !newMsg.contains("Set up")) {
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
      case 3:
        return PointerDirection.down;
      default:
        return PointerDirection.up;
    }
  }

  Future<void> _showPlayerSetupDialog() async {
    if (_isSetupDialogShowing) return;
    _isSetupDialogShowing = true;

    int playerCount = 2;
    final List<TextEditingController> nameControllers = [];
    final formKey = GlobalKey<FormState>();

    for (int i = 0; i < playerCount; i++) {
      nameControllers.add(TextEditingController(text: "Player ${i + 1}"));
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text("New Game Setup"),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: playerCount,
                      decoration: const InputDecoration(
                        labelText: "Number of Players",
                      ),
                      items: [2, 3, 4].map((count) {
                        return DropdownMenuItem(
                          value: count,
                          child: Text("$count players"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          playerCount = value!;
                          nameControllers.clear();
                          for (int i = 0; i < playerCount; i++) {
                            nameControllers.add(
                              TextEditingController(text: "Player ${i + 1}"),
                            );
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(playerCount, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: nameControllers[index],
                          decoration: InputDecoration(
                            labelText: "Player ${index + 1} Name",
                            hintText: "Enter name",
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "Name required"
                              : null,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final names = nameControllers
                        .map((c) => c.text.trim())
                        .toList();
                    Navigator.pop(ctx);
                    _controller.setupNewGame(names);
                    _isSetupDialogShowing = false;
                  }
                },
                child: const Text("Start Game"),
              ),
            ],
          );
        },
      ),
    );
    _isSetupDialogShowing = false;
  }

  void _placeBet(int amount) {
    bool success = _controller.placeBet(amount);
    if (success) {
      setState(() => _selectedBet = amount);
    }
  }

  void _bankCo() => _controller.bankCo();

  // NEW: Show dialog to enter For Less amount
  Future<void> _forLess() async {
    final TextEditingController amountController = TextEditingController(
      text: "50",
    );
    final currentPlayer = _controller.state.currentPlayer;
    final maxAmount = currentPlayer.balance;

    final int? amount = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("For Less Amount"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Your balance: $maxAmount chips", style: AppTheme.captionGold),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Chips to risk"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final int? risk = int.tryParse(amountController.text);
              if (risk != null && risk > 0) {
                Navigator.pop(ctx, risk);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text("Enter a valid positive amount"),
                  ),
                );
              }
            },
            child: const Text("Risk"),
          ),
        ],
      ),
    );

    if (amount != null) {
      _controller.forLess(amount);
    }
  }

  void _pass() => _controller.passTurn();

  bool _isGameOver() => _controller.state.phase == GamePhase.gameOver;

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

    if (state.players.isEmpty) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.primaryGold),
              onPressed: () => _showPlayerSetupDialog(),
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final gameOver = _isGameOver();
    final tableScale = _getTableScale(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final playersBySeat = {for (var p in state.players) p.seatIndex: p};

    // Determine current player name for turn banners
    String currentActivePlayer = "";
    bool showBettingBanner = false;
    bool showRoundBanner = false;
    if (state.phase == GamePhase.betting &&
        state.players.isNotEmpty &&
        state.bettingPlayerIndex < state.players.length) {
      currentActivePlayer = state.players[state.bettingPlayerIndex].name;
      showBettingBanner = true;
    } else if (state.phase == GamePhase.round && state.players.isNotEmpty) {
      currentActivePlayer = state.currentPlayer.name;
      showRoundBanner = true;
    }

    return Scaffold(
      floatingActionButton: (!gameOver && state.phase != GamePhase.setup)
          ? FloatingActionButton(
              onPressed: () => _showPlayerSetupDialog(),
              backgroundColor: AppTheme.emeraldGreen,
              child: const Icon(Icons.refresh),
              tooltip: "New Game",
            )
          : null,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryGold),
            onPressed: () => _showPlayerSetupDialog(),
            tooltip: "New Game",
          ),
        ],
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
                          if (playersBySeat.containsKey(2))
                            Align(
                              alignment: const Alignment(0, -0.82),
                              child: CompactPlayerInfo(
                                player: playersBySeat[2]!,
                                isCurrentTurn: _isCurrentPlayer(2),
                              ),
                            ),
                          if (playersBySeat.containsKey(0))
                            Align(
                              alignment: const Alignment(-0.75, 0.15),
                              child: CompactPlayerInfo(
                                player: playersBySeat[0]!,
                                isCurrentTurn: _isCurrentPlayer(0),
                              ),
                            ),
                          if (playersBySeat.containsKey(1))
                            Align(
                              alignment: const Alignment(0.75, 0.15),
                              child: CompactPlayerInfo(
                                player: playersBySeat[1]!,
                                isCurrentTurn: _isCurrentPlayer(1),
                              ),
                            ),
                          if (playersBySeat.containsKey(3))
                            Align(
                              alignment: const Alignment(0, 0.8),
                              child: CompactPlayerInfo(
                                player: playersBySeat[3]!,
                                isCurrentTurn: _isCurrentPlayer(3),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Turn indicator banner (betting phase) – centered at top
              if (showBettingBanner)
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$currentActivePlayer's bet",
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.pureBlack,
                        ),
                      ),
                    ),
                  ),
                ),

              // Animated cards + round banner
              if (state.phase == GamePhase.round && state.players.isNotEmpty)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showRoundBanner)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$currentActivePlayer's turn",
                            style: AppTheme.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.pureBlack,
                            ),
                          ),
                        ),
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
                          'cards_${state.currentPlayerIndex}_${state.roundContribution}',
                        ),
                        player: state.currentPlayer,
                      ),
                    ],
                  ),
                ),

              // Bottom action bar
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: gameOver
                    ? _buildGameOverPanel()
                    : _buildBottomActionBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isCurrentPlayer(int seatIndex) {
    final state = _controller.state;
    if (state.phase != GamePhase.round) return false;
    if (state.players.isEmpty) return false;
    return state.currentPlayer.seatIndex == seatIndex;
  }

  Widget _buildGameOverPanel() {
    final players = _controller.state.players;
    final winner = players.isNotEmpty ? players[0].name : "No one";
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
            "$winner wins!",
            style: AppTheme.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showPlayerSetupDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: AppTheme.pureBlack,
            ),
            child: const Text("NEW GAME"),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final state = _controller.state;
    if (state.players.isEmpty) return const SizedBox.shrink();

    if (state.phase == GamePhase.betting) {
      if (state.bettingPlayerIndex >= state.players.length) {
        return const SizedBox.shrink();
      }
      final currentBettingPlayer = state.players[state.bettingPlayerIndex];
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${currentBettingPlayer.name}'s bet",
              style: AppTheme.captionGold,
            ),
            const SizedBox(height: 8),
            Row(
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
                      style: AppTheme.buttonText.copyWith(
                        color: AppTheme.offWhite,
                      ),
                    ),
                  ),
                  onSelected: _placeBet,
                  itemBuilder: (context) => [
                    ..._betValues.map(
                      (v) => PopupMenuItem(value: v, child: Text("$v chips")),
                    ),
                    PopupMenuItem(
                      value: currentBettingPlayer.balance,
                      child: Text("Max (${currentBettingPlayer.balance})"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (state.phase == GamePhase.round) {
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
            _actionButton("Bank Co", AppTheme.emeraldGreen, _bankCo),
            _actionButton("For Less", AppTheme.highlightGold, _forLess),
            _actionButton("Pass", AppTheme.lose, _pass),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppTheme.pureBlack,
        textStyle: AppTheme.buttonText.copyWith(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(label),
    );
  }
}
