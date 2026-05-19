import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/authService.dart';
import 'package:flutter_application_1/core/services/userService.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/lobby/lobbyPage.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  Map<dynamic, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final userName = user?.displayName ?? user?.email ?? "Player";
    final chips = _userData?['chips'] ?? '...';
    final wins = _userData?['wins'] ?? '...';
    final losses = _userData?['losses'] ?? '...';

    return Scaffold(
      appBar: AppBar(
        title: const Text("BankCo Demo"),
        backgroundColor: AppTheme.pureBlack,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.logout();
            },
            tooltip: "Logout",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, $userName!",
              style: AppTheme.headingLarge.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text("Chips: $chips", style: AppTheme.bodyText),
            Text("Wins: $wins | Losses: $losses", style: AppTheme.bodyText),
            const SizedBox(height: 16),
            Text(
              "This is a temporary page.\nLater, this will show a list of available games\nor allow you to create a new game.",
              textAlign: TextAlign.center,
              style: AppTheme.bodyText,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LobbyPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldGreen,
                foregroundColor: AppTheme.pureBlack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text("Find a Game"),
            ),
          ],
        ),
      ),
    );
  }
}
