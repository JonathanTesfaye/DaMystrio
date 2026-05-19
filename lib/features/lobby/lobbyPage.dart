import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/core/services/authService.dart';
import 'package:flutter_application_1/features/bankCo%20Online/bankCoOnlineTable.dart';
import 'package:flutter_application_1/features/lobby/model/lobbyTable.dart';
import 'package:firebase_database/firebase_database.dart';

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
  List<LobbyTable> _tables = [];
  bool _isLoading = true;
  StreamSubscription<DatabaseEvent>? _activeTablesSubscription;

  @override
  void initState() {
    super.initState();
    _listenToActiveTables();
  }

  void _listenToActiveTables() {
    // Query waiting tables, limit to 20
    _activeTablesSubscription = _activeTablesRef
        .orderByChild('status')
        .equalTo('waiting')
        .limitToFirst(20)
        .onValue
        .listen(
          (event) {
            final data = event.snapshot.value as Map<dynamic, dynamic>?;
            final List<LobbyTable> loaded = [];
            if (data != null) {
              data.forEach((key, value) {
                final tableId = key.toString();
                final map = value as Map<dynamic, dynamic>; // direct cast
                loaded.add(LobbyTable.fromJson(tableId, map));
              });
            }
            setState(() {
              _tables = loaded;
              _isLoading = false;
            });
          },
          onError: (error) {
            print("Firebase error: $error");
            setState(() => _isLoading = false);
          },
        );
  }

  Future<void> _createGame(String gameName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final newTableRef = _tablesRef.push();
    final tableId = newTableRef.key!;

    // Full table data – exactly matching the web schema
    final tableData = {
      '_meta': {
        'maxPlayers': 4,
        'startConsentCount': 0,
        'startingChips': 1000,
        'totalPlayers': 1,
      },
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
      'gameName': gameName,
      'status': 'waiting',
      'id': tableId,
      'deck': {
        'cards': [
          "AS",
          "2S",
          "3S",
          "4S",
          "5S",
          "6S",
          "7S",
          "8S",
          "9S",
          "10S",
          "JS",
          "QS",
          "KS",
          "AH",
          "2H",
          "3H",
          "4H",
          "5H",
          "6H",
          "7H",
          "8H",
          "9H",
          "10H",
          "JH",
          "QH",
          "KH",
          "AD",
          "2D",
          "3D",
          "4D",
          "5D",
          "6D",
          "7D",
          "8D",
          "9D",
          "10D",
          "JD",
          "QD",
          "KD",
          "AC",
          "2C",
          "3C",
          "4C",
          "5C",
          "6C",
          "7C",
          "8C",
          "9C",
          "10C",
          "JC",
          "QC",
          "KC",
        ],
        'position': 0,
      },
      'gameState': {'activePlayerIndex': 0},
      'players': [
        {
          'avatar': '',
          'betAmount': 0,
          'id': user.uid,
          'initialChips': 1000,
          'isConnected': true,
          'isEliminated': false,
          'name': user.displayName ?? user.email ?? 'Player',
          'remainingChips': 1000,
          'seatPosition': 0,
          'stats': {'losses': 0, 'wins': 0},
          'status': {'startConsented': false, 'state': 'idle'},
        },
      ],
      'round': {
        'hasBegun': false,
        'potValue': 0,
        'roundContribution': 200,
        'roundCount': 0,
        'roundNumber': 1,
      },
    };

    // Active table entry (same as before)
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
      print("Table created: $tableId");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BankCoOnline(tableId: tableId)),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to create table: $e")));
    }
  }

  void _showCreateGameDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Game'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Game Name'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Round Contribution: 200 chips',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Total Players: 4',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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
        // Read current data
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

        final players = List<dynamic>.from(data['players'] ?? []);
        final meta = Map<dynamic, dynamic>.from(data['_meta'] ?? {});
        final maxPlayers = (meta['maxPlayers'] as num?)?.toInt() ?? 4;

        if (players.any((p) => p['id'] == user.uid)) {
          errorMessage = "You already joined this game.";
          break;
        }
        if (players.length >= maxPlayers) {
          errorMessage = "Game is full.";
          break;
        }

        // Find free seat
        final occupiedSeats = players
            .map<int>((p) => p['seatPosition'] as int)
            .toSet();
        int freeSeat = 0;
        while (occupiedSeats.contains(freeSeat)) freeSeat++;

        final newPlayer = {
          'avatar': '',
          'betAmount': 0,
          'id': user.uid,
          'initialChips': 1000,
          'isConnected': true,
          'isEliminated': false,
          'name': user.displayName ?? user.email ?? 'Player',
          'remainingChips': 1000,
          'seatPosition': freeSeat,
          'stats': {'wins': 0, 'losses': 0},
          'status': {'startConsented': false, 'state': 'idle'},
        };
        players.add(newPlayer);
        meta['totalPlayers'] = players.length;

        // Try to update (using a version check to avoid conflicts)
        final updates = {'_meta': meta, 'players': players};
        await tableRef.update(updates);
        success = true;
      } catch (e) {
        // Conflict – retry
        print("Join attempt failed, retrying: $e");
        await Future.delayed(Duration(milliseconds: 200));
      }
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? "Failed to join. Please try again."),
        ),
      );
      return;
    }

    // Update active table entry
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

  @override
  void dispose() {
    _activeTablesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Tables')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGameDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tables.isEmpty
          ? const Center(child: Text('No tables waiting.\nCreate one!'))
          : ListView.builder(
              itemCount: _tables.length,
              itemBuilder: (context, index) {
                final table = _tables[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      table.gameName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Players: ${table.currentPlayerCount}/${table.totalPlayers} · ${table.roundContribution} chips',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _joinGame(table),
                      child: const Text('Join'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
