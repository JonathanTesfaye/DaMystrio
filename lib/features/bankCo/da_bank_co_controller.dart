import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/cardModel.dart';
import 'package:flutter_application_1/features/bankCo/da_bank_co_state.dart';

class DaBankCoController {
  DaBankCoGameState _state;
  final VoidCallback onStateChanged;
  final Random _random = Random();

  DaBankCoController({required this.onStateChanged})
    : _state = DaBankCoGameState(
        pot: 0,
        roundContribution: 100,
        players: [],
        phase: DaBankCoPhase.betting,
        turnIndex: 0,
        lastMessage: "Start a new game.",
        humanIndex: 3,
      );

  DaBankCoGameState get state => _state;

  // ---------- Public API ----------
  void startNewGame({int startingPot = 0, int? customRoundContribution}) {
    if (customRoundContribution != null) {
      _state = _state.copyWith(roundContribution: customRoundContribution);
    }
    final players = [
      DaBankCoPlayer(
        name: "Liu Che",
        isAI: true,
        seatIndex: 0,
        balance: 1250000,
      ),
      DaBankCoPlayer(
        name: "Scipio",
        isAI: true,
        seatIndex: 1,
        balance: 1000000,
      ),
      DaBankCoPlayer(name: "Arthur", isAI: true, seatIndex: 2, balance: 900000),
      DaBankCoPlayer(name: "You", isAI: false, seatIndex: 4, balance: 1000),
    ];
    _state = _state.copyWith(
      pot: startingPot,
      players: players,
      phase: DaBankCoPhase.betting,
      turnIndex: 0,
      lastMessage: "New game. Place your bet, then press Begin Round.",
    );
    _applyRoundContribution();
    _autoBetAIPlayers();
    onStateChanged();
  }

  void placeHumanBet(int amount) {
    if (_state.phase != DaBankCoPhase.betting) {
      _setMessage("Betting is closed.");
      return;
    }
    final human = _state.players[_state.humanIndex];
    if (human.balance <= 0) {
      _setMessage("You have no chips.");
      return;
    }
    if (amount <= 0 || amount > human.balance) {
      _setMessage("Invalid bet amount.");
      return;
    }
    human.bet = amount;
    _setMessage("Your bet placed. Press Begin Round.");
    onStateChanged();
  }

  void finishBettingAndBegin() {
    if (_state.phase != DaBankCoPhase.betting) {
      _setMessage("Round already in progress.");
      return;
    }
    final human = _state.players[_state.humanIndex];
    if (human.balance > 0 && human.bet == 0) {
      _setMessage("Place your bet first.");
      return;
    }
    _state = _state.copyWith(phase: DaBankCoPhase.round, turnIndex: 0);
    _resetHandsForRound();
    _startTurn();
  }

  void bankCo() {
    final player = _state.players[_state.turnIndex];
    if (_state.phase != DaBankCoPhase.round || player.isAI) return;
    // Must have enough chips to risk the entire pot
    if (player.balance < _state.pot) {
      _setMessage(
        "Insufficient chips to call Bank Co (need ${_state.pot} chips).",
      );
      onStateChanged();
      return;
    }
    _resolvePlay(_state.pot, "bankco");
  }

  void forLess(int amount) {
    final player = _state.players[_state.turnIndex];
    if (_state.phase != DaBankCoPhase.round || player.isAI) return;
    if (amount <= 0) {
      _setMessage("Enter a valid For Less amount.");
      return;
    }
    // Can't risk more than pot or more than player's balance
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
    final player = _state.players[_state.turnIndex];
    if (_state.phase != DaBankCoPhase.round || player.isAI) return;
    player.state = "passed";
    player.cards = [];
    _setMessage("${player.name} passed.");
    onStateChanged();
    Future.delayed(const Duration(milliseconds: 800), () {
      _state = _state.copyWith(turnIndex: _state.turnIndex + 1);
      _startTurn();
    });
  }

