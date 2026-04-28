import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/core/widgets/custom_textfeild.dart'; // adjust path if needed

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  User? _user; // nullable
  bool _isLoading = false;
  bool _isEditing = false;
  late TextEditingController _displayNameController;
  late TextEditingController _phoneController;

  int _chipsBalance = 1250000;
  int _winCount = 342;
  int _lossCount = 189;
  String _rank = "Strategist";

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _displayNameController = TextEditingController(
      text: _user?.displayName ?? '',
    );
    _phoneController = TextEditingController(text: _user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;
    setState(() => _isLoading = true);
    try {
      await _user!.updateDisplayName(_displayNameController.text.trim());
      setState(() => _isEditing = false);
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

  Future<void> _confirmDeleteAccount() async {
    if (_user == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Delete Account',
          style: AppTheme.headingMedium.copyWith(fontSize: 20),
        ),
        content: Text(
          'Are you sure? This action is permanent and cannot be undone.',
          style: AppTheme.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTheme.bodyText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTheme.bodyText.copyWith(color: AppTheme.lose),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _user!.delete();
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        backgroundColor: AppTheme.richBlack,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No user logged in', style: AppTheme.bodyText),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.richBlack,
      appBar: AppBar(
        title: Text('My Account', style: AppTheme.headingMedium),
        centerTitle: true,
        backgroundColor: AppTheme.pureBlack,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
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
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.surface,
                      backgroundImage: _user!.photoURL != null
                          ? NetworkImage(_user!.photoURL!)
                          : null,
                      child: _user!.photoURL == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: AppTheme.primaryGold,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _user!.email ?? 'No email',
                    style: AppTheme.bodyText.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  if (_isEditing) ...[
                    CustomTextfeild(
                      hintText: 'Display Name',
                      icon: Icons.person,
                      controller: _displayNameController,
                    ),
                    CustomTextfeild(
                      hintText: 'Phone Number',
                      icon: Icons.phone,
                      controller: _phoneController,
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
                            child: const Text('Save Changes'),
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
                    _buildInfoTile(
                      Icons.badge,
                      'Display Name',
                      _user!.displayName ?? 'Not set',
                    ),
                    _buildInfoTile(
                      Icons.email,
                      'Email',
                      _user!.email ?? 'Not set',
                    ),
                    _buildInfoTile(
                      Icons.phone,
                      'Phone',
                      _user!.phoneNumber ?? 'Not set',
                    ),
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
                    _buildStatTile(Icons.workspace_premium, 'Rank', _rank),
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
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _confirmDeleteAccount,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Delete Account'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: AppTheme.lose),
                        foregroundColor: AppTheme.lose,
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
