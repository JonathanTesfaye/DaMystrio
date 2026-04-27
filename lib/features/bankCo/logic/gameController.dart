import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/cardModel.dart';
import 'package:flutter_application_1/core/models/gameState.dart';

class GameController extends ChangeNotifier {
  void initalizeDeck() {
    final suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];

    _deck = [];
    for (var suit in suits) {
      for (var value = 1; value <= 13; value++) {
        _deck.add(CardModel(suit: suit, value: value));
      }
    }
    _deck.shuffle();
  }

  late List<CardModel> _deck;
  GameState _state = GameState.initial();

  GameState get state => _state;

  final Random _random = Random();
}
