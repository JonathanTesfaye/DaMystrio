import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/features/bankCo%20Online/logic/OnlineGameService.dart';
import 'package:flutter_application_1/features/bankCo%20Online/logic/OnlineMatchState.dart';
import 'package:flutter_application_1/features/bankCo%20Online/model/cardModelOnline.dart';

class FirebaseOnlineGameService implements OnlineGameService {
  final String tableId;
  final String userId;
  final DatabaseReference _tablesRef = FirebaseDatabase.instance.ref('tables');
  late final DatabaseReference _tableRef;
  late final StreamSubscription<DatabaseEvent> _subscription;
  final _stateController = StreamController<OnlineMatchState>.broadcast();
  final Random _random = Random();

  FirebaseOnlineGameService({required this.tableId, required this.userId}) {
    _tableRef = _tablesRef.child(tableId);
    _subscription = _tableRef.onValue.listen(_onTableUpdate);
  }

  Map<String, dynamic> _toSimpleCard(CardModelOnline card) {
    return {'label': card.label, 'suit': card.suit, 'value': card.value};
  }

  @override
  Stream<OnlineMatchState> get gameStateStream => _stateController.stream;

  void _onTableUpdate(DatabaseEvent event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    print("🔥 [${DateTime.now()}] _onTableUpdate for table $tableId");
    print("🔥 currentPlayerId: ${data?['round']?['currentPlayerId']}");
    if (data == null) return;
    final newState = _convertToOnlineMatchState(data);
    _stateController.add(newState);
  }

  OnlineMatchState _convertToOnlineMatchState(Map<dynamic, dynamic> data) {
    final playersMap = data['players'] as Map<dynamic, dynamic>? ?? {};
    final roundData = data['round'] as Map<dynamic, dynamic>? ?? {};
    final gameStateData = data['gameState'] as Map<dynamic, dynamic>? ?? {};
    final meta = data['_meta'] as Map<dynamic, dynamic>? ?? {};
    final status = data['status'] as String? ?? 'waiting';

    final currentRound = (roundData['currentRound'] as num?)?.toInt() ?? 1;
    final totalRounds = (roundData['totalRounds'] as num?)?.toInt() ?? 3;
    final currentPlayerId = roundData['currentPlayerId'] as String? ?? '';
    final roundContribution =
        (data['roundContribution'] as num?)?.toInt() ?? 200;
    final pot = (gameStateData['potValue'] as num?)?.toInt() ?? 0;
    final winner = gameStateData['winner'] as String?;
    final lastMessage = data['lastMessage'] as String? ?? '';

    List<OnlinePlayer> players = [];
    playersMap.forEach((id, raw) {
      final p = Map<String, dynamic>.from(raw as Map);

      final rawDraw = p['draw'];
      List<dynamic> cardsRaw;
      if (rawDraw is List) {
        cardsRaw = rawDraw;
      } else {
        cardsRaw = [];
      }

      final statusRaw = p['status'] as Map<dynamic, dynamic>? ?? {};

      final cards = cardsRaw.map((cardMap) {
        final m = Map<String, dynamic>.from(cardMap);
        final dummyId =
            'card_${m['label']}_${m['suit']}_${DateTime.now().millisecondsSinceEpoch}';
        return CardModelOnline(
          id: dummyId,
          suit: m['suit'],
          label: m['label'],
          rank: m['label'],
          value: m['value'],
        );
      }).toList();

      players.add(
        OnlinePlayer(
          id: id,
          name: p['name'] ?? 'Player',
          seatIndex: (p['seatPosition'] as num?)?.toInt() ?? 0,
          balance: (p['chips'] as num?)?.toInt() ?? 0,
          bet: (p['customBet'] as num?)?.toInt() ?? 0,
          cards: cards,
          state: statusRaw['state'] ?? 'idle',
        ),
      );
    });
    players.sort((a, b) => a.seatIndex.compareTo(b.seatIndex));

    int currentPlayerIndex = 0;
    if (currentPlayerId.isNotEmpty) {
      final currentSeat = playersMap[currentPlayerId]?['seatPosition'] as int?;
      if (currentSeat != null) {
        currentPlayerIndex = players.indexWhere(
          (p) => p.seatIndex == currentSeat,
        );
        if (currentPlayerIndex == -1) currentPlayerIndex = 0;
      }
    }

    GamePhase phase;
    if (winner != null) {
      phase = GamePhase.gameOver;
    } else if (status == 'playing') {
      final hasCards = players.any((p) => p.cards.isNotEmpty);
      phase = hasCards ? GamePhase.round : GamePhase.setup;
    } else {
      phase = GamePhase.setup;
    }

    return OnlineMatchState(
      pot: pot,
      roundContribution: roundContribution,
      players: players,
      phase: phase,
      currentPlayerIndex: currentPlayerIndex,
      bettingPlayerIndex: 0,
      lastMessage: lastMessage,
      currentRound: currentRound,
      totalRounds: totalRounds,
      winnerName: winner,
      potValue: pot,
    );
  }

