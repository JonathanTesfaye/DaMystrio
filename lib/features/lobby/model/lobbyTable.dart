class LobbyTable {
  final String tableId;
  final String status;
  final int maxPlayers;
  final int roundContribution;
  final String gameName;
  final int currentPlayerCount;

  LobbyTable({
    required this.tableId,
    required this.status,
    required this.maxPlayers,
    required this.roundContribution,
    required this.gameName,
    required this.currentPlayerCount,
  });

  int get totalPlayers => maxPlayers;

  factory LobbyTable.fromJson(String id, Map<dynamic, dynamic> json) {
    final meta = json['_meta'] as Map<dynamic, dynamic>? ?? {};
    return LobbyTable(
      tableId: id,
      status: json['status'] ?? 'waiting',
      maxPlayers: (meta['maxPlayers'] as num?)?.toInt() ?? 4,
      roundContribution: (json['contribution'] as num?)?.toInt() ?? 200,
      gameName: json['gameName'] ?? 'Table ${id.substring(0, 8)}',
      currentPlayerCount: (meta['totalPlayers'] as num?)?.toInt() ?? 0,
    );
  }
}
