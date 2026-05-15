import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/data/model/game.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/logic/gameService.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/logic/localJSONGameService.dart';
import 'da_bank_co_PnP_state.dart';
import 'package:flutter_application_1/core/models/cardModel.dart';

class PnPController {
  late GameService _service;
  late PnPGameState _uiState;
  final VoidCallback onStateChanged;
  StreamSubscription<OnlineGameState>? _subscription;

  PnPController({required this.onStateChanged}) {
    _service = LocalJsonGameService();
    _uiState = _emptyState();
    _subscription = _service.gameStateStream.listen(_onGameStateChanged);
  }

  PnPGameState get state => _uiState;

  void setupNewGame(List<String> names) {
    _service.startNewGame(names);
  }

  bool placeBet(int amount) {
    if (_uiState.phase != GamePhase.betting) return false;
    if (_uiState.bettingPlayerIndex >= _uiState.players.length) return false;
    final player = _uiState.players[_uiState.bettingPlayerIndex];
    if (amount <= 0 || amount > player.balance) return false;
    _service.placeBet(amount);
    return true;
  }

  void bankCo() {
    if (_uiState.phase == GamePhase.round) _service.bankCo();
  }

  void forLess(int amount) {
    if (_uiState.phase == GamePhase.round) _service.forLess(amount);
  }

  void passTurn() {
    if (_uiState.phase == GamePhase.round) _service.pass();
  }

  void _onGameStateChanged(OnlineGameState gameState) {
    _uiState = _convertOnlineToUiState(gameState);
    onStateChanged();
  }

  PnPGameState _convertOnlineToUiState(OnlineGameState gameState) {
    // Convert players
    final players = <PnPPlayer>[];
    for (int i = 0; i < gameState.players.length; i++) {
      final p = gameState.players[i];
      players.add(
        PnPPlayer(
          name: p.name,
          seatIndex: p.seatPosition,
          balance: p.remainingChips,
          bet: p.betAmount ?? 0,
          cards: p.draw
              .map((card) => CardModel(value: card.value, suit: card.suit))
              .toList(),
          state: _determinePlayerState(p, gameState),
        ),
      );
    }

    // Determine game phase
    GamePhase phase;
    if (gameState.status == 'finished') {
      phase = GamePhase.gameOver;
    } else if (gameState.phase == 'betting') {
      phase = GamePhase.betting;
    } else if (gameState.phase == 'drawing') {
      phase = GamePhase.round;
    } else {
      phase = GamePhase.setup;
    }

    // Indices
    int currentPlayerIndex = 0;
    int bettingPlayerIndex = 0;
    if (phase == GamePhase.round) {
      currentPlayerIndex = gameState.gameState.activePlayerIndex;
    } else if (phase == GamePhase.betting) {
      bettingPlayerIndex = gameState.gameState.activePlayerIndex;
    }

    // Generate message
    String message = _generateMessage(gameState);

    return PnPGameState(
      pot: gameState.round.potValue,
      roundContribution: gameState.round.roundContribution,
      players: players,
      phase: phase,
      currentPlayerIndex: currentPlayerIndex,
      bettingPlayerIndex: bettingPlayerIndex,
      lastMessage: message,
    );
  }

  String _determinePlayerState(Player p, OnlineGameState gameState) {
    if (p.isEliminated) return 'broke';
    if (gameState.phase == 'drawing' &&
        gameState.gameState.activePlayerIndex == gameState.players.indexOf(p)) {
      return 'turn';
    }
    return 'idle';
  }

  String _generateMessage(OnlineGameState gameState) {
    // Check for win/loss messages from last action
    for (var p in gameState.players) {
      if (p.stats.wins > 0 && p.status.decision != null) {
        return "${p.name} won ${p.stats.wins} chips!";
      }
      if (p.stats.losses > 0 && p.status.decision != null) {
        return "${p.name} lost ${p.stats.losses} chips.";
      }
    }
    // Fallback
    if (gameState.phase == 'betting') {
      final player = gameState.players[gameState.gameState.activePlayerIndex];
      return "${player.name}, place your bet.";
    } else if (gameState.phase == 'drawing') {
      final player = gameState.players[gameState.gameState.activePlayerIndex];
      if (player.draw.length == 2) {
        final low = player.draw[0].value < player.draw[1].value
            ? player.draw[0].value
            : player.draw[1].value;
        final high = player.draw[0].value > player.draw[1].value
            ? player.draw[0].value
            : player.draw[1].value;
        return "${player.name}'s turn. Range: $low - $high";
      }
      return "${player.name}'s turn.";
    } else if (gameState.status == 'finished') {
      final winner = gameState.gameState.winner;
      return "Game over! ${winner?.name ?? "Someone"} wins!";
    }
    return "Game started!";
  }

  PnPGameState _emptyState() {
    return PnPGameState(
      pot: 0,
      roundContribution: 0,
      players: [],
      phase: GamePhase.setup,
      currentPlayerIndex: 0,
      bettingPlayerIndex: 0,
      lastMessage: '',
    );
  }

  void dispose() {
    _subscription?.cancel();
    _service.dispose();
  }
}