  // -------------------- Deck Helpers --------------------
  Future<List<String>> _getDeckCards() async {
    final snapshot = await _tableRef.child('deck/cards').get();
    final cards = snapshot.value as List<dynamic>?;
    return cards?.map((e) => e.toString()).toList() ?? [];
  }

  Future<int> _getDeckPosition() async {
    final snapshot = await _tableRef.child('deck/position').get();
    return (snapshot.value as num?)?.toInt() ?? 0;
  }

  Future<void> _shuffleDeck() async {
    List<String> cards = await _getDeckCards();
    if (cards.isEmpty) return;
    for (int i = cards.length - 1; i > 0; i--) {
      int j = _random.nextInt(i + 1);
      String temp = cards[i];
      cards[i] = cards[j];
      cards[j] = temp;
    }
    await _tableRef.child('deck/cards').set(cards);
    await _tableRef.child('deck/position').set(0);
  }

  Future<CardModelOnline> _drawCard() async {
    List<String> deckCards = await _getDeckCards();
    if (deckCards.isEmpty) return _randomCard();
    int pos = await _getDeckPosition();
    if (pos >= deckCards.length) {
      await _shuffleDeck();
      deckCards = await _getDeckCards();
      pos = 0;
    }
    final cardCode = deckCards[pos];
    await _tableRef.child('deck/position').set(pos + 1);
    return _cardFromCode(cardCode);
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

  // Deal cards to a player only if they don't already have cards
  Future<void> _dealCardsToPlayer(String playerId) async {
    final drawSnapshot = await _tableRef.child('players/$playerId/draw').get();
    final currentCards = drawSnapshot.value as List<dynamic>?;
    if (currentCards != null && currentCards.isNotEmpty) return;
    final card1 = await _drawCard();
    final card2 = await _drawCard();
    await _tableRef.child('players/$playerId/draw').set([
      _toSimpleCard(card1),
      _toSimpleCard(card2),
    ]);
    await _tableRef.child('players/$playerId/status/state').set('drawing');
    await _tableRef.child('players/$playerId/status/decision').set(null);
  }

  // Public wrapper
  Future<void> dealCardsToPlayer(String playerId) async {
    await _dealCardsToPlayer(playerId);
  }

  Future<void> _dealThirdCard(String playerId) async {
    final third = await _drawCard();
    await _tableRef
        .child('players/$playerId/draw')
        .child('2')
        .set(_toSimpleCard(third));
  }

  // -------------------- Drawing Phase Actions --------------------

  @override
  Future<void> bankCo() async {
    final playerId = userId;
    final snapshot = await _tableRef.child('players/$playerId').get();
    final playerData = snapshot.value as Map<dynamic, dynamic>?;
    if (playerData == null) return;

    final currentChips = (playerData['chips'] as num?)?.toInt() ?? 0;
    final pot =
        (await _tableRef.child('gameState/potValue').get()).value as int? ?? 0;

    final risk = min(currentChips, pot);
    if (risk <= 0) {
      await pass(); // cannot act if no chips or empty pot
      return;
    }

    await _resolveDrawingAction(risk, 'bankco', currentChips, pot);
  }

  @override
  @override
  Future<void> forLess(int amount) async {
    final playerId = userId;
    final snapshot = await _tableRef.child('players/$playerId').get();
    final playerData = snapshot.value as Map<dynamic, dynamic>?;
    if (playerData == null) return;

    final currentChips = (playerData['chips'] as num?)?.toInt() ?? 0;
    if (amount <= 0 || amount > currentChips) {
      await pass();
      return;
    }

    final pot =
        (await _tableRef.child('gameState/potValue').get()).value as int? ?? 0;
    // ForLess risk is the user-entered amount (no cap by pot)
    await _resolveDrawingAction(amount, 'forless', currentChips, pot);
  }

  @override
  Future<void> pass() async {
    final playerId = userId;
    await _tableRef.child('players/$playerId/status/state').set('passed');
    await _tableRef.child('players/$playerId/status/decision').set('passed');
    await _advanceTurn();
  }

  Future<void> _ensurePlayerHasCards(String playerId) async {
    print("🎴 _ensurePlayerHasCards for $playerId");
    final drawSnapshot = await _tableRef.child('players/$playerId/draw').get();
    final currentCards = drawSnapshot.value as List<dynamic>?;
    print("🎴 Current cards length: ${currentCards?.length ?? 0}");
    if (currentCards != null && currentCards.isNotEmpty) {
      print("🎴 Player already has cards, skipping deal");
      return;
    }
    final card1 = await _drawCard();
    final card2 = await _drawCard();
    print(
      "🎴 Dealt cards: ${card1.label}${card1.suit}, ${card2.label}${card2.suit}",
    );
    await _tableRef.child('players/$playerId/draw').set([
      _toSimpleCard(card1),
      _toSimpleCard(card2),
    ]);
  }

  Future<void> _resolveDrawingAction(
    int risk,
    String mode,
    int currentChips,
    int currentPot,
  ) async {
    final playerId = userId;
    final tableRef = _tableRef;

    // 1. Get player name
    final nameSnapshot = await tableRef.child('players/$playerId/name').get();
    final playerName = nameSnapshot.value as String? ?? 'Player';

    // 2. Deal third card
    await _dealThirdCard(playerId);

    // 3. Get all three cards
    final drawData =
        (await tableRef.child('players/$playerId/draw').get()).value
            as List<dynamic>? ??
        [];
    if (drawData.length < 3) return;

    final card0 = CardModelOnline.fromFirebase(
      Map<String, dynamic>.from(drawData[0]),
    );
    final card1 = CardModelOnline.fromFirebase(
      Map<String, dynamic>.from(drawData[1]),
    );
    final card2 = CardModelOnline.fromFirebase(
      Map<String, dynamic>.from(drawData[2]),
    );

    final values = [card0.value, card1.value, card2.value];
    final low = min(values[0], values[1]);
    final high = max(values[0], values[1]);
    final third = values[2];
    final bool isWin = (third > low && third < high);

    // 4. Calculate new chips and pot
    int newChips;
    int newPot;
    String resultMessage;

    if (isWin) {
      final winAmount = min(risk, currentPot);
      newChips = currentChips + winAmount;
      newPot = currentPot - winAmount;
      resultMessage = "$playerName won $winAmount chips!";
    } else {
      final lossAmount = risk;
      newChips = currentChips - lossAmount;
      newPot = currentPot + lossAmount;
      resultMessage = "$playerName lost $lossAmount chips.";
    }

    // 5. Prepare updates
    final updates = <String, dynamic>{
      'players/$playerId/chips': newChips,
      'gameState/potValue': newPot,
      'players/$playerId/status/decision': mode == 'bankco'
          ? 'bank co'
          : 'for less',
      'lastMessage': resultMessage,
    };

    if (newChips <= 0) {
      updates['players/$playerId/status/state'] = 'eliminated';
    } else {
      updates['players/$playerId/status/state'] = isWin ? 'won' : 'lost';
    }

    await tableRef.update(updates);
    await Future.delayed(const Duration(milliseconds: 2000));

    // 6. If pot is zero, end the round immediately (nothing left to play for)
    if (newPot == 0) {
      await _endRound();
    } else {
      await _advanceTurn();
    }
  }

  Future<void> _advanceTurn() async {
    final tableRef = _tableRef;

    final playersMap =
        (await tableRef.child('players').get()).value
            as Map<dynamic, dynamic>? ??
        {};

    // Players who still have chips and haven't acted this round (waiting or drawing)
    final List<MapEntry<String, int>> playersToAct = [];
    playersMap.forEach((uid, data) {
      final chips = (data['chips'] as num?)?.toInt() ?? 0;
      final state = data['status']['state'] as String?;
      if (chips > 0 && (state == 'waiting' || state == 'drawing')) {
        final seat = (data['seatPosition'] as num?)?.toInt() ?? 0;
        playersToAct.add(MapEntry(uid.toString(), seat));
      }
    });

    // End round only if no one is left to act
    if (playersToAct.isEmpty) {
      await _endRound();
      return;
    }

    playersToAct.sort((a, b) => a.value.compareTo(b.value));

    final currentPlayerId =
        (await tableRef.child('round/currentPlayerId').get()).value as String?;
    if (currentPlayerId == null) {
      // No current player → start with first waiting player
      final firstUid = playersToAct.first.key;
      await _ensurePlayerHasCards(firstUid);
      await tableRef.child('round/currentPlayerId').set(firstUid);
      await tableRef.child('players/$firstUid/status/state').set('drawing');
      return;
    }

    // Find current player's seat (if they are still in playersToAct)
    int currentSeat = -1;
    for (var entry in playersToAct) {
      if (entry.key == currentPlayerId) {
        currentSeat = entry.value;
        break;
      }
    }

    // If current player already acted (not in playersToAct), take the first waiting player
    if (currentSeat == -1) {
      final nextUid = playersToAct.first.key;
      await _ensurePlayerHasCards(nextUid);
      await tableRef.child('round/currentPlayerId').set(nextUid);
      await tableRef.child('players/$nextUid/status/state').set('drawing');
      return;
    }

    // Find next player in seat order (wrap around)
    final allSeats = List.generate(4, (i) => i);
    int nextSeatIndex = (allSeats.indexOf(currentSeat) + 1) % allSeats.length;
    int attempts = 0;
    while (attempts < allSeats.length) {
      final nextSeat = allSeats[nextSeatIndex];
      final nextPlayer = playersToAct.firstWhere(
        (entry) => entry.value == nextSeat,
        orElse: () => MapEntry('', -1),
      );
      if (nextPlayer.key.isNotEmpty) {
        final nextUid = nextPlayer.key;
        await _ensurePlayerHasCards(nextUid);
        await tableRef.child('round/currentPlayerId').set(nextUid);
        await tableRef.child('players/$nextUid/status/state').set('drawing');
        return;
      }
      nextSeatIndex = (nextSeatIndex + 1) % allSeats.length;
      attempts++;
    }

    // Fallback (should not happen if playersToAct is not empty)
    await _endRound();
  }

  bool _isEndingRound = false; // add at class level

  Future<void> _endRound() async {
    if (_isEndingRound) return; // prevent re-entry
    _isEndingRound = true;
    try {
      print("=== _endRound called ===");
      final tableRef = _tableRef;
      final playersMap =
          (await tableRef.child('players').get()).value
              as Map<dynamic, dynamic>? ??
          {};
      print("Players before end round: ${playersMap.length}");

      // Keep only players with chips > 0
      final remaining = {};
      playersMap.forEach((uid, value) {
        final chips = (value['chips'] as num?)?.toInt() ?? 0;
        if (chips > 0) remaining[uid] = value;
      });

      if (remaining.length < 2) {
        final winnerId = remaining.keys.first;
        final winnerName = remaining[winnerId]['name'];
        await tableRef.update({
          'status': 'finished',
          'gameState/winner': winnerName,
        });
        return;
      }

      print("Remaining players after elimination: ${remaining.length}");

      final roundContribution =
          (await tableRef.child('roundContribution').get()).value as int? ??
          200;
      final currentPot =
          (await tableRef.child('gameState/potValue').get()).value as int? ?? 0;
      int totalContributions = 0;
      final updates = <String, dynamic>{};

      for (var entry in remaining.entries) {
        final uid = entry.key;
        final player = Map<dynamic, dynamic>.from(entry.value);
        final currentChips = (player['chips'] as num?)?.toInt() ?? 0;
        final contribution = currentChips >= roundContribution
            ? roundContribution
            : currentChips;
        updates['players/$uid/chips'] = currentChips - contribution;
        totalContributions += contribution;
        if (contribution < roundContribution) {
          updates['players/$uid/isEliminated'] = true;
        }
        updates['players/$uid/draw'] = []; // clear cards
        updates['players/$uid/status/state'] = 'idle';
        updates['players/$uid/status/decision'] = null;
        updates['players/$uid/customBet'] = 0;
      }

      final newPot = currentPot + totalContributions;
      updates['gameState/potValue'] = newPot;
      updates['round/currentRound'] = ServerValue.increment(
        1,
      ); // increment round number

      await tableRef.update(updates);
      print("Calling _startNextRoundDrawing");
      await _startNextRoundDrawing();
    } finally {
      _isEndingRound = false;
    }
  }

  Future<void> _startNextRoundDrawing() async {
    print("🆕 _startNextRoundDrawing called");
    final tableRef = _tableRef;
    final playersMap =
        (await tableRef.child('players').get()).value
            as Map<dynamic, dynamic>? ??
        {};

    final List<String> activePlayers = [];
    playersMap.forEach((uid, value) {
      final chips = (value['chips'] as num?)?.toInt() ?? 0;
      if (chips > 0) activePlayers.add(uid.toString());
    });
    print("🆕 Active players (chips>0): $activePlayers");
    if (activePlayers.isEmpty) return;

    final seatMap = <String, int>{};
    for (var uid in activePlayers) {
      final seat = (playersMap[uid]['seatPosition'] as num?)?.toInt() ?? 0;
      seatMap[uid] = seat;
    }
    activePlayers.sort((a, b) => seatMap[a]!.compareTo(seatMap[b]!));

    // First player: give exactly two cards, set to 'drawing'
    final firstPlayerId = activePlayers.first;
    await _ensurePlayerHasCards(firstPlayerId); // gives two cards only
    await tableRef.child('round/currentPlayerId').set(firstPlayerId);
    await tableRef.child('players/$firstPlayerId/status/state').set('drawing');

    // All other players: clear cards, set to 'waiting'
    for (var uid in activePlayers) {
      if (uid != firstPlayerId) {
        await tableRef.child('players/$uid/status/state').set('waiting');
        await tableRef.child('players/$uid/status/decision').set(null);
        await tableRef
            .child('players/$uid/draw')
            .set([]); // ensure no cards (including third)
      }
    }
    print("Next round first player: $firstPlayerId");
  }

  // -------------------- Unused methods --------------------
  @override
  Future<bool> placeBet(int amount) async => false;
  @override
  Future<void> startNewGame(List<String> playerNames) async {}
  @override
  Future<void> joinTable(
    String tableId,
    String userId,
    String userName,
  ) async {}
  @override
  Future<void> setReady(String tableId, String userId) async {}
  @override
  Future<void> leaveGame(String tableId, String userId) async {}

  @override
  void dispose() {
    _subscription.cancel();
    _stateController.close();
  }
}
