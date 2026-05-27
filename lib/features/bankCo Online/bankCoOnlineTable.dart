import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/core/services/authService.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo%20Online/logic/OnlineMatchState.dart';
import 'package:flutter_application_1/features/bankCo%20Online/logic/onlineMatchController.dart';
import 'package:flutter_application_1/features/bankCo%20Online/widget/CompactPlayerInfoOnline.dart';
import 'package:flutter_application_1/features/bankCo%20Online/widget/actionBubbleOnline.dart';
import 'package:flutter_application_1/features/bankCo%20Online/widget/animatedCentralCardOnline.dart';
import 'package:flutter_application_1/features/bankCo%20Online/widget/gameBackground.dart';
import 'package:flutter_application_1/features/bankCo%20Online/model/cardModelOnline.dart';

class BankCoOnline extends StatefulWidget {
  final String tableId;
  const BankCoOnline({super.key, required this.tableId});

  @override
  State<BankCoOnline> createState() => _BankCoOnlineState();
}

class _BankCoOnlineState extends State<BankCoOnline> {
  late OnlineMatchController _controller;
  final DatabaseReference _tablesRef = FirebaseDatabase.instance.ref('tables');
  final AuthService _auth = AuthService();
  final Random _random = Random();

  bool _isLeaving = false;
  bool _hasShownWinner = false;
  bool _hasShownLost = false;
  bool _isWaiting = true;
  int _totalPlayers = 0;
  int _maxPlayers = 4;
  int _startConsentCount = 0;
  String _gameName = '';
  String? _lastShownMessage;
  Map<int, bool> _readyBySeat = {};

  String? _bubbleMessage;
  Timer? _bubbleTimer;
  PointerDirection _bubbleArrowDirection = PointerDirection.up;
  final List<int> _betValues = [50, 100, 200, 500];
  Set<int> _announcedRounds = {};

  // transitions
  bool _isStartingGame = false;
  String? _roundAnnouncement;
  Timer? _roundAnnouncementTimer;
  int _previousRound = 0;

  StreamSubscription<DatabaseEvent>? _metadataSubscription;

  String _suitToSymbol(String suit) {
    switch (suit) {
      case 'spades':
        return '♠';
      case 'hearts':
        return '♥';
      case 'diamonds':
        return '♦';
      case 'clubs':
        return '♣';
      default:
        return suit;
    }
  }

  void _showCardMessage(String rank, String suit) {
    final symbol = _suitToSymbol(suit);
    _showBubbleMessage("$rank$symbol");
  }

  Map<String, dynamic> _cardToSimpleMap(CardModelOnline card) {
    return {'label': card.label, 'suit': card.suit, 'value': card.value};
  }

