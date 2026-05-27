import 'package:flutter_application_1/features/bankCo%20Online/model/cardModelOnline.dart';

enum GamePhase { setup, betting, round, gameOver }

class OnlinePlayer {
  final String id;
  final String name;
  final int seatIndex;
  final int balance;
  final int bet;
  final List<CardModelOnline> cards;
  final String state; // 'idle', 'turn', 'broke', 'thinking'

  OnlinePlayer({
    required this.id,
    required this.name,
    required this.seatIndex,
    required this.balance,
    required this.bet,
    required this.cards,
    required this.state,
  });

  OnlinePlayer copyWith({
    String? id,
    String? name,
    int? seatIndex,
    int? balance,
    int? bet,
    List<CardModelOnline>? cards,
    String? state,
  }) {
    return OnlinePlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      seatIndex: seatIndex ?? this.seatIndex,
      balance: balance ?? this.balance,
      bet: bet ?? this.bet,
      cards: cards ?? this.cards,
      state: state ?? this.state,
    );
  }
}

class OnlineMatchState {
  final int pot;
  final int roundContribution;
  final List<OnlinePlayer> players;

  final GamePhase phase;
  final int currentPlayerIndex;
  final int bettingPlayerIndex;
  final String lastMessage;
  final int currentRound;
  final int totalRounds;
  final String? winnerName;
  final int potValue; // alias for pot (for compatibility)

  OnlineMatchState({
    required this.pot,
    required this.roundContribution,
    required this.players,
    required this.phase,
    required this.currentPlayerIndex,
    required this.bettingPlayerIndex,
    required this.lastMessage,
    this.currentRound = 1,
    this.totalRounds = 3,
    this.winnerName,
    this.potValue = 0,
  });

  OnlinePlayer get currentPlayer {
    if (currentPlayerIndex < 0 || currentPlayerIndex >= players.length)
      return players.first;
    return players[currentPlayerIndex];
  }

  OnlinePlayer get bettingPlayer {
    if (bettingPlayerIndex < 0 || bettingPlayerIndex >= players.length)
      return players.first;
    return players[bettingPlayerIndex];
  }

  OnlineMatchState copyWith({
    int? pot,
    int? roundContribution,
    List<OnlinePlayer>? players,
    GamePhase? phase,
    int? currentPlayerIndex,
    int? bettingPlayerIndex,
    String? lastMessage,
    int? currentRound,
    int? totalRounds,
    String? winnerName,
    int? potValue,
  }) {
    return OnlineMatchState(
      pot: pot ?? this.pot,
      roundContribution: roundContribution ?? this.roundContribution,
      players: players ?? this.players,
      phase: phase ?? this.phase,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      bettingPlayerIndex: bettingPlayerIndex ?? this.bettingPlayerIndex,
      lastMessage: lastMessage ?? this.lastMessage,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      winnerName: winnerName ?? this.winnerName,
      potValue: potValue ?? this.potValue,
    );
  }
}

// ---------- Firebase helper models ----------
class OnlineMatchMetadata {
  final int maxPlayers;
  final int totalPlayers;
  final int startConsentCount;
  final String status;
  final int startingChips;
  final String gameName;
  final int roundContribution;
  final int createdAt;
  final int updatedAt;

  OnlineMatchMetadata({
    required this.maxPlayers,
    required this.totalPlayers,
    required this.startConsentCount,
    required this.status,
    required this.startingChips,
    required this.gameName,
    required this.roundContribution,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OnlineMatchMetadata.fromMap(Map<String, dynamic> map) {
    return OnlineMatchMetadata(
      maxPlayers: (map['maxPlayers'] as num?)?.toInt() ?? 4,
      totalPlayers: (map['totalPlayers'] as num?)?.toInt() ?? 0,
      startConsentCount: (map['startConsentCount'] as num?)?.toInt() ?? 0,
      status: map['status'] ?? 'waiting',
      startingChips: (map['startingChips'] as num?)?.toInt() ?? 1000,
      gameName: map['gameName'] ?? '',
      roundContribution: (map['roundContribution'] as num?)?.toInt() ?? 200,
      createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updatedAt'] as num?)?.toInt() ?? 0,
    );
  }
}

class OnlineRound {
  final int totalRounds;
  final int currentRound;
  final String currentPlayerId;

  OnlineRound({
    required this.totalRounds,
    required this.currentRound,
    required this.currentPlayerId,
  });

  factory OnlineRound.fromMap(Map<String, dynamic> map) {
    return OnlineRound(
      totalRounds: (map['totalRounds'] as num?)?.toInt() ?? 3,
      currentRound: (map['currentRound'] as num?)?.toInt() ?? 1,
      currentPlayerId: map['currentPlayerId'] ?? '',
    );
  }
}

class OnlineGameStateDetails {
  final String? winner;
  final int potValue;
  final List<String> eliminatedPlayerIds;

  OnlineGameStateDetails({
    this.winner,
    required this.potValue,
    this.eliminatedPlayerIds = const [],
  });

  factory OnlineGameStateDetails.fromMap(Map<String, dynamic> map) {
    return OnlineGameStateDetails(
      winner: map['winner'],
      potValue: (map['potValue'] as num?)?.toInt() ?? 0,
      eliminatedPlayerIds:
          (map['eliminatedPlayers'] as List<dynamic>?)
              ?.map((e) => e['playerId'] as String)
              .toList() ??
          [],
    );
  }
}
