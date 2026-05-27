// lib/core/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/authService.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/myAccount/myAccountPage.dart';

class AppDrawer extends StatelessWidget {
  final AuthService _auth = AuthService();

  AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.panelSurface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppTheme.pureBlack,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primaryGold.withOpacity(0.3),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.casino, color: AppTheme.primaryGold, size: 40),
                const SizedBox(height: 8),
                Text('Da Mystro Gaming', style: AppTheme.headingMedium),
                const SizedBox(height: 4),
                Text('Royal Poker Club', style: AppTheme.captionGold),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.account_circle,
              color: AppTheme.primaryGold,
            ),
            title: const Text('My Account'),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyAccountPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard, color: AppTheme.primaryGold),
            title: const Text('Leaderboard'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to LeaderboardPage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Leaderboard coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppTheme.primaryGold),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to SettingsPage
            },
          ),
          const Divider(color: AppTheme.panelBorder),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.primaryGold),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context); // close drawer
              await _auth.logout();
            },
          ),
        ],
      ),
    );
  }
}
