import 'package:flutter_application_1/core/models/cardModel.dart';

enum GamePhase { setup, betting, round, gameOver }

class PnPPlayer {
  final String name;
  int balance;
  int bet;
  List<CardModel> cards;
  String state; // "idle", "turn", "passed", "won", "lost", "broke"
  final int seatIndex;

  PnPPlayer({
    required this.name,
    required this.seatIndex,
    this.balance = 1000,
    this.bet = 0,
    this.cards = const [],
    this.state = "idle",
  });
}

class PnPGameState {
  final int pot;
  final int roundContribution;
  final List<PnPPlayer> players;
  final GamePhase phase;
  final int currentPlayerIndex;
  final int bettingPlayerIndex;
  final String lastMessage;

  PnPPlayer get currentPlayer => players[currentPlayerIndex];
  bool get isBettingComplete => bettingPlayerIndex >= players.length;

  PnPGameState({
    required this.pot,
    required this.roundContribution,
    required this.players,
    required this.phase,
    required this.currentPlayerIndex,
    required this.bettingPlayerIndex,
    required this.lastMessage,
  });

  PnPGameState copyWith({
    int? pot,
    int? roundContribution,
    List<PnPPlayer>? players,
    GamePhase? phase,
    int? currentPlayerIndex,
    int? bettingPlayerIndex,
    String? lastMessage,
  }) {
    return PnPGameState(
      pot: pot ?? this.pot,
      roundContribution: roundContribution ?? this.roundContribution,
      players: players ?? this.players,
      phase: phase ?? this.phase,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      bettingPlayerIndex: bettingPlayerIndex ?? this.bettingPlayerIndex,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
