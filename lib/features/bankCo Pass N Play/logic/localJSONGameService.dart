import 'dart:async';
import 'dart:math';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/data/model/game.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/logic/gameService.dart';

class LocalJsonGameService implements GameService {
  OnlineGameState? _state;
  final _stateController = StreamController<OnlineGameState>.broadcast();
  final Random _random = Random();
  Set<String> _playersActedInDrawing = {};

  @override
  OnlineGameState get currentGameState {
    if (_state == null) throw StateError("Game not started");
    return _state!;
  }

  @override
  Stream<OnlineGameState> get gameStateStream => _stateController.stream;

  @override
  Future<void> startNewGame(List<String> playerNames) async {
    if (playerNames.length < 2 || playerNames.length > 4) {
      throw ArgumentError("Need 2-4 players");
    }

    final gameId = "local_${DateTime.now().millisecondsSinceEpoch}";
    final now = DateTime.now().toIso8601String();
    final players = <Player>[];
    for (int i = 0; i < playerNames.length; i++) {
      players.add(
        Player(
          id: "p${i + 1}",
          name: playerNames[i],
          avatar: "",
          initialChips: 1000,
          remainingChips: 1000,
          betAmount: null,
          seatPosition: i,
          isEliminated: false,
          isConnected: true,
          status: PlayerStatus(state: "idle"),
          draw: [],
          stats: PlayerStats(wins: 0, losses: 0),
        ),
      );
    }

    // Deduct round contribution
    final contribution = 200;
    int pot = 0;
    for (var p in players) {
      p.remainingChips -= contribution;
      pot += contribution;
    }

    _state = OnlineGameState(
      gameId: gameId,
      createdAt: now,
      updatedAt: now,
      status: "playing",
      phase: "betting",
      round: Round(
        roundNumber: 1,
        hasBegun: true,
        roundCount: 0,
        currentPlayerId: players.first.id,
        potValue: pot,
        roundContribution: contribution,
      ),
      cards: [], // we won't manage full deck for local mock
      players: players,
      gameState: GameStateInfo(activePlayerIndex: 0, eliminatedPlayers: []),
    );

    _playersActedInDrawing.clear();
    _stateController.add(_state!);
  }

  @override
  Future<bool> placeBet(int amount) async {
    if (_state == null) return false;
    if (_state!.phase != "betting") return false;

    final activeIdx = _state!.gameState.activePlayerIndex;
    final player = _state!.players[activeIdx];
    if (amount <= 0 || amount > player.remainingChips) return false;

    player.betAmount = amount;
    player.status.state = "bet placed";
    player.status.decision = null;

    // Move to next player
    int nextIdx = (activeIdx + 1) % _state!.players.length;
    _state!.gameState.activePlayerIndex = nextIdx;
    _state!.round.currentPlayerId = _state!.players[nextIdx].id;

    // Check if all players have bet
    bool allBet = _state!.players.every((p) => p.betAmount != null);
    if (allBet) {
      _state!.phase = "drawing";
      _state!.gameState.activePlayerIndex =
          0; // start drawing with first player
      _state!.round.currentPlayerId = _state!.players[0].id;
      _playersActedInDrawing.clear();
      // Deal two cards to the first player
      _dealCardsForPlayer(_state!.players[0]);
    }

    _state!.updatedAt = DateTime.now().toIso8601String();
    _stateController.add(_state!);
    return true;
  }

  void _dealCardsForPlayer(Player player) {
    player.draw = [_randomCard(), _randomCard()];
    player.status.state = "drawing";
    player.status.decision = null;
  }

  CardItem _randomCard() {
    const suits = ["spades", "hearts", "diamonds", "clubs"];
    const ranks = [
      {"rank": "A", "value": 1, "label": "A"},
      {"rank": "2", "value": 2, "label": "2"},
      {"rank": "3", "value": 3, "label": "3"},
      {"rank": "4", "value": 4, "label": "4"},
      {"rank": "5", "value": 5, "label": "5"},
      {"rank": "6", "value": 6, "label": "6"},
      {"rank": "7", "value": 7, "label": "7"},
      {"rank": "8", "value": 8, "label": "8"},
      {"rank": "9", "value": 9, "label": "9"},
      {"rank": "10", "value": 10, "label": "10"},
      {"rank": "J", "value": 11, "label": "J"},
      {"rank": "Q", "value": 12, "label": "Q"},
      {"rank": "K", "value": 13, "label": "K"},
    ];
    final rankData = ranks[_random.nextInt(ranks.length)];
    final suit = suits[_random.nextInt(suits.length)];
    return CardItem(
      id: "card_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}",
      suit: suit,
      label: "${rankData['label']}${_suitSymbol(suit)}",
      rank: rankData['rank'] as String,
      value: rankData['value'] as int,
      status: "dealt",
    );
  }

  String _suitSymbol(String suit) {
    switch (suit) {
      case "spades":
        return "♠";
      case "hearts":
        return "♥";
      case "diamonds":
        return "♦";
      case "clubs":
        return "♣";
      default:
        return "";
    }
  }

