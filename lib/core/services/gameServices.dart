import '../models/cardModel.dart';

class GameService {
  List<CardModel> deck = [];

  List<CardModel> createDeck() {
    List<String> suits = ['spades', 'hearts', 'diamonds', 'clubs'];
    List<CardModel> newDeck = [];

    for (String suit in suits) {
      for (int value = 1; value <= 13; value++) {
        newDeck.add(CardModel(value: value, suit: suit));
      }
    }
    return newDeck;
  }

  void initializeDeck() {
    deck = createDeck();
    deck.shuffle();
  }

  List<CardModel> dealTwoCards() {
    return [deck.removeLast(), deck.removeLast()];
  }

  CardModel drawThirdCard() {
    return deck.removeLast();
  }

  bool isWin(CardModel first, CardModel second, CardModel third) {
    int minValue = first.value < second.value ? first.value : second.value;
    int maxValue = first.value > second.value ? first.value : second.value;
    return third.value > minValue && third.value < maxValue;
  }
}
