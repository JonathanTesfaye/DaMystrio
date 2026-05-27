import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/features/bankCo%20Online/logic/OnlineGameService.dart';
import 'package:flutter_application_1/features/bankCo%20Online/logic/OnlineMatchState.dart';
import 'package:flutter_application_1/features/bankCo%20Online/logic/firebaseOnlineGameService.dart';

class OnlineMatchController {
  late OnlineGameService _service;
  late OnlineMatchState _uiState;
  final VoidCallback onStateChanged;
  StreamSubscription<OnlineMatchState>? _subscription;

  OnlineMatchController({
    required this.onStateChanged,
    required String tableId,
    required String userId,
  }) {
    _service = FirebaseOnlineGameService(tableId: tableId, userId: userId);
    _uiState = _emptyState();
    _subscription = _service.gameStateStream.listen(_onGameStateChanged);
  }
  Future<void> dealCardsToPlayer(String playerId) async {
    if (_service is FirebaseOnlineGameService) {
      await (_service as FirebaseOnlineGameService).dealCardsToPlayer(playerId);
    }
  }

  OnlineMatchState get state => _uiState;

  void setupNewGame(List<String> names) {}

  bool placeBet(int amount) {
    if (_uiState.phase != GamePhase.betting) return false;

    // Find current user's player by name (or we could pass userId if OnlinePlayer had id)
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;
    final currentPlayer = _uiState.players.firstWhere(
      (p) => p.name == (currentUser.displayName ?? currentUser.email ?? ''),
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
    if (currentPlayer.name.isEmpty) return false;
    if (amount <= 0 || amount > currentPlayer.balance) return false;

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

  void _onGameStateChanged(OnlineMatchState gameState) {
    print(
      "New state received: phase=${gameState.phase}, players bet: ${gameState.players.map((p) => p.bet)}",
    );
    _uiState = gameState;
    onStateChanged();
  }

  OnlineMatchState _emptyState() {
    return OnlineMatchState(
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
