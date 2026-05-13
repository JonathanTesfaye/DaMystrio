import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/PlayerLocalServices.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/aboutUs/aboutUsPage.dart';
import 'package:flutter_application_1/features/myAccount/myAccountPage.dart';
import 'package:flutter_application_1/features/settings/settingsPage.dart';

class PlayerInfo extends StatefulWidget {
  final VoidCallback onChangeName;

  const PlayerInfo({super.key, required this.onChangeName});

  @override
  State<PlayerInfo> createState() => _PlayerInfoState();
}

class _PlayerInfoState extends State<PlayerInfo> {
  String _displayName = "Player";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await PlayerLocalService.getDisplayName();
    if (mounted) {
      setState(() {
        _displayName = name;
        _isLoading = false;
      });
    }
  }

  Future<void> _changeName() async {
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Name"),
        content: TextField(
          controller: TextEditingController(text: _displayName),
          decoration: const InputDecoration(labelText: "Your name"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              ctx,
              (ctx as dynamic)
                  .findAncestorWidgetOfExactType<TextField>()
                  ?.controller
                  ?.text,
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && newName != _displayName) {
      await PlayerLocalService.setDisplayName(newName);
      setState(() {
        _displayName = newName;
      });
      widget.onChangeName();
    }
  }

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
                _displayName,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyAccountPage()),
                  );
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                  break;
                case 'about_us':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsPage()),
                  );
                  break;
                case 'change_name':
                  _changeName();
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
                value: 'change_name',
                child: ListTile(
                  leading: Icon(Icons.edit, color: AppTheme.highlightGold),
                  title: Text('Change Name'),
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
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryGold,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
