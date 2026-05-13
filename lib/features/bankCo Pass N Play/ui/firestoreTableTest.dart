import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';

class RtdbTableTestPage extends StatelessWidget {
  const RtdbTableTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final database = FirebaseDatabase.instance;
    final tableRef = database.ref(
      'tables/tbl_full',
    ); // Use the correct table ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime DB – Table: tbl_full'),
        backgroundColor: AppTheme.primaryGold,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: tableRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.snapshot.value;
          if (data == null) {
            return const Center(child: Text('Table not found'));
          }
          final map = data as Map<dynamic, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoRow('Table ID', map['tableId']),
              _buildInfoRow('Status', map['status']),
              _buildInfoRow('Phase', map['phase']),
              _buildInfoRow('Pot', map['pot']?.toString()),
              _buildInfoRow('Current Turn', map['currentTurn']),
              _buildInfoRow(
                'Round Contribution',
                map['roundContributions']?.toString(),
              ),
              _buildInfoRow('Current Round', map['currentRound']?.toString()),
              const Divider(),
              const Text(
                'Players:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._buildPlayersList(map['players']),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? 'null'),
        ],
      ),
    );
  }

  List<Widget> _buildPlayersList(dynamic players) {
    if (players == null) return [const Text('No players data')];
    final map = players as Map<dynamic, dynamic>;
    return map.entries.map((entry) {
      final player = entry.value as Map<dynamic, dynamic>;
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text(player['displayName'] ?? entry.key),
          subtitle: Text(
            'Chips: ${player['chips']} | Bet: ${player['betAmount']}',
          ),
          trailing: Text('Seat ${player['seat']}'),
        ),
      );
    }).toList();
  }
}
