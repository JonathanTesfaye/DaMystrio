import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/authService.dart';
import 'package:flutter_application_1/core/services/userService.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/core/widgets/custom_textfeild.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();

  bool _isLoading = true;
  bool _isEditing = false;
  late TextEditingController _usernameController;

  // Real data from Realtime Database
  String _username = '';
  String _email = '';
  int _chipsBalance = 0;
  int _winCount = 0;
  int _lossCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final data = await _userService.getUserData(uid);
      if (data != null) {
        setState(() {
          _username = data['username'] ?? 'Player';
          _email = data['email'] ?? _auth.currentUser?.email ?? '';
          _chipsBalance = (data['chips'] as int?) ?? 0;
          _winCount = (data['wins'] as int?) ?? 0;
          _lossCount = (data['losses'] as int?) ?? 0;
          _usernameController = TextEditingController(text: _username);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    }
  }

  Future<void> _updateProfile() async {
    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        // Update username in Realtime Database
        await _userService.updateUsername(uid, newUsername);
      }
      setState(() {
        _username = newUsername;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.richBlack,
      appBar: AppBar(
        title: Text('My Account', style: AppTheme.headingMedium),
        centerTitle: true,
        backgroundColor: AppTheme.pureBlack,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.feltBackgroundGradient,
        ),
        child: Stack(
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGold),
              ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryGold, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.surface,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _email,
                    style: AppTheme.bodyText.copyWith(
                      fontSize: 14,
                      color: AppTheme.offWhite.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_isEditing) ...[
                    CustomTextfeild(
                      hintText: 'Username',
                      icon: Icons.person,
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGold,
                              foregroundColor: AppTheme.pureBlack,
                            ),
                            child: const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _isEditing = false),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _buildInfoTile(Icons.badge, 'Username', _username),
                    _buildInfoTile(Icons.email, 'Email', _email),
                    const Divider(color: AppTheme.primaryGold, height: 32),
                    Text(
                      'Game Statistics',
                      style: AppTheme.headingMedium.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    _buildStatTile(
                      Icons.monetization_on,
                      'Chips Balance',
                      _chipsBalance.toString(),
                    ),
                    _buildStatTile(
                      Icons.emoji_events,
                      'Wins',
                      _winCount.toString(),
                    ),
                    _buildStatTile(
                      Icons.sentiment_dissatisfied,
                      'Losses',
                      _lossCount.toString(),
                    ),
                    const Divider(color: AppTheme.primaryGold, height: 32),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit My Account'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: AppTheme.emeraldGreen,
                        foregroundColor: AppTheme.offWhite,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.captionGold.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: AppTheme.bodyText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTheme.bodyText)),
          Text(
            value,
            style: AppTheme.captionGold.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
