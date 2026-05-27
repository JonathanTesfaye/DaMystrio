class CardModelOnline {
  final String id;
  final String suit;
  final String label;
  final String rank;
  final int value;

  CardModelOnline({
    required this.id,
    required this.suit,
    required this.label,
    required this.rank,
    required this.value,
  });

  /// Creates from Firebase snapshot (supports both full and simplified objects)
  factory CardModelOnline.fromFirebase(Map<String, dynamic> map) {
    return CardModelOnline(
      id:
          map['id'] ??
          'card_${map['label']}_${map['suit']}_${DateTime.now().millisecondsSinceEpoch}',
      suit: map['suit'] ?? '',
      label: map['label'] ?? '',
      rank: map['rank'] ?? map['label'] ?? '',
      value: (map['value'] as num?)?.toInt() ?? 0,
    );
  }

  /// Creates a simple card for testing
  factory CardModelOnline.simple({String suit = 'hearts', int value = 10}) {
    return CardModelOnline(
      id: 'card_${suit}_$value',
      suit: suit,
      label: value.toString(),
      rank: value.toString(),
      value: value,
    );
  }

  /// Converts to a map suitable for Firebase (full format with id and rank)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'suit': suit,
      'label': label,
      'rank': rank,
      'value': value,
    };
  }

  /// Converts to a simplified map for web compatibility (no id, no rank)
  Map<String, dynamic> toSimpleMap() {
    return {'label': label, 'suit': suit, 'value': value};
  }
}
