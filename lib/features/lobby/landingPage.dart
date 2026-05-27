import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/authService.dart';
import 'package:flutter_application_1/core/services/userService.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/lobby/lobbyPage.dart';
import 'package:flutter_application_1/features/lobby/widget/appDrawer.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  Map<dynamic, dynamic>? _userData;

  // ✅ GlobalKey to control the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Mock online players list – replace with real data later
  final List<Map<String, String>> _onlinePlayers = [
    {'name': 'DaMaverick', 'status': 'playing'},
    {'name': 'Sharknado', 'status': 'in lobby'},
    {'name': 'PokerKing', 'status': 'waiting'},
    {'name': 'CardSharp', 'status': 'playing'},
    {'name': 'LuckyAce', 'status': 'in lobby'},
    {'name': 'HighRoller', 'status': 'playing'},
  ];

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final data = await _userService.getUserData(uid);
      setState(() {
        _userData = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String _calculateWinRate(String winsStr, String lossesStr) {
    final wins = int.tryParse(winsStr) ?? 0;
    final losses = int.tryParse(lossesStr) ?? 0;
    final total = wins + losses;
    if (total == 0) return '0%';
    final rate = (wins / total) * 100;
    return '${rate.toStringAsFixed(0)}%';
  }

  void _showPrivateGameDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('Adds you to a random table'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final userName = user?.displayName ?? user?.email ?? "Player";
    final chips = _userData?['chips']?.toString() ?? '—';
    final wins = _userData?['wins']?.toString() ?? '—';
    final losses = _userData?['losses']?.toString() ?? '—';

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
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
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: AppTheme.primaryGold),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const SizedBox(width: 8),
                    Text("DaMystro Gaming", style: AppTheme.headingMedium),
                    const Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. User Profile
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppTheme.primaryGold,
                            child: Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.pureBlack,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userName, style: AppTheme.headingSmall),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGold.withOpacity(
                                      0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppTheme.primaryGold,
                                    ),
                                  ),
                                  child: Text(
                                    'ROYAL PATRON',
                                    style: AppTheme.captionGold.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 2. Chip Balance Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1A2A1F),
                              AppTheme.panelSurface,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryGold.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: AppTheme.primaryGold,
                                  size: 36,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TOTAL CHIPS',
                                      style: AppTheme.tableHeaderStyle,
                                    ),
                                    Text(
                                      chips,
                                      style: AppTheme.headingLarge.copyWith(
                                        fontSize: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldGreen.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: AppTheme.statusGreen,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Stats Row (Wins, Losses, Win Rate)
                      Row(
                        children: [
                          Expanded(
                            child: _statCard('WINS', wins, Icons.emoji_events),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              'LOSSES',
                              losses,
                              Icons.sentiment_dissatisfied,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.panelSurface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.panelBorder),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'WIN RATE',
                                    style: AppTheme.tableHeaderStyle,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _calculateWinRate(wins, losses),
                                    style: AppTheme.headingSmall.copyWith(
                                      fontSize: 20,
                                      color: AppTheme.primaryGold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 4. Quick Actions (Quick Join & Private Game)
                      Text('QUICK ACTIONS', style: AppTheme.tableHeaderStyle),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _actionCard(
                              icon: Icons.group_add,
                              title: 'Find Table',
                              subtitle: 'look for available table',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LobbyPage(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _actionCard(
                              icon: Icons.play_circle_filled,
                              title: 'Quick Join',
                              subtitle: 'Find a table instantly',
                              onTap: _showPrivateGameDialog,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 5. Online Players List
                      Text('ONLINE PLAYERS', style: AppTheme.tableHeaderStyle),
                      const SizedBox(height: 12),
                      Card(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _onlinePlayers.length,
                          separatorBuilder: (_, __) => const Divider(
                            color: AppTheme.panelBorder,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final player = _onlinePlayers[index];
                            final status = player['status']!;
                            Color statusColor;
                            IconData statusIcon;
                            switch (status) {
                              case 'playing':
                                statusColor = AppTheme.statusGreen;
                                statusIcon = Icons.play_circle;
                                break;
                              case 'in lobby':
                                statusColor = AppTheme.primaryGold;
                                statusIcon = Icons.meeting_room;
                                break;
                              default:
                                statusColor = Colors.grey;
                                statusIcon = Icons.hourglass_empty;
                            }
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.panelBorder,
                                child: Text(
                                  player['name']![0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppTheme.primaryGold,
                                  ),
                                ),
                              ),
                              title: Text(
                                player['name']!,
                                style: AppTheme.bodyText,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: statusColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status.toUpperCase(),
                                    style: AppTheme.captionGold.copyWith(
                                      color: statusColor,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.panelSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 28),
          const SizedBox(height: 6),
          Text(label, style: AppTheme.tableHeaderStyle),
          const SizedBox(height: 2),
          Text(value, style: AppTheme.headingSmall.copyWith(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.panelSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.panelBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGold, size: 44),
            const SizedBox(height: 12),
            Text(title, style: AppTheme.headingSmall.copyWith(fontSize: 16)),
            Text(
              subtitle,
              style: AppTheme.bodyText.copyWith(
                fontSize: 12,
                color: AppTheme.offWhite.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
