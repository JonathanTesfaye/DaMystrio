import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/core/services/authService.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/logic/da_bank_co_PnP_state.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/widgets/CompactPlayerInfo.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/widgets/actionBubble.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/widgets/animatedCentralCard.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/widgets/gameBackground.dart';

class BankCoOnline extends StatefulWidget {
  final String tableId;
  const BankCoOnline({super.key, required this.tableId});

  @override
  State<BankCoOnline> createState() => _BankCoOnlineState();
}

class _BankCoOnlineState extends State<BankCoOnline> {
  final DatabaseReference _tablesRef = FirebaseDatabase.instance.ref('tables');
  final DatabaseReference _activeTablesRef = FirebaseDatabase.instance.ref(
    'activeTables',
  );
  final AuthService _auth = AuthService();

  StreamSubscription<DatabaseEvent>? _tableSubscription;

  bool _isWaiting = true;
  int _playerCount = 0;
  int _maxPlayers = 4;
  int _startConsentCount = 0;
  String _gameName = '';
  List<Map<String, dynamic>> _playersList = [];
  Map<String, Map<String, dynamic>> _playersMap = {};

  PnPGameState? _gameState;

  String? _bubbleMessage;
  Timer? _bubbleTimer;
  PointerDirection _bubbleArrowDirection = PointerDirection.up;
  final List<int> _betValues = [50, 100, 200, 500];
  int? _selectedBet;

  @override
  void initState() {
    super.initState();
    _listenToTable();
  }

