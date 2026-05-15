import 'dart:async';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/data/model/game.dart';

abstract class GameService {
  /// Starts a new game with the given player names.
  Future<void> startNewGame(List<String> playerNames);

  /// Places a bet during betting phase.
  Future<bool> placeBet(int amount);

  /// Calls "Bank Co" during the drawing phase.
  Future<bool> bankCo();

  /// Bets "For Less" with a given risk amount.
  Future<bool> forLess(int amount);

  /// Passes the turn.
  Future<bool> pass();

  /// Stream of game state (the full JSON table).
  Stream<OnlineGameState> get gameStateStream;

  /// Current game state (synchronous getter).
  OnlineGameState get currentGameState;

  /// Disposes resources.
  void dispose();
}