  @override
  void initState() {
    super.initState();
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      Future.delayed(Duration.zero, () => Navigator.pop(context));
      return;
    }
    _controller = OnlineMatchController(
      onStateChanged: _onGameStateChanged,
      tableId: widget.tableId,
      userId: userId,
    );
    _listenToTableMetadata();
  }

  void _showLostDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("You Lost"),
        content: const Text("You have run out of chips and are eliminated."),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showWinnerDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("You Won!"),
        content: const Text(
          "Congratulations! You are the last player standing.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _onGameStateChanged() {
    if (_isLeaving) return;
    setState(() {});
    final state = _controller.state;
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    final currentName = currentUser.displayName ?? currentUser.email ?? '';

    // Winner detection – using name (simple, no extra fields)
    if (state.phase == GamePhase.gameOver && state.winnerName != null) {
      if (state.winnerName == currentName && !_hasShownWinner) {
        _hasShownWinner = true;
        _showWinnerDialog();
      }
      return;
    }
    final newMsg = state.lastMessage;
    if (newMsg.isNotEmpty && newMsg != _lastShownMessage) {
      _lastShownMessage = newMsg;
      if (!newMsg.contains("place your bet") && !newMsg.contains("'s turn")) {
        _showBubbleMessage(newMsg);
      }
    }
    // Elimination detection – compare by UID (already correct)
    final myPlayer = state.players.firstWhere(
      (p) => p.id == currentUser.uid,
      orElse: () => OnlinePlayer(
        id: '',
        name: '',
        seatIndex: 0,
        balance: 0,
        bet: 0,
        cards: [],
        state: '',
      ),
    );
    if (myPlayer.balance == 0 &&
        !_hasShownLost &&
        state.phase != GamePhase.gameOver) {
      _hasShownLost = true;
      _showLostDialog();
    }
    // Round announcement
    if (state.phase == GamePhase.round &&
        state.currentRound > 0 &&
        !_isStartingGame) {
      if (!_announcedRounds.contains(state.currentRound) && !_hasShownWinner) {
        _announcedRounds.add(state.currentRound);
        _showRoundAnnouncement("Round ${state.currentRound}");
      }
    }
  }

  void _showStartingGameAndStart() async {
    print(">>> Starting game animation triggered");
    setState(() => _isStartingGame = true);
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() => _isStartingGame = false);
      _startGame();
    }
  }

  void _showRoundAnnouncement(String message) {
    _roundAnnouncementTimer?.cancel();
    setState(() => _roundAnnouncement = message);
    _roundAnnouncementTimer = Timer(
      const Duration(seconds: 2, milliseconds: 500),
      () {
        if (mounted) setState(() => _roundAnnouncement = null);
      },
    );
  }

  void _listenToTableMetadata() {
    _metadataSubscription = FirebaseDatabase.instance
        .ref('tables/${widget.tableId}')
        .onValue
        .listen((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return;

          final meta = data['_meta'] as Map<dynamic, dynamic>? ?? {};
          final playersRaw = data['players'] as Map<dynamic, dynamic>? ?? {};

          final readyMap = <int, bool>{};
          for (var entry in playersRaw.entries) {
            final p = entry.value as Map<dynamic, dynamic>;
            final seat = (p['seatPosition'] as num?)?.toInt() ?? 0;
            final consented = p['startConsented'] == true;
            readyMap[seat] = consented;
          }

          final startConsent =
              (data['startConsentCount'] as num?)?.toInt() ?? 0;

          setState(() {
            _gameName = data['gameName'] ?? '';
            _maxPlayers = (meta['maxPlayers'] as num?)?.toInt() ?? 4;
            _totalPlayers = playersRaw.length;
            _startConsentCount = startConsent;
            _readyBySeat = readyMap;
            _isWaiting = data['status'] != 'playing';
          });

          if (_isWaiting && !_isStartingGame) {
            print(
              "Players: $_totalPlayers/$_maxPlayers, Consent: $_startConsentCount",
            );
            if (_totalPlayers >= _maxPlayers) {
              _showStartingGameAndStart();
            } else if (_totalPlayers >= 2 &&
                _startConsentCount >= _totalPlayers) {
              _showStartingGameAndStart();
            }
          }
        });
  }

  Future<void> _startGame() async {
    final tableRef = _tablesRef.child(widget.tableId);
    final snapshot = await tableRef.get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return;

    final players = Map<dynamic, dynamic>.from(data['players'] ?? {});
    final roundContribution =
        (data['roundContribution'] as num?)?.toInt() ?? 200;

    int pot = 0;
    final updates = <String, dynamic>{};
    for (var entry in players.entries) {
      final uid = entry.key;
      final player = Map<dynamic, dynamic>.from(entry.value);
      final currentChips = (player['chips'] as num?)?.toInt() ?? 0;
      final newChips = currentChips - roundContribution;
      updates['players/$uid/chips'] = newChips;
      updates['players/$uid/customBet'] = null;
      pot += roundContribution;
    }

    updates['status'] = 'playing';
    await FirebaseDatabase.instance
        .ref('activeTables/${widget.tableId}')
        .remove();
    _announcedRounds.clear();

    final playerEntries = players.entries.map((entry) {
      final uid = entry.key;
      final seat = (entry.value['seatPosition'] as num?)?.toInt() ?? 0;
      return MapEntry(uid.toString(), seat);
    }).toList();
    playerEntries.sort((a, b) => a.value.compareTo(b.value));
    final firstPlayerId = playerEntries.isNotEmpty
        ? playerEntries.first.key
        : null;

    updates['round'] = {
      'currentPlayerId': firstPlayerId ?? '',
      'currentRound': 1,
      'totalRounds': 3,
    };
    updates['gameState'] = {
      'potValue': pot,
      'winner': null,
      'eliminatedPlayers': [],
    };
    updates['createdAt'] = ServerValue.timestamp;
    updates['updatedAt'] = ServerValue.timestamp;
    updates['id'] = widget.tableId;

    await tableRef.update(updates);
    await _shuffleDeck();

    if (firstPlayerId != null) {
      final card1 = await _drawCard();
      final card2 = await _drawCard();
      await tableRef.child('players/$firstPlayerId/draw').set([
        _cardToSimpleMap(card1),
        _cardToSimpleMap(card2),
      ]);
      await tableRef
          .child('players/$firstPlayerId/status/state')
          .set('drawing');
      await tableRef.child('players/$firstPlayerId/status/decision').set(null);

      for (var entry in playerEntries) {
        final uid = entry.key;
        if (uid != firstPlayerId) {
          final playerChips = (players[uid]?['chips'] as num?)?.toInt() ?? 0;
          if (playerChips > 0) {
            await tableRef.child('players/$uid/status/state').set('waiting');
            await tableRef.child('players/$uid/status/decision').set(null);
            await tableRef.child('players/$uid/draw').set([]);
          }
        }
      }
    }
  }

  Future<void> _dealToAllPlayers() async {
    final tableRef = _tablesRef.child(widget.tableId);
    final playersMap =
        (await tableRef.child('players').get()).value
            as Map<dynamic, dynamic>? ??
        {};
    final playerIds = playersMap.keys.toList();
    for (var uid in playerIds) {
      final card1 = await _drawCard();
      final card2 = await _drawCard();
      await tableRef.child('players/$uid/draw').set([
        _cardToSimpleMap(card1),
        _cardToSimpleMap(card2),
      ]);
      await tableRef.child('players/$uid/status/state').set('waiting');
      await tableRef.child('players/$uid/status/decision').set(null);
    }
  }

  Future<void> _shuffleDeck() async {
    final deckRef = _tablesRef.child(widget.tableId).child('deck');
    final snapshot = await deckRef.child('cards').get();
    final cards = List<String>.from(snapshot.value as List);
    cards.shuffle(_random);
    await deckRef.update({'cards': cards, 'position': 0});
  }

  Future<CardModelOnline> _drawCard() async {
    final tableRef = _tablesRef.child(widget.tableId);
    final deckRef = tableRef.child('deck');
    final cardsSnapshot = await deckRef.child('cards').get();
    final cards = List<String>.from(cardsSnapshot.value as List);
    if (cards.isEmpty) return _randomCard();

    int pos = (await deckRef.child('position').get()).value as int? ?? 0;
    if (pos >= cards.length) {
      cards.shuffle(_random);
      await deckRef.update({'cards': cards, 'position': 0});
      pos = 0;
    }
    final cardCode = cards[pos];
    await deckRef.child('position').set(pos + 1);
    return _cardFromCode(cardCode);
  }

  CardModelOnline _randomCard() {
    const suits = ['♠', '♥', '♦', '♣'];
    const ranks = [
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K',
      'A',
    ];
    final suit = suits[_random.nextInt(suits.length)];
    final rank = ranks[_random.nextInt(ranks.length)];
    int value;
    switch (rank) {
      case 'J':
        value = 11;
        break;
      case 'Q':
        value = 12;
        break;
      case 'K':
        value = 13;
        break;
      case 'A':
        value = 14;
        break;
      default:
        value = int.parse(rank);
    }
    return CardModelOnline(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      suit: suit,
      label: rank,
      rank: rank,
      value: value,
    );
  }

  CardModelOnline _cardFromCode(String code) {
    final rankStr = code.substring(0, code.length - 1);
    final suitSymbol = code[code.length - 1];
    int value;
    switch (rankStr) {
      case 'A':
        value = 14;
        break;
      case 'J':
        value = 11;
        break;
      case 'Q':
        value = 12;
        break;
      case 'K':
        value = 13;
        break;
      default:
        value = int.parse(rankStr);
    }
    return CardModelOnline(
      id: 'card_$code',
      suit: suitSymbol,
      label: rankStr,
      rank: rankStr,
      value: value,
    );
  }

  Future<void> _setReady() async {
    if (_isStartingGame || _roundAnnouncement != null) return;
    final user = _auth.currentUser;
    if (user == null) return;

    final tableRef = _tablesRef.child(widget.tableId);
    int attempts = 0;
    const maxAttempts = 3;
    bool success = false;

    while (attempts < maxAttempts && !success) {
      attempts++;
      try {
        final snapshot = await tableRef.get();
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data == null) return;

        final players = Map<dynamic, dynamic>.from(data['players'] ?? {});
        final playerObj = players[user.uid];
        if (playerObj == null) return;
        if (playerObj['startConsented'] == true) return;

        playerObj['startConsented'] = true;
        final currentConsent =
            (data['startConsentCount'] as num?)?.toInt() ?? 0;
        final newConsent = currentConsent + 1;

        final updates = {'players': players, 'startConsentCount': newConsent};
        await tableRef.update(updates);
        success = true;
        print("✅ Ready set for ${user.uid}");
      } catch (e) {
        print("SetReady attempt $attempts failed: $e");
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to set ready. Please try again.")),
      );
    }
  }

  Future<void> _leaveGame() async {
    if (_isStartingGame || _roundAnnouncement != null) return;
    final user = _auth.currentUser;
    if (user == null) return;

    // UID‑based turn check
    if (!_isWaiting && _controller.state.currentPlayer.id == user.uid) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Cannot Leave"),
          content: const Text(
            "You cannot leave the game during your turn. Please pass or make a decision first.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

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

    _isLeaving = true;
    _metadataSubscription?.cancel();
    _controller.dispose();

    final tableRef = _tablesRef.child(widget.tableId);
    final snapshot = await tableRef.get();
    if (!snapshot.exists) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final data = snapshot.value as Map<dynamic, dynamic>;
    final players = Map<dynamic, dynamic>.from(data['players'] ?? {});
    final playerObj = players[user.uid];
    if (playerObj == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final hadConsented = playerObj['startConsented'] == true;
    players.remove(user.uid);
    final newTotal = players.length;

    if (players.isEmpty) {
      await tableRef.remove();
      await FirebaseDatabase.instance
          .ref('activeTables/${widget.tableId}')
          .remove();
      if (mounted) Navigator.pop(context);
      return;
    }

    await tableRef.update({'players': players});
    await tableRef.child('_meta/totalPlayers').set(newTotal);

    final activeRef = FirebaseDatabase.instance.ref(
      'activeTables/${widget.tableId}',
    );
    final activeSnapshot = await activeRef.get();
    if (activeSnapshot.exists) {
      await activeRef.child('_meta/totalPlayers').set(newTotal);
    }

    if (hadConsented && _isWaiting) {
      final currentCount = (data['startConsentCount'] as num?)?.toInt() ?? 0;
      await tableRef.child('startConsentCount').set(currentCount - 1);
    }

    if (!_isWaiting && newTotal == 1) {
      final winnerId = players.keys.first;
      final winnerName = players[winnerId]['name'];
      await tableRef.update({
        'status': 'finished',
        'gameState/winner': winnerName,
        'gameState/winnerId': winnerId,
      });
    } else if (!_isWaiting &&
        playerObj['status']['state'] == 'drawing' &&
        data['round']['currentPlayerId'] == user.uid) {
      final activePlayers = players.keys.where((uid) {
        final chips = (players[uid]['chips'] as num?)?.toInt() ?? 0;
        final state = players[uid]['status']['state'] as String?;
        return chips > 0 && state != 'eliminated';
      }).toList();
      if (activePlayers.isNotEmpty) {
        await tableRef.child('round/currentPlayerId').set(activePlayers.first);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  void _bankCo() {
    _controller.bankCo();
    _showBubbleMessage("Bank Co!");
  }

  void _forLess() async {
    final currentPlayer = _controller.state.currentPlayer;
    final maxRisk = currentPlayer.balance;
    final controller = TextEditingController();
    final amount = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("For Less Amount"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Risk Amount (1 - $maxRisk)",
            helperText: "Enter chips to risk",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final risk = int.tryParse(controller.text);
              if (risk != null && risk > 0 && risk <= maxRisk) {
                Navigator.pop(ctx, risk);
              } else {
                ScaffoldMessenger.of(
                  ctx,
                ).showSnackBar(const SnackBar(content: Text("Invalid amount")));
              }
            },
            child: const Text("Risk"),
          ),
        ],
      ),
    );
    if (amount != null) {
      _controller.forLess(amount);
      _showBubbleMessage("For Less $amount");
    }
  }

  void _pass() {
    _controller.passTurn();
    _showBubbleMessage("Pass");
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

  bool _isCurrentPlayer(OnlineMatchState state, int seatIndex) {
    if (state.phase != GamePhase.round) return false;
    if (state.players.isEmpty) return false;
    return state.currentPlayer.id == _auth.currentUser?.uid &&
        state.currentPlayer.seatIndex == seatIndex;
  }

  Size _getTableSize(BoxConstraints constraints) {
    double maxWidth = constraints.maxWidth;
    double maxHeight = constraints.maxHeight;
    double desiredWidth = maxWidth * 0.92;
    double desiredHeight = desiredWidth;
    if (desiredHeight > maxHeight * 0.75) {
      desiredHeight = maxHeight * 0.75;
      desiredWidth = desiredHeight;
    }
    if (desiredWidth < 450) desiredWidth = 450;
    return Size(desiredWidth, desiredWidth);
  }

  Widget _buildBottomActionBar(OnlineMatchState state) {
    if (state.players.isEmpty) return const SizedBox.shrink();
    if (state.phase == GamePhase.round) {
      final isMyTurn = state.currentPlayer.id == _auth.currentUser?.uid;
      return Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(5),
        ),
        child: isMyTurn
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _bankCo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldGreen,
                    ),
                    child: const Text("Bank Co"),
                  ),
                  ElevatedButton(
                    onPressed: _forLess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                    ),
                    child: const Text("For Less"),
                  ),
                  ElevatedButton(
                    onPressed: _pass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Pass"),
                  ),
                ],
              )
            : Center(
                child: Text(
                  "Waiting for ${state.currentPlayer.name} to act...",
                  style: const TextStyle(color: AppTheme.primaryGold),
                ),
              ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildGameOverPanel() {
    final winner = _controller.state.winnerName ?? "No one";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGold, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "GAME OVER",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$winner wins!",
            style: const TextStyle(color: AppTheme.offWhite),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("EXIT"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final gameOver = state.phase == GamePhase.gameOver;

    final playersBySeat = <int, OnlinePlayer?>{};
    for (int seat = 0; seat < 4; seat++) {
      final matching = state.players.where((p) => p.seatIndex == seat);
      playersBySeat[seat] = matching.isNotEmpty ? matching.first : null;
    }

    final currentUserId = _auth.currentUser?.uid;
    int currentUserSeat = -1;
    for (var entry in _readyBySeat.entries) {
      final seat = entry.key;
      final player = playersBySeat[seat];
      if (player != null && player.id == currentUserId) {
        currentUserSeat = seat;
        break;
      }
    }
    final hasConsented =
        currentUserSeat != -1 && (_readyBySeat[currentUserSeat] ?? false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.offWhite),
          onPressed: _leaveGame,
        ),
        title: Column(
          children: [
            Text(
              "Pot: ${state.pot}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
              ),
            ),
            Text(
              "Contribution: ${state.roundContribution}",
              style: const TextStyle(fontSize: 12, color: AppTheme.offWhite),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final tableSize = _getTableSize(constraints);
          final double seatScale = tableSize.width / 600;
          final seatAlignments = {
            2: const Alignment(0, -1),
            0: const Alignment(-0.95, 0.15),
            1: const Alignment(0.95, 0.12),
            3: const Alignment(0, 1),
          };

          return Stack(
            children: [
              GameBackground(
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: tableSize.width,
                        height: tableSize.height,
                        child: Image.asset(
                          'lib/assets/images/GameTableTraditional.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: tableSize.width,
                        height: tableSize.height,
                        child: Stack(
                          children: [
                            if (_isWaiting || playersBySeat[2] != null)
                              Align(
                                alignment: seatAlignments[2]!,
                                child: Transform.scale(
                                  scale: seatScale,
                                  child: CompactPlayerInfo(
                                    player: playersBySeat[2],
                                    seatIndex: 2,
                                    isCurrentTurn:
                                        !_isWaiting &&
                                        _isCurrentPlayer(state, 2),
                                    isReady:
                                        _isWaiting &&
                                        (_readyBySeat[2] ?? false),
                                    onCardTap: _showCardMessage,
                                  ),
                                ),
                              ),
                            if (_isWaiting || playersBySeat[0] != null)
                              Align(
                                alignment: seatAlignments[0]!,
                                child: Transform.scale(
                                  scale: seatScale,
                                  child: CompactPlayerInfo(
                                    player: playersBySeat[0],
                                    seatIndex: 0,
                                    isCurrentTurn:
                                        !_isWaiting &&
                                        _isCurrentPlayer(state, 0),
                                    isReady:
                                        _isWaiting &&
                                        (_readyBySeat[0] ?? false),
                                    onCardTap: _showCardMessage,
                                  ),
                                ),
                              ),
                            if (_isWaiting || playersBySeat[1] != null)
                              Align(
                                alignment: seatAlignments[1]!,
                                child: Transform.scale(
                                  scale: seatScale,
                                  child: CompactPlayerInfo(
                                    player: playersBySeat[1],
                                    seatIndex: 1,
                                    isCurrentTurn:
                                        !_isWaiting &&
                                        _isCurrentPlayer(state, 1),
                                    isReady:
                                        _isWaiting &&
                                        (_readyBySeat[1] ?? false),
                                    onCardTap: _showCardMessage,
                                  ),
                                ),
                              ),
                            if (_isWaiting || playersBySeat[3] != null)
                              Align(
                                alignment: seatAlignments[3]!,
                                child: Transform.scale(
                                  scale: seatScale,
                                  child: CompactPlayerInfo(
                                    player: playersBySeat[3],
                                    seatIndex: 3,
                                    isCurrentTurn:
                                        !_isWaiting &&
                                        _isCurrentPlayer(state, 3),
                                    isReady:
                                        _isWaiting &&
                                        (_readyBySeat[3] ?? false),
                                    onCardTap: _showCardMessage,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (!_isWaiting &&
                        state.phase == GamePhase.round &&
                        state.players.isNotEmpty)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.phase == GamePhase.round)
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
                                  "${state.currentPlayer.name}'s turn",
                                  style: const TextStyle(
                                    color: AppTheme.pureBlack,
                                  ),
                                ),
                              ),
                            if (_bubbleMessage != null)
                              ActionBubble(
                                message: _bubbleMessage!,
                                pointerDirection: _bubbleArrowDirection,
                              ),
                            const SizedBox(height: 20),
                            AnimatedCentralCards(
                              key: ValueKey(
                                '${state.currentPlayer.id}_${state.currentRound}_${state.currentPlayer.cards.length}',
                              ),
                              player: state.currentPlayer,
                              onCardTap: _showCardMessage,
                            ),
                          ],
                        ),
                      ),
                    if (!_isWaiting && !gameOver)
                      Positioned(
                        bottom: MediaQuery.of(context).padding.bottom + 10,
                        left: 5,
                        right: 5,
                        child: _buildBottomActionBar(state),
                      ),
                  ],
                ),
              ),
              if (_roundAnnouncement != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          _roundAnnouncement!,
                          style: AppTheme.headingLarge.copyWith(fontSize: 28),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_isStartingGame)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.85),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryGold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Starting Game...",
                            style: AppTheme.headingMedium.copyWith(
                              color: AppTheme.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_isWaiting && !_isStartingGame)
                Positioned.fill(
                  child: Container(
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
                                ),
                                const SizedBox(height: 8),
                                Text('Players: $_totalPlayers/$_maxPlayers'),
                                const SizedBox(height: 16),
                                if (!hasConsented &&
                                    _totalPlayers >= 2 &&
                                    _totalPlayers < _maxPlayers &&
                                    _isWaiting)
                                  ElevatedButton(
                                    onPressed: _setReady,
                                    child: const Text('Ready'),
                                  ),
                                if (_totalPlayers >= 2 &&
                                    _startConsentCount < _totalPlayers &&
                                    _isWaiting)
                                  const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'Waiting for all players to be ready...',
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
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _metadataSubscription?.cancel();
    _controller.dispose();
    _bubbleTimer?.cancel();
    super.dispose();
  }
}
