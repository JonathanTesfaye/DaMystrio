import 'package:flutter_application_1/features/bankCo/logic/models/playerModel.dart';

enum GamePhase { betting, dealing, decision, reveal, result }

class GameState {
  final List<PlayerModel> players;
  final int currentPlayerIndex;
  final int pot;
  final GamePhase phase;
  final String message;
  final bool dealCards;
  final bool revealCards;
  final bool showThirdCard;

  GameState({
    required this.players,
    this.currentPlayerIndex = 0,
    this.pot = 0,
    this.phase = GamePhase.betting,
    this.message = "",
    this.dealCards = false,
    this.revealCards = false,
    this.showThirdCard = false,
  });

  GameState copyWith({
    List<PlayerModel>? players,
    int? currentPlayerIndex,
    int? pot,
    GamePhase? phase,
    String? message,
    bool? dealCards,
    bool? revealCards,
    bool? showThirdCard,
  }) {
    return GameState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      pot: pot ?? this.pot,
      phase: phase ?? this.phase,
      message: message ?? this.message,
      dealCards: dealCards ?? this.dealCards,
      revealCards: revealCards ?? this.revealCards,
      showThirdCard: showThirdCard ?? this.showThirdCard,
    );
  }
}