  // ---------- Internal Logic ----------
  CardModel _drawCard() {
    const suits = ["spades", "hearts", "diamonds", "clubs"];
    const values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
    int idx = _random.nextInt(values.length);
    return CardModel(
      value: values[idx],
      suit: suits[_random.nextInt(suits.length)],
    );
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

  void _autoBetAIPlayers() {
    for (int i = 0; i < 3; i++) {
      var ai = _state.players[i];
      if (ai.balance <= 0) {
        ai.bet = 0;
        ai.state = "broke";
        continue;
      }
      int minBet = 25;
      int maxBet = min(150, ai.balance);
      ai.bet = minBet + _random.nextInt(maxBet - minBet + 1);
    }
    onStateChanged();
  }

  void _resetHandsForRound() {
    for (var p in _state.players) {
      p.cards = [];
      p.state = p.balance > 0 ? "idle" : "broke";
    }
  }

  void _startTurn() {
    if (_state.turnIndex >= _state.players.length) {
      _startNextBettingRound();
      return;
    }
    var player = _state.players[_state.turnIndex];
    if (player.balance <= 0) {
      player.state = "broke";
      _setMessage("${player.name} has no chips and passes.");
      onStateChanged();
      Future.delayed(const Duration(milliseconds: 800), () {
        _state = _state.copyWith(turnIndex: _state.turnIndex + 1);
        _startTurn();
      });
      return;
    }
    player.cards = [_drawCard(), _drawCard()];
    player.state = "turn";
    int low = min(player.cards[0].value, player.cards[1].value);
    int high = max(player.cards[0].value, player.cards[1].value);
    _setMessage("${player.name}'s turn. Range: $low - $high");
    onStateChanged();

    if (player.isAI) {
      Future.delayed(const Duration(milliseconds: 1200), _aiTakeTurn);
    } else {
      _setMessage("Your turn: Bank Co, For Less, or Pass.");
    }
  }

  void _resolvePlay(int riskAmount, String mode) {
    var player = _state.players[_state.turnIndex];
    if (_state.phase != DaBankCoPhase.round || player.cards.length != 2) return;

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
      // WIN
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
        // For Less win: player wins the riskAmount from pot
        player.balance += riskAmount;
        _state = _state.copyWith(pot: _state.pot - riskAmount);
        player.state = "won";
        _setMessage("${player.name} wins $riskAmount chips!");
      }
    } else {
      // LOSE
      player.balance -= riskAmount;
      _state = _state.copyWith(pot: _state.pot + riskAmount);
      player.state = "lost";
      if (isBankCo) {
        _setMessage(
          "${player.name} called Bank Co and lost $riskAmount chips.",
        );
      } else {
        _setMessage("${player.name} loses $riskAmount chips.");
      }
    }
    onStateChanged();
    Future.delayed(const Duration(milliseconds: 1800), () {
      player.cards = [];
      _state = _state.copyWith(turnIndex: _state.turnIndex + 1);
      _startTurn();
    });
  }

  void _aiTakeTurn() {
    var player = _state.players[_state.turnIndex];
    if (!player.isAI || _state.phase != DaBankCoPhase.round) return;
    if (player.balance <= 0) {
      player.state = "broke";
      _setMessage("${player.name} has no chips and passes.");
      onStateChanged();
      Future.delayed(const Duration(milliseconds: 800), () {
        player.cards = [];
        _state = _state.copyWith(turnIndex: _state.turnIndex + 1);
        _startTurn();
      });
      return;
    }
    int a = player.cards[0].value;
    int b = player.cards[1].value;
    int gap = (a - b).abs() - 1;
    if (gap <= 0) {
      player.state = "passed";
      _setMessage("${player.name} passed.");
      onStateChanged();
      Future.delayed(const Duration(milliseconds: 1000), () {
        player.cards = [];
        _state = _state.copyWith(turnIndex: _state.turnIndex + 1);
        _startTurn();
      });
      return;
    }
    double roll = _random.nextDouble();
    // AI BankCo only if can afford whole pot
    if (gap >= 6 && roll < 0.35 && player.balance >= _state.pot) {
      _resolvePlay(_state.pot, "bankco");
    } else if (gap >= 3 && roll < 0.75) {
      int lessAmount = (_state.pot * 0.25).floor().clamp(25, player.balance);
      if (lessAmount > _state.pot) lessAmount = _state.pot;
      if (lessAmount > 0) {
        _resolvePlay(lessAmount, "less");
      } else {
        player.state = "passed";
        _setMessage("${player.name} passed.");
        onStateChanged();
        Future.delayed(const Duration(milliseconds: 1000), () {
          player.cards = [];
          _state = _state.copyWith(turnIndex: _state.turnIndex + 1);
          _startTurn();
        });
      }
    } else {
      player.state = "passed";
      _setMessage("${player.name} passed.");
      onStateChanged();
      Future.delayed(const Duration(milliseconds: 1000), () {
        player.cards = [];
        _state = _state.copyWith(turnIndex: _state.turnIndex + 1);
        _startTurn();
      });
    }
  }

  void _startNextBettingRound() {
    for (var p in _state.players) {
      p.bet = 0;
      p.cards = [];
      p.state = p.balance > 0 ? "idle" : "broke";
    }
    _state = _state.copyWith(
      phase: DaBankCoPhase.betting,
      turnIndex: 0,
      lastMessage: "New round. Place your bet, then press Begin Round.",
    );
    _applyRoundContribution();
    _autoBetAIPlayers();
    onStateChanged();
  }

  void _setMessage(String msg) {
    _state = _state.copyWith(lastMessage: msg);
  }
}
