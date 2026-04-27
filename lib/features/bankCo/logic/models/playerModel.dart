import 'package:flutter_application_1/core/models/cardModel.dart';
import 'package:flutter_application_1/features/bankCo/logic/models/playerStatus.dart';

class PlayerModel {
  String name;
  String avatar;
  int chips;
  int currentBet;
  List<CardModel> cards;
  PlayerStatus status;

  PlayerModel({
    required this.name,
    required this.avatar,
    required this.chips,
    required this.currentBet,
    this.cards = const [],
    this.status = PlayerStatus.idle,
  });
  PlayerModel copyWith({
    String? name,
    String? avatar,
    int? chips,
    int? currentBet,
    List<CardModel>? cards,
    PlayerStatus? status,
  }) {
    return PlayerModel(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      chips: chips ?? this.chips,
      currentBet: currentBet ?? this.currentBet,
      cards: cards ?? this.cards,
      status: status ?? this.status,
    );
  }
}
