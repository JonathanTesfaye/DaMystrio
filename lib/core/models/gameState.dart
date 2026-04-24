import 'package:flutter_application_1/core/models/cardModel.dart';

enum GamePhase { dealing, decision, reveal, result }

class GameState {
  final List<CardModel> playerCards;
  final CardModel? thirdCard;
  final GamePhase phase;
  final String result;
  final int playerChips;
  final int currentBet;
  GameState({
    required this.playerCards,
    this.thirdCard,
    required this.phase,
    this.result = "",
    this.currentBet = 100,
    this.playerChips = 1000,
  });
  GameState copyWith({
    List<CardModel>? playerCards,
    CardModel? thirdCard,
    GamePhase? phase,
    String? result,
    int? playerChips,
    int? currentBet,
  }) {
    return GameState(
      playerCards: playerCards ?? this.playerCards,
      thirdCard: thirdCard ?? this.thirdCard,
      phase: phase ?? this.phase,
      result: result ?? this.result,
      playerChips: playerChips ?? this.playerChips,
      currentBet: currentBet ?? this.currentBet,
    );
  }
}
