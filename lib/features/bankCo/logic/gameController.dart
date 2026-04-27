import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/cardModel.dart';
import 'package:flutter_application_1/core/models/gameState.dart';
import 'package:flutter_application_1/core/services/gameServices.dart';
import 'package:flutter_application_1/features/bankCo/logic/gameRules.dart';
import 'package:flutter_application_1/features/bankCo/logic/models/playerModel.dart';
import 'package:flutter_application_1/features/bankCo/logic/models/playerStatus.dart';

class GameController extends ChangeNotifier {
  late GameState state;
  final GameService _service = GameService();

  CardModel? thirdCard;

  // ================= INIT =================
  void init(List<PlayerModel> players) {
    _service.initializeDeck();

    state = GameState(players: players);
  }

  // ================= ROUND START =================
  void beginRound() {
    startRound();
  }

  void startRound() {
    thirdCard = null;

    state = state.copyWith(
      currentPlayerIndex: 0,
      pot: 0,
      phase: GamePhase.dealing,
      message: "",
    );

    _startTurn();
  }

  // ================= TURN =================
  void _startTurn() {
    if (state.currentPlayerIndex >= state.players.length) {
      _endRound();
      return;
    }

    final player = _currentPlayer();

    if (player.chips <= 0) {
      _nextTurn();
      return;
    }

    // 🔥 START ANIMATION
    state = state.copyWith(phase: GamePhase.dealing, dealCards: true);

    notifyListeners();

    // 🔥 DELAY REAL DEAL
    Future.delayed(const Duration(milliseconds: 500), () {
      player.cards = _service.dealTwoCards();

      state = state.copyWith(phase: GamePhase.decision, dealCards: false);

      notifyListeners();
    });
  }

  // ================= ACTIONS =================
  void pass() {
    final player = _currentPlayer();

    player.status = PlayerStatus.passed;
    player.cards = [];

    notifyListeners();
    _nextTurn();
  }

  // ================= TAKE (UI VERSION) =================
  void takeThirdCard() {
    final player = _currentPlayer();

    thirdCard = _service.drawThirdCard();

    state = state.copyWith(phase: GamePhase.reveal, showThirdCard: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      _resolve(player, player.currentBet);
    });

    notifyListeners();
  }

  // ================= FOR LESS =================
  void forLess(int amount) {
    final player = _currentPlayer();

    player.currentBet = amount;

    thirdCard = _service.drawThirdCard();

    state = state.copyWith(phase: GamePhase.reveal, showThirdCard: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      _resolve(player, amount);
    });

    notifyListeners();
  }

  // ================= BANKCO =================
  void bankCo() {
    final player = _currentPlayer();

    thirdCard = _service.drawThirdCard();

    final win = GameRules.isWin(player.cards[0], player.cards[1], thirdCard!);

    if (win) {
      player.chips += state.pot;
      state = state.copyWith(pot: 0, message: "BankCo Win!");
    } else {
      player.chips -= state.pot;
      state = state.copyWith(message: "BankCo Lose!");
    }

    _nextTurn();
  }

  // ================= CORE RESOLVE =================
  void _resolve(PlayerModel player, int bet) {
    final win = GameRules.isWin(player.cards[0], player.cards[1], thirdCard!);

    if (win) {
      player.chips += bet;
      state = state.copyWith(message: "Win!");
    } else {
      player.chips -= bet;
      state = state.copyWith(pot: state.pot + bet, message: "Lose!");
    }

    _nextTurn();
  }

  // ================= FLOW =================
  void _nextTurn() {
    state = state.copyWith(currentPlayerIndex: state.currentPlayerIndex + 1);

    _startTurn();
  }

  void _endRound() {
    state = state.copyWith(phase: GamePhase.result, message: "Round Finished");

    notifyListeners();
  }

  // ================= HELPERS =================
  PlayerModel _currentPlayer() {
    return state.players[state.currentPlayerIndex];
  }
}
