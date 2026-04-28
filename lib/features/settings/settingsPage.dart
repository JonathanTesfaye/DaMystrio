import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import '../../../core/widgets/custom_textfeild.dart'; // if needed for any input

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings state (replace with SharedPreferences or provider later)
  bool _isSoundEnabled = true;
  bool _isNotificationsEnabled = true;
  bool _isDarkMode =
      true; // always true for now, but keep for future light mode
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'አማርኛ', 'French', 'Spanish'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.richBlack,
      appBar: AppBar(
        title: Text('Settings', style: AppTheme.headingMedium),
        centerTitle: true,
        backgroundColor: AppTheme.pureBlack,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Sound Toggle ---
              _buildSettingsTile(
                icon: Icons.volume_up,
                title: 'Sound Effects',
                trailing: Switch(
                  value: _isSoundEnabled,
                  onChanged: (val) => setState(() => _isSoundEnabled = val),
                  activeColor: AppTheme.primaryGold,
                  activeTrackColor: AppTheme.emeraldGreen,
                ),
              ),
              const SizedBox(height: 16),

              // --- Notifications Toggle ---
              _buildSettingsTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                trailing: Switch(
                  value: _isNotificationsEnabled,
                  onChanged: (val) =>
                      setState(() => _isNotificationsEnabled = val),
                  activeColor: AppTheme.primaryGold,
                  activeTrackColor: AppTheme.emeraldGreen,
                ),
              ),
              const SizedBox(height: 16),

              // --- Language Selector ---
              _buildSettingsTile(
                icon: Icons.language,
                title: 'Language',
                trailing: DropdownButton<String>(
                  value: _selectedLanguage,
                  dropdownColor: AppTheme.surface,
                  style: AppTheme.bodyText,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: AppTheme.primaryGold,
                  ),
                  onChanged: (newLang) {
                    if (newLang != null)
                      setState(() => _selectedLanguage = newLang);
                  },
                  items: _languages.map((lang) {
                    return DropdownMenuItem<String>(
                      value: lang,
                      child: Text(lang, style: AppTheme.bodyText),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // --- Dark Mode (optional) ---
              _buildSettingsTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Always on for this theme',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Premium', style: AppTheme.captionGold),
                ),
              ),
              const SizedBox(height: 24),

              const Divider(color: AppTheme.primaryGold, height: 32),

              // --- Privacy & Legal Section ---
              Text(
                'Legal & Support',
                style: AppTheme.headingMedium.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),

              _buildActionTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () => _showPolicyDialog(
                  'Privacy Policy',
                  'Your privacy is important to us. We collect only essential data for game functionality.',
                ),
              ),
              _buildActionTile(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () => _showPolicyDialog(
                  'Terms of Service',
                  'By using DaMystrio, you agree to our terms. This is a premium strategy game for entertainment.',
                ),
              ),
              _buildActionTile(
                icon: Icons.support_agent,
                title: 'Support',
                onTap: () => _showPolicyDialog(
                  'Support',
                  'Contact us at support@damystrio.com\n\nWe’ll respond within 24 hours.',
                ),
              ),
              _buildActionTile(
                icon: Icons.info,
                title: 'Version',
                subtitle: '1.0.0',
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.captionGold.copyWith(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGold, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.bodyText),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.captionGold.copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: AppTheme.primaryGold),
          ],
        ),
      ),
    );
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          title,
          style: AppTheme.headingMedium.copyWith(fontSize: 20),
        ),
        content: Text(content, style: AppTheme.bodyText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: AppTheme.bodyText),
          ),
        ],
      ),
    );
  }
}
