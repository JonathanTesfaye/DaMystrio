import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo/ui/backCo.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/backCoPassNPlay.dart';
import 'package:flutter_application_1/features/home/ui/widgets/bottomPanel.dart';
import 'package:flutter_application_1/features/home/ui/widgets/playButton.dart';
import 'package:flutter_application_1/features/home/ui/widgets/playerInfo.dart';
import '../../../core/services/auth_service.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  int _selectedModeIndex = 0; // 0 = BankCo, 1 = Injera, 2 = Pass & Play

  void _onModeSelected(int index) {
    setState(() {
      _selectedModeIndex = index;
    });
  }

  void _playNow() {
    if (_selectedModeIndex == 1) {
      // Coming soon
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Injera be Wot – Coming Soon!")),
      );
      return;
    }

    if (_selectedModeIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BankCoPage()),
      );
    } else if (_selectedModeIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PassNPlayPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'lib/assets/images/HomeHero2.png',
                  fit: BoxFit.cover,
                  color: AppTheme.primaryGold.withOpacity(0.05),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: PlayerInfo(
                  user: user,
                  onLogout: () async {
                    await authService.signOut();
                  },
                ),
              ),
              // Floating PLAY BUTTON
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.48,
                left: 0,
                right: 0,
                child: Center(child: PlayButton(onPressed: _playNow)),
              ),
              // Bottom panel (mode selector)
              Positioned(
                bottom: -10,
                left: 0,
                right: 0,
                child: BottomPanel(
                  selectedModeIndex: _selectedModeIndex,
                  onModeSelected: _onModeSelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
