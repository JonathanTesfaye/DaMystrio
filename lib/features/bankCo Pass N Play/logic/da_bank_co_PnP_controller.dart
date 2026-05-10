import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/cardModel.dart';
import 'da_bank_co_PnP_state.dart';

class PnPController {
  PnPGameState _state;
  final VoidCallback onStateChanged;
  final Random _random = Random();

  PnPController({required this.onStateChanged})
    : _state = PnPGameState(
        pot: 0,
        roundContribution: 100,
        players: [],
        phase: GamePhase.setup,
        currentPlayerIndex: 0,
        bettingPlayerIndex: 0,
        lastMessage: "Set up players to start.",
      );

  PnPGameState get state => _state;

  // ---------- Setup new game with player names ----------
  void setupNewGame(List<String> names, {int startingContribution = 100}) {
    if (names.length < 2 || names.length > 4) {
      _setMessage("Need 2 to 4 players.");
      return;
    }

    // Create players with seat indices 0..n-1
    final players = <PnPPlayer>[];
    for (int i = 0; i < names.length; i++) {
      players.add(PnPPlayer(name: names[i], seatIndex: i, balance: 1000));
    }

    // Reset state
    _state = _state.copyWith(
      pot: 0,
      roundContribution: startingContribution,
      players: players,
      phase: GamePhase.betting,
      currentPlayerIndex: 0,
      bettingPlayerIndex: 0,
      lastMessage: "Game started! Place your bets.",
    );

    // Deduct contribution from all players and add to pot
    _applyRoundContribution();
    _resetBets();
    _setMessage(
      "Each player pays ${_state.roundContribution} chips. ${_state.players[0].name}, place your bet.",
    );
    onStateChanged();
  }

  // ---------- Betting Phase ----------
  bool placeBet(int amount) {
    if (_state.phase != GamePhase.betting) {
      _setMessage("Not betting phase.");
      return false;
    }
    if (_state.bettingPlayerIndex >= _state.players.length) {
      // Betting already complete – should start round
      _startRound();
      return false;
    }
    final player = _state.players[_state.bettingPlayerIndex];
    if (player.balance <= 0) {
      _setMessage("${player.name} has no chips and cannot bet.");
      _nextBettingPlayer();
      return false;
    }
    if (amount <= 0 || amount > player.balance) {
      _setMessage("Invalid bet amount. Max: ${player.balance}");
      return false;
    }
    player.bet = amount;
    _setMessage("${player.name} bets $amount chips.");
    onStateChanged();
    _nextBettingPlayer();
    return true;
  }

  void _nextBettingPlayer() {
    int next = _state.bettingPlayerIndex + 1;
    if (next >= _state.players.length) {
      // Betting complete, start round
      _startRound();
    } else {
      _state = _state.copyWith(bettingPlayerIndex: next);
      _setMessage("${_state.players[next].name}, place your bet.");
      onStateChanged();
    }
  }

  void _startRound() {
    _resetHands();
    _state = _state.copyWith(
      phase: GamePhase.round,
      currentPlayerIndex: 0,
      bettingPlayerIndex: 0,
    );
    _startTurn();
  }

  // ---------- Round Actions ----------
  void bankCo() {
    if (_state.phase != GamePhase.round) return;
    final player = _state.currentPlayer;
    if (player.balance < _state.pot) {
      _setMessage("Insufficient chips to call Bank Co (need ${_state.pot}).");
      onStateChanged();
      return;
    }
    _resolvePlay(_state.pot, "bankco");
  }

  void forLess(int amount) {
    if (_state.phase != GamePhase.round) return;
    final player = _state.currentPlayer;
    if (amount <= 0) {
      _setMessage("Enter a valid amount.");
      return;
    }
    int actualRisk = amount;
    if (actualRisk > player.balance) actualRisk = player.balance;
    if (actualRisk > _state.pot) actualRisk = _state.pot;
    if (actualRisk <= 0) {
      _setMessage("Cannot risk that amount.");
      return;
    }
    _resolvePlay(actualRisk, "less");
  }

  void passTurn() {
    if (_state.phase != GamePhase.round) return;
    final player = _state.currentPlayer;
    player.state = "passed";
    player.cards = [];
    _setMessage("${player.name} passed.");
    onStateChanged();
    Future.delayed(const Duration(milliseconds: 800), () {
      _advanceTurn();
    });
  }

