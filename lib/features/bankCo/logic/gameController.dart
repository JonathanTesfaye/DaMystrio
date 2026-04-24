import 'package:flutter_application_1/core/models/gameState.dart';
import 'package:flutter_application_1/core/services/gameServices.dart';

class GameController {
  GameState _state;
  final GameService _gameService;

  GameController(this._gameService, this._state);

  GameState get state => _state;

  void executeTake() {
    final third = _gameService.drawThirdCard();

    final first = _state.playerCards[0];
    final second = _state.playerCards[1];

    // Special case: pair = auto loss
    bool isPair = first.value == second.value;

    bool win = false;

    if (!isPair) {
      win = _gameService.isWin(first, second, third);
    }

    int newChips = _state.playerChips;

    if (win) {
      newChips += _state.currentBet;
    } else {
      newChips -= _state.currentBet;
    }

    _state = _state.copyWith(
      thirdCard: third,
      phase: GamePhase.result,
      result: newChips <= 0 ? "Game Over" : (win ? "You Win!" : "You Lose!"),
      playerChips: newChips < 0 ? 0 : newChips,
    );
  }
}
