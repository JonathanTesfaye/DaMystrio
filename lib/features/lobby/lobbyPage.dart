import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/core/services/authService.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo%20Online/bankCoOnlineTable.dart';
import 'package:flutter_application_1/features/lobby/model/lobbyTable.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final DatabaseReference _activeTablesRef = FirebaseDatabase.instance.ref(
    'activeTables',
  );
  final DatabaseReference _tablesRef = FirebaseDatabase.instance.ref('tables');
  final AuthService _auth = AuthService();
  final Random _random = Random();

  List<LobbyTable> _tables = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  StreamSubscription<DatabaseEvent>? _activeTablesSubscription;
  int _totalPlayersOnline = 0;

  @override
  void initState() {
    super.initState();
    _listenToActiveTables();
  }

  void _listenToActiveTables() {
    _activeTablesSubscription = _activeTablesRef
        .orderByChild('status')
        .equalTo('waiting')
        .limitToFirst(20)
        .onValue
        .listen(
          (event) {
            final data = event.snapshot.value as Map<dynamic, dynamic>?;
            final List<LobbyTable> loaded = [];
            int totalPlayers = 0;
            if (data != null) {
              data.forEach((key, value) {
                final tableId = key.toString();
                final map = Map<String, dynamic>.from(value as Map);
                final table = LobbyTable.fromJson(tableId, map);
                loaded.add(table);
                totalPlayers += table.currentPlayerCount;
              });
            }
            setState(() {
              _tables = loaded;
              _totalPlayersOnline = totalPlayers;
              _isLoading = false;
              _isRefreshing = false;
            });
          },
          onError: (error) {
            print("Firebase error: $error");
            setState(() {
              _isLoading = false;
              _isRefreshing = false;
            });
          },
        );
  }

  Future<void> _refreshTables() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _createGame(String gameName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final newTableRef = _tablesRef.push();
    final tableId = newTableRef.key!;
    final now = ServerValue.timestamp;

    // Build and shuffle the deck
    final List<String> cards = [
      "A♠",
      "2♠",
      "3♠",
      "4♠",
      "5♠",
      "6♠",
      "7♠",
      "8♠",
      "9♠",
      "10♠",
      "J♠",
      "Q♠",
      "K♠",
      "A♥",
      "2♥",
      "3♥",
      "4♥",
      "5♥",
      "6♥",
      "7♥",
      "8♥",
      "9♥",
      "10♥",
      "J♥",
      "Q♥",
      "K♥",
      "A♦",
      "2♦",
      "3♦",
      "4♦",
      "5♦",
      "6♦",
      "7♦",
      "8♦",
      "9♦",
      "10♦",
      "J♦",
      "Q♦",
      "K♦",
      "A♣",
      "2♣",
      "3♣",
      "4♣",
      "5♣",
      "6♣",
      "7♣",
      "8♣",
      "9♣",
      "10♣",
      "J♣",
      "Q♣",
      "K♣",
    ];
    cards.shuffle(_random);
    final deck = {'cards': cards, 'position': 0};

    final tableData = {
      'id': tableId,
      '_meta': {'maxPlayers': 4, 'totalPlayers': 1},
      'createdAt': now,
      'updatedAt': now,
      'gameName': gameName,
      'status': 'waiting',
      'deck': deck,
      'gameState': {'eliminatedPlayers': [], 'potValue': 0, 'winner': null},
      'players': {
        user.uid: {
          'avatar': '',
          'customBet': 0,
          'id': user.uid,
          'chips': 1000,
          'isConnected': true,
          'isEliminated': false,
          'name': user.displayName ?? user.email ?? 'Player',
          'seatPosition': 0,
          'startConsented': false,
          'stats': {'wins': 0, 'losses': 0},
          'status': {'state': 'idle', 'decision': null},
        },
      },
      'round': {
        'currentPlayerId': user.uid,
        'currentRound': 1,
        'totalRounds': 3,
      },
      'roundContribution': 200,
      'startConsentCount': 0,
      'startingChips': 1000,
    };

    final activeEntry = {
      '_meta': {'maxPlayers': 4, 'totalPlayers': 1},
      'contribution': 200,
      'id': tableId,
      'startingChips': 1000,
      'status': 'waiting',
      'gameName': gameName,
    };

    try {
      await newTableRef.set(tableData);
      await _activeTablesRef.child(tableId).set(activeEntry);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BankCoOnline(tableId: tableId)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to create table: $e")));
    }
  }

  Future<void> _joinGame(LobbyTable table) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final tableRef = _tablesRef.child(table.tableId);
    final activeRef = _activeTablesRef.child(table.tableId);

    int maxAttempts = 3;
    bool success = false;
    String? errorMessage;

    while (maxAttempts > 0 && !success) {
      maxAttempts--;
      try {
        final snapshot = await tableRef.get();
        if (!snapshot.exists) {
          errorMessage = "Table no longer exists.";
          break;
        }
        final data = snapshot.value as Map<dynamic, dynamic>;
        if (data['status'] != 'waiting') {
          errorMessage = "Game already started.";
          break;
        }

        final playersMap = Map<String, dynamic>.from(data['players'] ?? {});
        final meta = Map<String, dynamic>.from(data['_meta'] ?? {});
        final maxPlayers = (meta['maxPlayers'] as num?)?.toInt() ?? 4;

        if (playersMap.containsKey(user.uid)) {
          errorMessage = "You already joined this game.";
          break;
        }
        if (playersMap.length >= maxPlayers) {
          errorMessage = "Game is full.";
          break;
        }

        final occupiedSeats = playersMap.values
            .map<int>((p) => (p['seatPosition'] as num?)?.toInt() ?? 0)
            .toSet();
        int freeSeat = 0;
        while (occupiedSeats.contains(freeSeat)) freeSeat++;

        final newPlayer = {
          'avatar': '',
          'customBet': 0,
          'id': user.uid,
          'chips': 1000,
          'isConnected': true,
          'isEliminated': false,
          'name': user.displayName ?? user.email ?? 'Player',
          'seatPosition': freeSeat,
          'startConsented': false,
          'stats': {'wins': 0, 'losses': 0},
          'status': {'state': 'idle', 'decision': null},
        };
        playersMap[user.uid] = newPlayer;
        meta['totalPlayers'] = playersMap.length;

        await tableRef.update({'_meta': meta, 'players': playersMap});
        success = true;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? "Failed to join. Try again.")),
      );
      return;
    }

    final activeSnapshot = await activeRef.get();
    if (activeSnapshot.exists) {
      final currentMeta = (activeSnapshot.value as Map)['_meta'] ?? {};
      final currentTotal = (currentMeta['totalPlayers'] as num?)?.toInt() ?? 0;
      await activeRef.child('_meta/totalPlayers').set(currentTotal + 1);
    } else {
      await activeRef.set({
        '_meta': {'maxPlayers': table.totalPlayers, 'totalPlayers': 1},
        'contribution': table.roundContribution,
        'id': table.tableId,
        'startingChips': 1000,
        'status': 'waiting',
        'gameName': table.gameName,
      });
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BankCoOnline(tableId: table.tableId)),
      );
    }
  }

  void _showCreateGameDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panelSurface,
        title: Text('Create New Game', style: AppTheme.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Game Name',
                labelStyle: AppTheme.captionGold,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.panelBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryGold),
                ),
              ),
              style: AppTheme.bodyText,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Round Contribution:', style: AppTheme.bodyText),
                Text(
                  ' 200 chips',
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('Total Players:', style: AppTheme.bodyText),
                Text(
                  ' 4',
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTheme.bodyText),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Please enter a game name')),
                );
                return;
              }
              Navigator.pop(ctx);
              _createGame(name);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _activeTablesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.feltBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.primaryGold,
                      ),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 8),
                    // Title – wraps when needed
                    Expanded(
                      child: Text(
                        "Game Lobby",
                        style: AppTheme.headingMedium,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Online counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.pureBlack.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppTheme.statusGreen.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.statusGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_totalPlayersOnline Online',
                            style: AppTheme.bodyText.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Create button
                    IconButton(
                      icon: const Icon(Icons.add, color: AppTheme.primaryGold),
                      onPressed: _showCreateGameDialog,
                      tooltip: 'Create Game',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshTables,
                  color: AppTheme.primaryGold,
                  child: _isLoading
                      ? _buildShimmerLoading()
                      : _tables.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.table_restaurant,
                                size: 64,
                                color: AppTheme.primaryGold.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tables waiting',
                                style: AppTheme.headingSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create a new game to get started',
                                style: AppTheme.bodyText,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _showCreateGameDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('CREATE GAME'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _tables.length,
                          itemBuilder: (context, index) =>
                              _buildTableCard(_tables[index]),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.panelSurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _ShimmerText(width: 120, height: 20)),
                    _ShimmerText(width: 80, height: 16),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    _ShimmerText(width: 100, height: 14),
                    SizedBox(width: 20),
                    _ShimmerText(width: 80, height: 14),
                  ],
                ),
                SizedBox(height: 16),
                _ShimmerText(width: double.infinity, height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableCard(LobbyTable table) {
    final bool isAlmostFull =
        table.currentPlayerCount >= table.totalPlayers - 1;
    final Color statusColor = isAlmostFull
        ? AppTheme.primaryGold
        : AppTheme.statusGreen;
    final String statusText = isAlmostFull ? "Almost full" : "Waiting";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.panelSurface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    table.gameName,
                    style: AppTheme.headingSmall.copyWith(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: AppTheme.captionGold.copyWith(
                      color: statusColor,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people, color: AppTheme.primaryGold, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${table.currentPlayerCount}/${table.totalPlayers} players',
                  style: AppTheme.bodyText,
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.monetization_on,
                  color: AppTheme.primaryGold,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${table.roundContribution} chips',
                  style: AppTheme.bodyText,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _joinGame(table),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: AppTheme.whiteAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('JOIN TABLE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  const _ShimmerText({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const SizedBox.shrink(),
    );
  }
}
