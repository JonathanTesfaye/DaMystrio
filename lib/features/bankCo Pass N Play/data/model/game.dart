// Matches the agreed JSON structure
class OnlineGameState {
  String gameId;
  String createdAt;
  String updatedAt;
  String status; // "waiting", "playing", "finished"
  String phase; // "betting", "drawing", "ended"  (our addition)
  Round round;
  List<CardItem> cards;
  List<Player> players;
  GameStateInfo gameState;

  OnlineGameState({
    required this.gameId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.phase,
    required this.round,
    required this.cards,
    required this.players,
    required this.gameState,
  });

  factory OnlineGameState.fromJson(
    Map<String, dynamic> json,
  ) => OnlineGameState(
    gameId: json['gameId'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    status: json['status'],
    phase: json['phase'] ?? 'betting', // fallback
    round: Round.fromJson(json['round']),
    cards: (json['cards'] as List).map((e) => CardItem.fromJson(e)).toList(),
    players: (json['players'] as List).map((e) => Player.fromJson(e)).toList(),
    gameState: GameStateInfo.fromJson(json['gameState']),
  );

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'status': status,
    'phase': phase,
    'round': round.toJson(),
    'cards': cards.map((e) => e.toJson()).toList(),
    'players': players.map((e) => e.toJson()).toList(),
    'gameState': gameState.toJson(),
  };
}

class Round {
  int roundNumber;
  bool hasBegun;
  int roundCount;
  String? currentPlayerId;
  int potValue;
  int roundContribution;

  Round({
    required this.roundNumber,
    required this.hasBegun,
    required this.roundCount,
    this.currentPlayerId,
    required this.potValue,
    required this.roundContribution,
  });

  factory Round.fromJson(Map<String, dynamic> json) => Round(
    roundNumber: json['roundNumber'],
    hasBegun: json['hasBegun'],
    roundCount: json['roundCount'],
    currentPlayerId: json['currentPlayerId'],
    potValue: json['potValue'],
    roundContribution: json['roundContribution'],
  );

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'hasBegun': hasBegun,
    'roundCount': roundCount,
    'currentPlayerId': currentPlayerId,
    'potValue': potValue,
    'roundContribution': roundContribution,
  };
}

class CardItem {
  String id;
  String suit;
  String label;
  String rank;
  int value;
  String status; // "available" or "dealt"

  CardItem({
    required this.id,
    required this.suit,
    required this.label,
    required this.rank,
    required this.value,
    required this.status,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) => CardItem(
    id: json['id'],
    suit: json['suit'],
    label: json['label'],
    rank: json['rank'],
    value: json['value'],
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'suit': suit,
    'label': label,
    'rank': rank,
    'value': value,
    'status': status,
  };
}

class Player {
  String id;
  String name;
  String avatar;
  int initialChips;
  int remainingChips;
  int? betAmount;
  int seatPosition;
  bool isEliminated;
  bool isConnected;
  PlayerStatus status;
  List<CardItem> draw;
  PlayerStats stats;

  Player({
    required this.id,
    required this.name,
    required this.avatar,
    required this.initialChips,
    required this.remainingChips,
    this.betAmount,
    required this.seatPosition,
    required this.isEliminated,
    required this.isConnected,
    required this.status,
    required this.draw,
    required this.stats,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    avatar: json['avatar'],
    initialChips: json['initialChips'],
    remainingChips: json['remainingChips'],
    betAmount: json['betAmount'],
    seatPosition: json['seatPosition'],
    isEliminated: json['isEliminated'],
    isConnected: json['isConnected'],
    status: PlayerStatus.fromJson(json['status']),
    draw: (json['draw'] as List).map((e) => CardItem.fromJson(e)).toList(),
    stats: PlayerStats.fromJson(json['stats']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'initialChips': initialChips,
    'remainingChips': remainingChips,
    'betAmount': betAmount,
    'seatPosition': seatPosition,
    'isEliminated': isEliminated,
    'isConnected': isConnected,
    'status': status.toJson(),
    'draw': draw.map((e) => e.toJson()).toList(),
    'stats': stats.toJson(),
  };
}

class PlayerStatus {
  String state; // "thinking", "betting", "drawing", etc.
  String? decision; // "bank co", "for less", "passed"

  PlayerStatus({required this.state, this.decision});

  factory PlayerStatus.fromJson(Map<String, dynamic> json) =>
      PlayerStatus(state: json['state'], decision: json['decision']);

  Map<String, dynamic> toJson() => {'state': state, 'decision': decision};
}

class PlayerStats {
  int wins;
  int losses;

  PlayerStats({required this.wins, required this.losses});

  factory PlayerStats.fromJson(Map<String, dynamic> json) =>
      PlayerStats(wins: json['wins'], losses: json['losses']);

  Map<String, dynamic> toJson() => {'wins': wins, 'losses': losses};
}

class GameStateInfo {
  int activePlayerIndex;
  Winner? winner;
  List<EliminatedPlayer> eliminatedPlayers;

  GameStateInfo({
    required this.activePlayerIndex,
    this.winner,
    required this.eliminatedPlayers,
  });

  factory GameStateInfo.fromJson(Map<String, dynamic> json) => GameStateInfo(
    activePlayerIndex: json['activePlayerIndex'],
    winner: json['winner'] != null ? Winner.fromJson(json['winner']) : null,
    eliminatedPlayers: (json['eliminatedPlayers'] as List)
        .map((e) => EliminatedPlayer.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'activePlayerIndex': activePlayerIndex,
    'winner': winner?.toJson(),
    'eliminatedPlayers': eliminatedPlayers.map((e) => e.toJson()).toList(),
  };
}

class Winner {
  String playerId;
  String name;

  Winner({required this.playerId, required this.name});

  factory Winner.fromJson(Map<String, dynamic> json) =>
      Winner(playerId: json['playerId'], name: json['name']);

  Map<String, dynamic> toJson() => {'playerId': playerId, 'name': name};
}

class EliminatedPlayer {
  String playerId;
  int eliminatedAtRound;

  EliminatedPlayer({required this.playerId, required this.eliminatedAtRound});

  factory EliminatedPlayer.fromJson(Map<String, dynamic> json) =>
      EliminatedPlayer(
        playerId: json['playerId'],
        eliminatedAtRound: json['eliminatedAtRound'],
      );

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'eliminatedAtRound': eliminatedAtRound,
  };
}
