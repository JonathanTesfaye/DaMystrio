import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:url_launcher/url_launcher.dart'; // optional for links

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.richBlack,
      appBar: AppBar(
        title: Text('About Us', style: AppTheme.headingMedium),
        centerTitle: true,
        backgroundColor: AppTheme.pureBlack,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo / Icon
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGold.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'lib/assets/images/DaMystrioLogo.png', // Change to your image path
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image not found
                      return Center(
                        child: Text(
                          'DM',
                          style: AppTheme.headingLarge.copyWith(fontSize: 48),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // App Name
              Text(
                'DaMystrio',
                style: AppTheme.headingLarge.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                'Ethiopian Royal Strategy',
                style: AppTheme.captionGold.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Description
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryGold.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'DaMystrio is a premium strategy card game blending Ethiopian royal heritage with modern gaming. Master the art of DaBankCo, compete with AI, and rise through the ranks.',
                  style: AppTheme.bodyText,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Developer Section
              _buildSectionTitle('Developer'),
              _buildInfoRow('Studio', 'Mystrio Gaming'),
              _buildInfoRow('Lead Designer', 'Someone'),
              _buildInfoRow('Version', '1.0.0'),
              const SizedBox(height: 20),

              // Contact Section
              _buildSectionTitle('Contact'),
              _buildLinkRow(
                Icons.email,
                'support@damystrio.com',
                () => _launchEmail(),
              ),
              _buildLinkRow(
                Icons.web,
                'www.damystrio.com',
                () => _launchUrl('https://www.damystrio.com'),
              ),
              _buildLinkRow(
                Icons.telegram,
                '@damystrio',
                () => _launchUrl('https://t.me/damystrio'),
              ),
              const SizedBox(height: 20),

              // Social Media
              _buildSectionTitle('Follow Us'),
              Wrap(
                spacing: 20,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildSocialButton(
                    Icons.camera_alt,
                    'Instagram',
                    _launchInstagram,
                  ),
                  _buildSocialButton(
                    Icons.facebook,
                    'Facebook',
                    _launchFacebook,
                  ),
                  _buildSocialButton(Icons.chat, 'Twitter', _launchTwitter),
                ],
              ),
              const SizedBox(height: 32),

              // Copyright
              Text(
                '© 2025 DaMystrio. All rights reserved.',
                style: AppTheme.captionGold.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(width: 40, height: 2, color: AppTheme.primaryGold),
          const SizedBox(width: 12),
          Text(title, style: AppTheme.headingMedium.copyWith(fontSize: 20)),
          const SizedBox(width: 12),
          Container(width: 40, height: 2, color: AppTheme.primaryGold),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.captionGold),
          Text(value, style: AppTheme.bodyText),
        ],
      ),
    );
  }

  Widget _buildLinkRow(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGold, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(text, style: AppTheme.bodyText)),
            Icon(Icons.open_in_new, color: AppTheme.primaryGold, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.primaryGold,
        side: BorderSide(color: AppTheme.primaryGold.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  // --- Launch functions (replace with actual URLs) ---
  void _launchEmail() async {
    final Uri emailUri = Uri(scheme: 'mailto', path: 'support@damystrio.com');
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchInstagram() async {
    const url = 'https://instagram.com/damystrio';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _launchFacebook() async {
    const url = 'https://facebook.com/damystrio';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _launchTwitter() async {
    const url = 'https://twitter.com/damystrio';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
