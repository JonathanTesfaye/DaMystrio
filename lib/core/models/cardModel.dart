class CardModel {
  final int value;
  final String suit;

  const CardModel({required this.value, required this.suit});
}

extension CardModelParsing on CardModel {
  static CardModel fromString(String code) {
    final suitChar = code[code.length - 1];
    final rankStr = code.substring(0, code.length - 1);
    String suit;
    switch (suitChar) {
      case 'S':
        suit = 'spades';
        break;
      case 'H':
        suit = 'hearts';
        break;
      case 'D':
        suit = 'diamonds';
        break;
      case 'C':
        suit = 'clubs';
        break;
      default:
        suit = 'spades';
    }
    int value;
    switch (rankStr) {
      case 'A':
        value = 1;
        break;
      case 'J':
        value = 11;
        break;
      case 'Q':
        value = 12;
        break;
      case 'K':
        value = 13;
        break;
      default:
        value = int.parse(rankStr);
    }
    return CardModel(value: value, suit: suit);
  }
}
