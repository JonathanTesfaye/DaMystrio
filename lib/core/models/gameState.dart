import 'package:flutter_application_1/features/bankCo/logic/models/playerModel.dart';

enum GamePhase { betting, dealing, result }

class GameState {
  final List<PlayerModel> players;
  final int currentPlayerIndex;
  final int pot;
  final GamePhase phase;
  final String message;

  GameState({
    required this.players,
    this.currentPlayerIndex = 0,
    this.pot = 0,
    this.phase = GamePhase.betting,
    this.message = "",
  });

  GameState copyWith({
    List<PlayerModel>? players,
    int? currentPlayerIndex,
    int? pot,
    GamePhase? phase,
    String? message,
  }) {
    return GameState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      pot: pot ?? this.pot,
      phase: phase ?? this.phase,
      message: message ?? this.message,
    );
  }
}
