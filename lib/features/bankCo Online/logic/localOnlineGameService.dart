import 'dart:async';
import 'package:flutter_application_1/features/bankCo%20Online/logic/OnlineGameService.dart';
import 'package:flutter_application_1/features/bankCo%20Online/logic/OnlineMatchState.dart';
import 'package:flutter_application_1/features/bankCo%20Online/model/cardModelOnline.dart';

class LocalOnlineGameService implements OnlineGameService {
  final _stateController = StreamController<OnlineMatchState>.broadcast();
  late OnlineMatchState _currentState;
  List<String> _playerNames = [];
  int _currentRound = 1;
  int _pot = 0;

  @override
  Stream<OnlineMatchState> get gameStateStream => _stateController.stream;

  @override
  Future<void> startNewGame(List<String> playerNames) async {
    _playerNames = playerNames;
    _currentRound = 1;
    _pot = 0;

    final players = <OnlinePlayer>[];
    for (int i = 0; i < playerNames.length; i++) {
      players.add(
        OnlinePlayer(
          id: '',
          name: playerNames[i],
          seatIndex: i,
          balance: 1000,
          bet: 0,
          cards: [],
          state: i == 0 ? 'turn' : 'idle',
        ),
      );
    }

    _currentState = OnlineMatchState(
      pot: 0,
      roundContribution: 200,
      players: players,
      phase: GamePhase.round,
      currentPlayerIndex: 0,
      bettingPlayerIndex: 0,
      lastMessage: 'Game started! ${players[0].name}\'s turn',
      currentRound: 1,
      totalRounds: 3,
    );

    _stateController.add(_currentState);
    _startRound();
  }

  void _startRound() {
    final updatedPlayers = List<OnlinePlayer>.from(_currentState.players);
    for (int i = 0; i < updatedPlayers.length; i++) {
      updatedPlayers[i] = updatedPlayers[i].copyWith(
        cards: [
          CardModelOnline.simple(suit: 'hearts', value: 10),
          CardModelOnline.simple(suit: 'spades', value: 11),
        ],
        state: i == 0 ? 'turn' : 'idle',
      );
    }
    _currentState = _currentState.copyWith(
      players: updatedPlayers,
      phase: GamePhase.round,
      currentPlayerIndex: 0,
      lastMessage:
          'Round $_currentRound started. ${updatedPlayers[0].name}\'s turn',
    );
    _stateController.add(_currentState);
  }

  @override
  Future<bool> placeBet(int amount) async {
    if (_currentState.phase != GamePhase.betting) return false;
    final player = _currentState.bettingPlayer;
    if (amount > player.balance) return false;

    final newBalance = player.balance - amount;
    final updatedPlayers = List<OnlinePlayer>.from(_currentState.players);
    final idx = _currentState.bettingPlayerIndex;
    updatedPlayers[idx] = player.copyWith(balance: newBalance, bet: amount);
    _pot += amount;

    _currentState = _currentState.copyWith(
      players: updatedPlayers,
      pot: _pot,
      lastMessage: '${player.name} bet $amount',
    );
    _stateController.add(_currentState);

    _advanceBetting();
    return true;
  }

  void _advanceBetting() {
    int next = _currentState.bettingPlayerIndex + 1;
    if (next >= _currentState.players.length) {
      _currentState = _currentState.copyWith(
        phase: GamePhase.round,
        bettingPlayerIndex: 0,
        lastMessage: 'Betting finished. Starting round.',
      );
      _stateController.add(_currentState);
      _startRound();
    } else {
      _currentState = _currentState.copyWith(
        bettingPlayerIndex: next,
        lastMessage: '${_currentState.players[next].name}\'s turn to bet',
      );
      _stateController.add(_currentState);
    }
  }

  @override
  Future<void> bankCo() async {
    if (_currentState.phase != GamePhase.round) return;
    final player = _currentState.currentPlayer;
    final amount = _currentState.roundContribution * 2;
    if (amount > player.balance) {
      _stateController.add(
        _currentState.copyWith(lastMessage: 'Not enough chips for Bank Co!'),
      );
      return;
    }
    _resolveAction(amount, 'Bank Co');
  }

  @override
  Future<void> forLess(int amount) async {
    if (_currentState.phase != GamePhase.round) return;
    _resolveAction(amount, 'For Less');
  }

  @override
  Future<void> pass() async {
    if (_currentState.phase != GamePhase.round) return;
    _resolveAction(0, 'Pass');
  }

  void _resolveAction(int amount, String actionName) {
    final player = _currentState.currentPlayer;
    final newBalance = player.balance - amount;
    final updatedPlayers = List<OnlinePlayer>.from(_currentState.players);
    final idx = _currentState.currentPlayerIndex;
    updatedPlayers[idx] = player.copyWith(balance: newBalance, bet: amount);
    _pot += amount;

    _currentState = _currentState.copyWith(
      players: updatedPlayers,
      pot: _pot,
      lastMessage:
          '${player.name} $actionName ${amount > 0 ? '($amount chips)' : ''}',
    );
    _stateController.add(_currentState);

    int nextIdx =
        (_currentState.currentPlayerIndex + 1) % _currentState.players.length;
    if (nextIdx == 0) {
      _endRound();
    } else {
      _currentState = _currentState.copyWith(
        currentPlayerIndex: nextIdx,
        lastMessage: '${_currentState.players[nextIdx].name}\'s turn',
      );
      _stateController.add(_currentState);
    }
  }

  void _endRound() {
    int bestTotal = -1;
    int winnerIdx = 0;
    for (int i = 0; i < _currentState.players.length; i++) {
      int total = _currentState.players[i].cards.fold(
        0,
        (sum, card) => sum + card.value,
      );
      if (total > bestTotal) {
        bestTotal = total;
        winnerIdx = i;
      }
    }
    final winnerName = _currentState.players[winnerIdx].name;
    final prize = _pot;
    final updatedPlayers = List<OnlinePlayer>.from(_currentState.players);
    updatedPlayers[winnerIdx] = updatedPlayers[winnerIdx].copyWith(
      balance: updatedPlayers[winnerIdx].balance + prize,
    );

    _currentState = _currentState.copyWith(
      players: updatedPlayers,
      pot: 0,
      lastMessage:
          '$winnerName wins round $_currentRound and takes $prize chips!',
    );
    _stateController.add(_currentState);

    if (_currentRound < _currentState.totalRounds) {
      _currentRound++;
      Future.delayed(const Duration(seconds: 2), () {
        _startRound();
      });
    } else {
      int maxChips = -1;
      int gameWinnerIdx = 0;
      for (int i = 0; i < _currentState.players.length; i++) {
        if (_currentState.players[i].balance > maxChips) {
          maxChips = _currentState.players[i].balance;
          gameWinnerIdx = i;
        }
      }
      _currentState = _currentState.copyWith(
        phase: GamePhase.gameOver,
        winnerName: _currentState.players[gameWinnerIdx].name,
        lastMessage:
            'Game Over! ${_currentState.players[gameWinnerIdx].name} wins the match!',
      );
      _stateController.add(_currentState);
    }
  }

  // Online stubs
  @override
  Future<void> joinTable(
    String tableId,
    String userId,
    String userName,
  ) async {}
  @override
  Future<void> setReady(String tableId, String userId) async {}
  @override
  Future<void> leaveGame(String tableId, String userId) async {}

  @override
  void dispose() {
    _stateController.close();
  }
}
