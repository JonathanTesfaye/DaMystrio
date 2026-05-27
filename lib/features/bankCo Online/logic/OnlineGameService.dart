import 'dart:async';
import 'package:flutter_application_1/features/bankCo%20Online/logic/OnlineMatchState.dart';

abstract class OnlineGameService {
  Stream<OnlineMatchState> get gameStateStream;

  // Local mock methods
  Future<void> startNewGame(List<String> playerNames);

  // Game actions
  Future<bool> placeBet(int amount);
  Future<void> bankCo();
  Future<void> forLess(int amount);
  Future<void> pass();

  // Online-specific methods (for Firebase implementation)
  Future<void> joinTable(String tableId, String userId, String userName);
  Future<void> setReady(String tableId, String userId);
  Future<void> leaveGame(String tableId, String userId);

  void dispose();
}
