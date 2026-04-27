import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/gameState.dart';
import 'package:flutter_application_1/core/models/cardModel.dart';
import 'package:flutter_application_1/core/services/gameServices.dart';
import 'package:flutter_application_1/features/bankCo/logic/models/playerModel.dart';
import 'package:flutter_application_1/features/bankCo/logic/gameRules.dart';
import 'package:flutter_application_1/features/bankCo/logic/models/playerStatus.dart';

class GameController extends ChangeNotifier {
  late GameState state;
  final GameService _service = GameService();

  CardModel? thirdCard;

  bool _turnLocked = false;

  // Snapshot of current turn (CRITICAL FIX)
  int _turnIndex = 0;
  PlayerModel? _turnPlayer;

  // ================= INIT =================
  void init(List<PlayerModel> players) {
    _service.initializeDeck();

    state = GameState(players: players);
  }

  void beginRound() {
    startRound();
  }

  // ================= START GAME =================
  void startRound() {
    thirdCard = null;

    state = state.copyWith(
      currentPlayerIndex: 0,
      phase: GamePhase.dealing,
      message: "",
    );

    _startTurn();
  }

  // ================= SAFE TURN ENGINE =================
  void _startTurn() {
    if (_turnLocked) return;

    if (state.currentPlayerIndex >= state.players.length) {
      _endRound();
      return;
    }

    _turnLocked = true;

    _turnIndex = state.currentPlayerIndex;
    _turnPlayer = state.players[_turnIndex];

    final player = _turnPlayer!;

    if (player.chips <= 0) {
      _turnLocked = false;
      _nextTurn();
      return;
    }

    state = state.copyWith(
      phase: GamePhase.dealing,
      dealCards: true,
      showCardFaceUp: false,
    );

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      _dealCards();
    });
  }

  // ================= DEAL =================
  void _dealCards() {
    final player = _turnPlayer;
    if (player == null) return;

    final updated = List<PlayerModel>.from(state.players);

    updated[_turnIndex] = player.copyWith(cards: _service.dealTwoCards());

    state = state.copyWith(
      players: updated,
      phase: GamePhase.decision,
      dealCards: false,
      showCardFaceUp: false,
    );

    _turnLocked = false;

    notifyListeners();
  }

  // ================= PASS =================
  void pass() {
    if (_turnLocked) return;

    final player = _turnPlayer;
    if (player == null) return;

    final updated = List<PlayerModel>.from(state.players);

    updated[_turnIndex] = player.copyWith(
      status: PlayerStatus.passed,
      cards: [],
    );

    state = state.copyWith(players: updated);

    notifyListeners();

    _nextTurn();
  }

  // ================= TAKE =================
  void takeThirdCard() {
    if (_turnLocked) return;

    final player = _turnPlayer;
    if (player == null) return;

    thirdCard = _service.drawThirdCard();

    state = state.copyWith(
      phase: GamePhase.reveal,
      showThirdCard: true,
      showCardFaceUp: true,
    );

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      _resolve(player.currentBet);
    });
  }

  // ================= FOR LESS =================
  void forLess(int amount) {
    if (_turnLocked) return;

    final player = _turnPlayer;
    if (player == null) return;

    thirdCard = _service.drawThirdCard();

    state = state.copyWith(phase: GamePhase.reveal, showThirdCard: true);

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      _resolve(amount);
    });
  }

  // ================= RESOLVE =================
  void _resolve(int bet) {
    final player = _turnPlayer;
    if (player == null || thirdCard == null) return;

    final updated = List<PlayerModel>.from(state.players);

    final current = updated[_turnIndex];

    final win = GameRules.isWin(current.cards[0], current.cards[1], thirdCard!);

    updated[_turnIndex] = current.copyWith(
      chips: win ? current.chips + bet : current.chips - bet,
    );

    state = state.copyWith(
      players: updated,
      message: win ? "Win!" : "Lose!",
      showCardFaceUp: true,
    );

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 800), () {
      _nextTurn();
    });
  }

  // ================= NEXT TURN =================
  void _nextTurn() {
    _turnLocked = false;
    _turnPlayer = null;

    final next = state.currentPlayerIndex + 1;

    if (next >= state.players.length) {
      _endRound();
      return;
    }

    state = state.copyWith(currentPlayerIndex: next);

    _startTurn();
  }

  // ================= END ROUND =================
  void _endRound() {
    state = state.copyWith(phase: GamePhase.result, message: "Round Finished");

    notifyListeners();
  }
}