  void _listenToTable() {
    _tableSubscription = _tablesRef.child(widget.tableId).onValue.listen((
      event,
    ) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return;
      final meta = data['_meta'] as Map<dynamic, dynamic>? ?? {};

      setState(() {
        _gameName = data['gameName'] ?? '';
        _maxPlayers = (meta['maxPlayers'] as num?)?.toInt() ?? 4;
        _startConsentCount = (meta['startConsentCount'] as num?)?.toInt() ?? 0;
        final players = data['players'] as List<dynamic>? ?? [];
        _playersList = players
            .map((p) => Map<String, dynamic>.from(p as Map))
            .toList();
        _playerCount = _playersList.length;
        _playersMap = {for (var p in _playersList) p['id']: p};
        _isWaiting = data['status'] != 'playing';
      });

      if (_isWaiting) {
        if (_playerCount >= _maxPlayers) {
          _startGame();
        } else if (_playerCount >= 2 && _startConsentCount >= _playerCount) {
          _startGame();
        }
      }

      if (!_isWaiting && _gameState == null) {
        setState(() {
          _gameState = _buildWaitingState();
        });
      }
    });
  }

  Future<void> _startGame() async {
    await _tablesRef.child(widget.tableId).child('status').set('playing');
    await _activeTablesRef.child(widget.tableId).remove();
  }

  Future<void> _setReady() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final playerIndex = _playersList.indexWhere((p) => p['id'] == user.uid);
    if (playerIndex == -1) return;
    if (_playersList[playerIndex]['status']?['startConsented'] == true) return;

    final updates = {
      'players/$playerIndex/status/startConsented': true,
      '_meta/startConsentCount': ServerValue.increment(1),
    };
    await _tablesRef.child(widget.tableId).update(updates);
  }

  Future<void> _leaveGame() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Game'),
        content: const Text('Are you sure you want to leave this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final leavingPlayer = _playersMap[user.uid];
    final hadConsented = leavingPlayer?['status']?['startConsented'] == true;

    final updatedPlayers = _playersList
        .where((p) => p['id'] != user.uid)
        .toList();
    await _tablesRef.child(widget.tableId).update({'players': updatedPlayers});

    final activeRef = _activeTablesRef.child(widget.tableId);
    if (updatedPlayers.isEmpty) {
      await _tablesRef.child(widget.tableId).remove();
      await activeRef.remove();
    } else {
      final activeSnapshot = await activeRef.get();
      if (activeSnapshot.exists) {
        final currentMeta = (activeSnapshot.value as Map)['_meta'] ?? {};
        final currentTotal =
            (currentMeta['totalPlayers'] as num?)?.toInt() ?? 0;
        await activeRef.child('_meta/totalPlayers').set(currentTotal - 1);
      }
      if (hadConsented) {
        final newConsentCount = _startConsentCount - 1;
        await _tablesRef
            .child(widget.tableId)
            .child('_meta/startConsentCount')
            .set(newConsentCount);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  void _placeBet(int amount) {}
  void _bankCo() {}
  Future<void> _forLess() async {}
  void _pass() {}

  PnPGameState _buildWaitingState() {
    final players = <PnPPlayer>[];
    for (int i = 0; i < _playersList.length; i++) {
      final p = _playersList[i];
      players.add(
        PnPPlayer(
          name: p['name'] ?? 'Player',
          seatIndex: p['seatPosition'] ?? i,
          balance: p['remainingChips'] ?? p['chips'] ?? 1000,
          bet: p['betAmount'] ?? 0,
          cards: [],
          state: 'idle',
        ),
      );
    }
    return PnPGameState(
      pot: 0,
      roundContribution: 200,
      players: players,
      phase: GamePhase.round,
      currentPlayerIndex: 0,
      bettingPlayerIndex: 0,
      lastMessage: 'Game started! (logic coming soon)',
    );
  }

  @override
  void dispose() {
    _tableSubscription?.cancel();
    _bubbleTimer?.cancel();
    super.dispose();
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

  bool _isCurrentPlayer(PnPGameState state, int seatIndex) {
    if (state.phase != GamePhase.round) return false;
    if (state.players.isEmpty) return false;
    return state.currentPlayer.seatIndex == seatIndex;
  }

  double _getTableScale(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double desiredTableWidth = 600.0;
    return desiredTableWidth / (screenWidth * 2);
  }

  Widget _buildGameOverPanel() {
    final winner = _gameState?.players.isNotEmpty == true
        ? _gameState!.players[0].name
        : "No one";
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
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: AppTheme.pureBlack,
            ),
            child: const Text("EXIT"),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(PnPGameState state) {
    if (state.players.isEmpty) return const SizedBox.shrink();
    if (state.phase == GamePhase.betting) {
      if (state.bettingPlayerIndex >= state.players.length)
        return const SizedBox.shrink();
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

  @override
  Widget build(BuildContext context) {
    final displayState = _isWaiting
        ? _buildWaitingState()
        : (_gameState ?? _buildWaitingState());
    final gameOver = displayState.phase == GamePhase.gameOver;
    final tableScale = _getTableScale(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Build players by seat and ready status
    final playersBySeat = <int, PnPPlayer?>{};
    final readyBySeat = <int, bool>{};
    for (int seat = 0; seat < 4; seat++) {
      final matchingPlayers = displayState.players.where(
        (p) => p.seatIndex == seat,
      );
      playersBySeat[seat] = matchingPlayers.isNotEmpty
          ? matchingPlayers.first
          : null;
    }
    for (var p in _playersList) {
      final seat = p['seatPosition'] as int? ?? 0;
      readyBySeat[seat] = p['status']?['startConsented'] == true;
    }

    String currentActivePlayer = "";
    bool showBettingBanner = false;
    bool showRoundBanner = false;
    if (!_isWaiting) {
      if (displayState.phase == GamePhase.betting &&
          displayState.players.isNotEmpty &&
          displayState.bettingPlayerIndex < displayState.players.length) {
        currentActivePlayer =
            displayState.players[displayState.bettingPlayerIndex].name;
        showBettingBanner = true;
      } else if (displayState.phase == GamePhase.round &&
          displayState.players.isNotEmpty) {
        currentActivePlayer = displayState.currentPlayer.name;
        showRoundBanner = true;
      }
    }

    final currentUserId = _auth.currentUser?.uid;
    final currentPlayer = currentUserId != null
        ? _playersMap[currentUserId]
        : null;
    final hasConsented = currentPlayer?['status']?['startConsented'] == true;

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
              "Pot: ${displayState.pot}",
              style: AppTheme.captionGold.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Contribution: ${displayState.roundContribution}",
              style: AppTheme.bodyText.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: GameBackground(
              child: Stack(
                children: [
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
                              // Seat 2 (top)
                              Align(
                                alignment: const Alignment(0, -0.82),
                                child: CompactPlayerInfo(
                                  player: playersBySeat[2],
                                  seatIndex: 2,
                                  isCurrentTurn:
                                      !_isWaiting &&
                                      _isCurrentPlayer(displayState, 2),
                                  isReady:
                                      _isWaiting && (readyBySeat[2] ?? false),
                                ),
                              ),
                              // Seat 0 (left)
                              Align(
                                alignment: const Alignment(-0.75, 0.15),
                                child: CompactPlayerInfo(
                                  player: playersBySeat[0],
                                  seatIndex: 0,
                                  isCurrentTurn:
                                      !_isWaiting &&
                                      _isCurrentPlayer(displayState, 0),
                                  isReady:
                                      _isWaiting && (readyBySeat[0] ?? false),
                                ),
                              ),
                              // Seat 1 (right)
                              Align(
                                alignment: const Alignment(0.75, 0.15),
                                child: CompactPlayerInfo(
                                  player: playersBySeat[1],
                                  seatIndex: 1,
                                  isCurrentTurn:
                                      !_isWaiting &&
                                      _isCurrentPlayer(displayState, 1),
                                  isReady:
                                      _isWaiting && (readyBySeat[1] ?? false),
                                ),
                              ),
                              // Seat 3 (bottom)
                              Align(
                                alignment: const Alignment(0, 0.8),
                                child: CompactPlayerInfo(
                                  player: playersBySeat[3],
                                  seatIndex: 3,
                                  isCurrentTurn:
                                      !_isWaiting &&
                                      _isCurrentPlayer(displayState, 3),
                                  isReady:
                                      _isWaiting && (readyBySeat[3] ?? false),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!_isWaiting &&
                      displayState.phase == GamePhase.round &&
                      displayState.players.isNotEmpty)
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
                            key: ValueKey(displayState.currentPlayerIndex),
                            player: displayState.currentPlayer,
                          ),
                        ],
                      ),
                    ),
                  if (!_isWaiting && !gameOver)
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: _buildBottomActionBar(displayState),
                    ),
                  if (gameOver)
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: _buildGameOverPanel(),
                    ),
                ],
              ),
            ),
          ),
          if (_isWaiting)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 250),
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _gameName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                          const SizedBox(height: 8),
                          Text('Players: $_playerCount/$_maxPlayers'),
                          const SizedBox(height: 16),
                          if (!hasConsented &&
                              _playerCount >= 2 &&
                              _playerCount < _maxPlayers &&
                              _isWaiting)
                            ElevatedButton(
                              onPressed: _setReady,
                              child: const Text('Ready'),
                            ),
                          if (_playerCount >= 2 &&
                              _startConsentCount < _playerCount &&
                              _isWaiting)
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Waiting for all players to be ready...',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _leaveGame,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Leave Game'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