  void _resolvePlay(int riskAmount, String mode) {
    final player = _state.currentPlayer;
    if (player.cards.length != 2) return;

    CardModel third = _drawCard();
    player.cards.add(third);

    int a = player.cards[0].value;
    int b = player.cards[1].value;
    int c = third.value;
    int low = min(a, b);
    int high = max(a, b);
    bool between = (c > low && c < high);
    bool isBankCo = (mode == "bankco");

    if (between) {
      if (isBankCo) {
        int wonPot = _state.pot;
        player.balance += wonPot;
        _state = _state.copyWith(pot: 0);
        player.state = "won";
        _setMessage(
          "${player.name} called Bank Co and won the entire pot ($wonPot chips)!",
        );
        onStateChanged();
        Future.delayed(
          const Duration(milliseconds: 1800),
          () => _startNextBettingRound(),
        );
        return;
      } else {
        player.balance += riskAmount;
        _state = _state.copyWith(pot: _state.pot - riskAmount);
        player.state = "won";
        _setMessage("${player.name} wins $riskAmount chips!");
      }
    } else {
      player.balance -= riskAmount;
      _state = _state.copyWith(pot: _state.pot + riskAmount);
      player.state = "lost";
      _setMessage("${player.name} loses $riskAmount chips.");
    }
    onStateChanged();
    Future.delayed(const Duration(milliseconds: 1800), () {
      player.cards = [];
      _advanceTurn();
    });
  }

  void _advanceTurn() {
    if (_state.phase != GamePhase.round) return;
    int next = _state.currentPlayerIndex + 1;
    if (next >= _state.players.length) {
      _startNextBettingRound();
    } else {
      _state = _state.copyWith(currentPlayerIndex: next);
      _startTurn();
    }
  }

  void _startTurn() {
    if (_state.currentPlayerIndex >= _state.players.length) {
      _startNextBettingRound();
      return;
    }
    final player = _state.currentPlayer;
    if (player.balance <= 0) {
      player.state = "broke";
      _setMessage("${player.name} has no chips and passes.");
      onStateChanged();
      Future.delayed(const Duration(milliseconds: 800), () {
        _advanceTurn();
      });
      return;
    }
    player.cards = [_drawCard(), _drawCard()];
    player.state = "turn";
    int low = min(player.cards[0].value, player.cards[1].value);
    int high = max(player.cards[0].value, player.cards[1].value);
    _setMessage("${player.name}'s turn. Range: $low - $high");
    onStateChanged();
  }

  // ---------- Round Management ----------
  void _startNextBettingRound() {
    // Remove players with zero balance
    final remaining = _state.players.where((p) => p.balance > 0).toList();
    if (remaining.length < 2) {
      String winner = remaining.isNotEmpty ? remaining[0].name : "No one";
      _setMessage("Game over! $winner wins!");
      _state = _state.copyWith(phase: GamePhase.gameOver, players: remaining);
      onStateChanged();
      return;
    }
    // Reset for new betting round
    for (var p in remaining) {
      p.bet = 0;
      p.cards = [];
      p.state = "idle";
    }
    _state = _state.copyWith(
      players: remaining,
      phase: GamePhase.betting,
      currentPlayerIndex: 0,
      bettingPlayerIndex: 0,
    );
    _applyRoundContribution();
    _setMessage(
      "New round. Each player pays ${_state.roundContribution} chips. ${_state.players[0].name}, place your bet.",
    );
    onStateChanged();
  }

  void _applyRoundContribution() {
    int newPot = _state.pot;
    for (var p in _state.players) {
      int amount = min(_state.roundContribution, p.balance);
      p.balance -= amount;
      newPot += amount;
      if (amount < _state.roundContribution) p.state = "lost";
    }
    _state = _state.copyWith(pot: newPot);
  }

  void _resetBets() {
    for (var p in _state.players) {
      p.bet = 0;
    }
  }

  void _resetHands() {
    for (var p in _state.players) {
      p.cards = [];
      p.state = p.balance > 0 ? "idle" : "broke";
    }
  }

  CardModel _drawCard() {
    const suits = ["spades", "hearts", "diamonds", "clubs"];
    const values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
    int idx = _random.nextInt(values.length);
    return CardModel(
      value: values[idx],
      suit: suits[_random.nextInt(suits.length)],
    );
  }

  void _setMessage(String msg) {
    _state = _state.copyWith(lastMessage: msg);
  }
}
