import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/widgets/CompactPlayerInfo.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/widgets/gameBackground.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/logic/da_bank_co_PnP_state.dart';

class MultiplayerGamePage extends StatefulWidget {
  final String tableId;
  const MultiplayerGamePage({super.key, required this.tableId});

  @override
  State<MultiplayerGamePage> createState() => _MultiplayerGamePageState();
}

class _MultiplayerGamePageState extends State<MultiplayerGamePage> {
  final DatabaseReference _tableRef = FirebaseDatabase.instance.ref(
    'tables/tbl_full',
  );
  Map<dynamic, dynamic>? _tableData;
  String? _error;
  String? _myUid =
      "player_abc123"; // placeholder, later from PlayerLocalService

  // Bubble message state (like Pass & Play)
  String? _bubbleMessage;
  Timer? _bubbleTimer;

  @override
  void initState() {
    super.initState();
    _tableRef.onValue.listen(
      (event) {
        if (event.snapshot.value != null) {
          setState(() {
            _tableData = event.snapshot.value as Map<dynamic, dynamic>;
            _error = null;
          });
        } else {
          setState(() => _error = "Table not found");
        }
      },
      onError: (error) {
        setState(() => _error = error.toString());
      },
    );
  }

  void _showBubbleMessage(String msg) {
    _bubbleTimer?.cancel();
    setState(() => _bubbleMessage = msg);
    _bubbleTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _bubbleMessage = null);
    });
  }

  // HTTP test button method
  Future<void> _testHttp() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': 'Test from DaMystrio',
          'body': 'HTTP request works!',
          'userId': 1,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _showBubbleMessage('HTTP success! ID: ${data['id']}');
      } else {
        _showBubbleMessage('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      _showBubbleMessage('Request failed: $e');
    }
  }

  // Placeholder action methods (will become real HTTP calls later)
  void _placeBet(int amount) {
    _showBubbleMessage('Bet $amount (endpoint ready)');
    // TODO: call POST /tables/:tableId/place-bet
  }

  void _bankCo() {
    _showBubbleMessage('Bank Co (endpoint ready)');
    // TODO: call POST /tables/:tableId/action
  }

  void _forLess() {
    _showBubbleMessage('For Less (endpoint ready)');
    // TODO: call POST /tables/:tableId/action with amount
  }

  void _pass() {
    _showBubbleMessage('Pass (endpoint ready)');
    // TODO: call POST /tables/:tableId/action
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Multiplayer Game')),
        body: Center(child: Text('Error: $_error')),
      );
    }
    if (_tableData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final playersData = _tableData!['players'] as Map<dynamic, dynamic>? ?? {};
    final players = playersData.entries.map((entry) {
      final p = entry.value as Map<dynamic, dynamic>;
      return _PlayerAdapter(
        uid: entry.key,
        name: p['displayName'] ?? entry.key,
        balance: (p['chips'] ?? 0).toInt(),
        bet: (p['betAmount'] ?? 0).toInt(),
        seatIndex: (p['seat'] ?? 0).toInt(),
        isCurrentTurn: _tableData!['currentTurn'] == entry.key,
      );
    }).toList();
    players.sort((a, b) => a.seatIndex.compareTo(b.seatIndex));

    final pot = _tableData!['pot'] ?? 0;
    final phase = _tableData!['phase'] ?? 'betting';
    final currentTurn = _tableData!['currentTurn'];
    final isMyTurn = (phase == 'drawing' && currentTurn == _myUid);
    final isBettingPhase = (phase == 'betting');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Pot: $pot',
              style: AppTheme.captionGold.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Phase: $phase',
              style: AppTheme.bodyText.copyWith(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.http, color: AppTheme.primaryGold),
            onPressed: _testHttp,
            tooltip: 'Test HTTP',
          ),
        ],
      ),
      body: GameBackground(
        child: Stack(
          children: [
            // Table image
            Positioned.fill(
              child: Image.asset(
                'lib/assets/images/GameTableTraditional .png',
                fit: BoxFit.cover,
              ),
            ),
            // Player seats
            ...players.map((player) {
              Alignment alignment;
              if (player.seatIndex == 0)
                alignment = const Alignment(-0.75, 0.15);
              else if (player.seatIndex == 1)
                alignment = const Alignment(0.75, 0.15);
              else if (player.seatIndex == 2)
                alignment = const Alignment(0, -0.82);
              else
                alignment = const Alignment(0, 0.8);
              return Align(
                alignment: alignment,
                child: CompactPlayerInfo(
                  player: _toPnPPlayer(player),
                  isCurrentTurn: player.isCurrentTurn,
                ),
              );
            }),
            // Bubble message (if any)
            if (_bubbleMessage != null)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _bubbleMessage!,
                      style: AppTheme.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.pureBlack,
                      ),
                    ),
                  ),
                ),
              ),
            // Bottom action bar (styled like Pass & Play)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.pureBlack.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: AppTheme.primaryGold.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    if (isBettingPhase) ...[
                      Text(
                        'Betting Phase – Place your bet',
                        style: AppTheme.captionGold,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [50, 100, 200, 500].map((bet) {
                          return ElevatedButton(
                            onPressed: () => _placeBet(bet),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.emeraldGreen,
                              foregroundColor: AppTheme.offWhite,
                            ),
                            child: Text('$bet'),
                          );
                        }).toList(),
                      ),
                    ] else if (phase == 'drawing') ...[
                      if (isMyTurn) ...[
                        Text('Your turn', style: AppTheme.captionGold),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _actionButton(
                              'Bank Co',
                              AppTheme.emeraldGreen,
                              _bankCo,
                            ),
                            _actionButton(
                              'For Less',
                              AppTheme.highlightGold,
                              _forLess,
                            ),
                            _actionButton('Pass', AppTheme.lose, _pass),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'Waiting for ${_tableData!['currentTurn']}...',
                          style: AppTheme.captionGold,
                        ),
                      ],
                    ] else ...[
                      Text(
                        'Round ended / Game over',
                        style: AppTheme.captionGold,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppTheme.pureBlack,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(label, style: AppTheme.buttonText.copyWith(fontSize: 14)),
    );
  }

  PnPPlayer _toPnPPlayer(_PlayerAdapter p) {
    return PnPPlayer(
      name: p.name,
      seatIndex: p.seatIndex,
      balance: p.balance,
      bet: p.bet,
      cards: const [],
      state: 'idle',
    );
  }
}

class _PlayerAdapter {
  final String uid;
  final String name;
  final int balance;
  final int bet;
  final int seatIndex;
  final bool isCurrentTurn;
  _PlayerAdapter({
    required this.uid,
    required this.name,
    required this.balance,
    required this.bet,
    required this.seatIndex,
    required this.isCurrentTurn,
  });
}
