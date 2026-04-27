import 'package:flutter_application_1/core/models/cardModel.dart';

enum DaBankCoPhase { betting, round, result }

class DaBankCoPlayer {
  final String name;
  int balance;
  int bet;
  List<CardModel> cards;
  String state;
  final bool isAI;
  final int seatIndex;

  DaBankCoPlayer({
    required this.name,
    required this.isAI,
    required this.seatIndex,
    this.balance = 1000,
    this.bet = 0,
    this.cards = const [],
    this.state = "idle",
  });
}

class DaBankCoGameState {
  final int pot;
  final int roundContribution;
  final List<DaBankCoPlayer> players;
  final DaBankCoPhase phase;
  final int turnIndex;
  final String lastMessage;
  final int humanIndex;

  List<CardModel> get humanCards => players[humanIndex].cards;
  CardModel? get thirdCard => (players[humanIndex].cards.length == 3)
      ? players[humanIndex].cards.last
      : null;
  int get humanChips => players[humanIndex].balance;
  int get humanBet => players[humanIndex].bet;

  DaBankCoGameState({
    required this.pot,
    required this.roundContribution,
    required this.players,
    required this.phase,
    required this.turnIndex,
    required this.lastMessage,
    required this.humanIndex,
  });

  DaBankCoGameState copyWith({
    int? pot,
    int? roundContribution,
    List<DaBankCoPlayer>? players,
    DaBankCoPhase? phase,
    int? turnIndex,
    String? lastMessage,
    int? humanIndex,
  }) {
    return DaBankCoGameState(
      pot: pot ?? this.pot,
      roundContribution: roundContribution ?? this.roundContribution,
      players: players ?? this.players,
      phase: phase ?? this.phase,
      turnIndex: turnIndex ?? this.turnIndex,
      lastMessage: lastMessage ?? this.lastMessage,
      humanIndex: humanIndex ?? this.humanIndex,
    );
  }
}
