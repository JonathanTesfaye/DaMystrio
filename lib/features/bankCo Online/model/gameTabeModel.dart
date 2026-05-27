import 'package:flutter/material.dart';

class GameTableModel {
  final String id;
  final Map<String, dynamic> meta; // will be stored as '_meta' in DB
  final int createdAt;
  final int updatedAt;
  final String gameName;
  final String status;
  final Map<String, dynamic> deck;
  final Map<String, dynamic> gameState;
  final Map<String, PlayerModel> players;
  final Map<String, dynamic> round;
  final int roundContribution;
  final int startConsentCount;
  final int startingChips;

  GameTableModel({
    required this.id,
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
    required this.gameName,
    required this.status,
    required this.deck,
    required this.gameState,
    required this.players,
    required this.round,
    required this.roundContribution,
    required this.startConsentCount,
    required this.startingChips,
  });

  factory GameTableModel.fromJson(Map<String, dynamic> json) {
    final playersMap = (json['players'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, PlayerModel.fromJson(value)),
    );
    return GameTableModel(
      id: json['id'],
      meta: Map<String, dynamic>.from(json['_meta']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      gameName: json['gameName'],
      status: json['status'],
      deck: Map<String, dynamic>.from(json['deck']),
      gameState: Map<String, dynamic>.from(json['gameState']),
      players: playersMap,
      round: Map<String, dynamic>.from(json['round']),
      roundContribution: json['roundContribution'],
      startConsentCount: json['startConsentCount'],
      startingChips: json['startingChips'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    '_meta': meta,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'gameName': gameName,
    'status': status,
    'deck': deck,
    'gameState': gameState,
    'players': players.map((k, v) => MapEntry(k, v.toJson())),
    'round': round,
    'roundContribution': roundContribution,
    'startConsentCount': startConsentCount,
    'startingChips': startingChips,
  };

  int get maxPlayers => meta['maxPlayers'];
  int get totalPlayers => meta['totalPlayers'];
}

class PlayerModel {
  final String avatar;
  final int customBet;
  final String id;
  final int chips;
  final bool isConnected;
  final bool isEliminated;
  final String name;
  final int seatPosition;
  final bool startConsented;
  final Map<String, dynamic> stats;
  final Map<String, dynamic> status;
  final List<Map<String, dynamic>>? draw;

  PlayerModel({
    required this.avatar,
    required this.customBet,
    required this.id,
    required this.chips,
    required this.isConnected,
    required this.isEliminated,
    required this.name,
    required this.seatPosition,
    required this.startConsented,
    required this.stats,
    required this.status,
    this.draw,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      avatar: json['avatar'] ?? '',
      customBet: json['customBet'] ?? 0,
      id: json['id'],
      chips: json['chips'],
      isConnected: json['isConnected'] ?? true,
      isEliminated: json['isEliminated'] ?? false,
      name: json['name'],
      seatPosition: json['seatPosition'],
      startConsented: json['startConsented'] ?? false,
      stats: Map<String, dynamic>.from(json['stats']),
      status: Map<String, dynamic>.from(json['status']),
      draw: json['draw'] != null ? List<Map<String, dynamic>>.from(json['draw']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'avatar': avatar,
    'customBet': customBet,
    'id': id,
    'chips': chips,
    'isConnected': isConnected,
    'isEliminated': isEliminated,
    'name': name,
    'seatPosition': seatPosition,
    'startConsented': startConsented,
    'stats': stats,
    'status': status,
    if (draw != null) 'draw': draw,
  };
}