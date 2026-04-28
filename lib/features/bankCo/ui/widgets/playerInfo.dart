import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/aboutUs/aboutUsPage.dart';
import 'package:flutter_application_1/features/myAccount/myAccountPage.dart';
import 'package:flutter_application_1/features/settings/settingsPage.dart'; // ✅ verify this path

class PlayerInfo extends StatelessWidget {
  final User? user;
  final VoidCallback onLogout;

  const PlayerInfo({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.pureBlack.withOpacity(0.85),
            AppTheme.pureBlack.withOpacity(0.4),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user?.displayName ?? 'Player',
                style: AppTheme.headingMedium.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: AppTheme.primaryGold,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text('1,250,000', style: AppTheme.captionGold),
                ],
              ),
            ],
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            onSelected: (value) {
              switch (value) {
                case 'my_account':
                  // ✅ Safe navigation with error handling
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          MyAccountPage(), // just an empty container, no custom page
                    ),
                  );
                  break;
                case 'settings':
                  // TODO: Navigate to SettingsPage
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SettingsPage(), // just an empty container, no custom page
                    ),
                  );
                  break;
                case 'about_us':
                  // TODO: Navigate to AboutUsPage
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AboutUsPage(), // just an empty container, no custom page
                    ),
                  );
                  break;
                case 'logout':
                  onLogout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'my_account',
                child: ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    color: AppTheme.primaryGold,
                  ),
                  title: Text('My Account'),
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings, color: AppTheme.primaryGold),
                  title: Text('Settings'),
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'about_us',
                child: ListTile(
                  leading: Icon(Icons.info, color: AppTheme.primaryGold),
                  title: Text('About Us'),
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: AppTheme.lose),
                  title: Text('Logout', style: TextStyle(color: AppTheme.lose)),
                  dense: true,
                ),
              ),
            ],
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryGold, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.surface,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                child: user?.photoURL == null
                    ? const Icon(
                        Icons.person,
                        color: AppTheme.primaryGold,
                        size: 28,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