  @override
  Future<bool> bankCo() async {
    if (_state == null) return false;
    if (_state!.phase != "drawing") return false;

    final activeIdx = _state!.gameState.activePlayerIndex;
    final player = _state!.players[activeIdx];
    if (player.draw.length != 2) return false;

    final thirdCard = _randomCard();
    player.draw.add(thirdCard);
    player.status.decision = "bank co";

    final values = player.draw.map((c) => c.value).toList();
    final low = min(values[0], values[1]);
    final high = max(values[0], values[1]);
    final third = values[2];
    final isWin = (third > low && third < high);
    final risk = _state!.round.potValue;

    if (isWin) {
      player.remainingChips += risk;
      player.stats.wins += risk;
      _state!.round.potValue = 0;
    } else {
      player.remainingChips -= risk;
      player.stats.losses += risk;
      _state!.round.potValue += risk;
    }

    _state!.updatedAt = DateTime.now().toIso8601String();
    _stateController.add(_state!);
    await Future.delayed(const Duration(seconds: 2));

    _playersActedInDrawing.add(player.id);
    await _advanceDrawingTurn();
    return true;
  }

  @override
  Future<bool> forLess(int amount) async {
    if (_state == null) return false;
    if (_state!.phase != "drawing") return false;

    final activeIdx = _state!.gameState.activePlayerIndex;
    final player = _state!.players[activeIdx];
    if (player.draw.length != 2) return false;

    int risk = amount;
    if (risk > player.remainingChips) risk = player.remainingChips;
    if (risk > _state!.round.potValue) risk = _state!.round.potValue;
    if (risk <= 0) return false;

    final thirdCard = _randomCard();
    player.draw.add(thirdCard);
    player.status.decision = "for less";

    final values = player.draw.map((c) => c.value).toList();
    final low = min(values[0], values[1]);
    final high = max(values[0], values[1]);
    final third = values[2];
    final isWin = (third > low && third < high);

    if (isWin) {
      player.remainingChips += risk;
      player.stats.wins += risk;
      _state!.round.potValue -= risk;
    } else {
      player.remainingChips -= risk;
      player.stats.losses += risk;
      _state!.round.potValue += risk;
    }

    _state!.updatedAt = DateTime.now().toIso8601String();
    _stateController.add(_state!);
    await Future.delayed(const Duration(seconds: 2));

    _playersActedInDrawing.add(player.id);
    await _advanceDrawingTurn();
    return true;
  }

  @override
  Future<bool> pass() async {
    if (_state == null) return false;
    if (_state!.phase != "drawing") return false;

    final activeIdx = _state!.gameState.activePlayerIndex;
    final player = _state!.players[activeIdx];
    player.status.decision = "passed";
    _state!.updatedAt = DateTime.now().toIso8601String();
    _stateController.add(_state!);
    await Future.delayed(const Duration(milliseconds: 800));

    _playersActedInDrawing.add(player.id);
    await _advanceDrawingTurn();
    return true;
  }

  Future<void> _advanceDrawingTurn() async {
    if (_state == null) return;
    final totalPlayers = _state!.players.length;
    int nextIdx = (_state!.gameState.activePlayerIndex + 1) % totalPlayers;

    // Check if all players have acted
    bool allActed = _state!.players.every(
      (p) => _playersActedInDrawing.contains(p.id),
    );
    if (allActed) {
      await _endRoundAndNextBetting();
    } else {
      _state!.gameState.activePlayerIndex = nextIdx;
      _state!.round.currentPlayerId = _state!.players[nextIdx].id;
      _dealCardsForPlayer(_state!.players[nextIdx]);
      _state!.updatedAt = DateTime.now().toIso8601String();
      _stateController.add(_state!);
    }
  }

  Future<void> _endRoundAndNextBetting() async {
    if (_state == null) return;
    // Record round history (simplified)
    // Remove eliminated players (chips <= 0)
    _state!.players.removeWhere((p) => p.remainingChips <= 0);
    if (_state!.players.length < 2) {
      _state!.status = "finished";
      _state!.phase = "ended";
      _stateController.add(_state!);
      return;
    }

    // Start new betting round
    for (var p in _state!.players) {
      p.betAmount = null;
      p.status.decision = null;
      p.draw.clear();
      p.status.state = "idle";
      // Deduct contribution again
      final contribution = _state!.round.roundContribution;
      if (p.remainingChips >= contribution) {
        p.remainingChips -= contribution;
        _state!.round.potValue += contribution;
      } else {
        p.isEliminated = true;
      }
    }
    _state!.players.removeWhere((p) => p.isEliminated);
    if (_state!.players.length < 2) {
      _state!.status = "finished";
      _state!.phase = "ended";
      _stateController.add(_state!);
      return;
    }

    _state!.round.roundNumber += 1;
    _state!.phase = "betting";
    _state!.gameState.activePlayerIndex = 0;
    _state!.round.currentPlayerId = _state!.players[0].id;
    _state!.updatedAt = DateTime.now().toIso8601String();
    _playersActedInDrawing.clear();
    _stateController.add(_state!);
  }

  @override
  void dispose() {
    _stateController.close();
  }
}
