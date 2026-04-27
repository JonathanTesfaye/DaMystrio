import 'package:flutter_application_1/core/models/cardModel.dart';

class GameRules {
  static bool isWin(CardModel c1, CardModel c2, CardModel c3) {
    final low = c1.value < c2.value ? c1.value : c2.value;
    final high = c1.value > c2.value ? c1.value : c2.value;

    return c3.value > low && c3.value < high;
  }

  static bool resolveNormalPlay({
    required CardModel c1,
    required CardModel c2,
    required CardModel c3,
  }) {
    return isWin(c1, c2, c3);
  }

  static bool resolveBankCo({
    required CardModel c1,
    required CardModel c2,
    required CardModel c3,
  }) {
    return isWin(c1, c2, c3);
  }
}
