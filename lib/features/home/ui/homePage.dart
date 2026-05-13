import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo/ui/backCo.dart';
import 'package:flutter_application_1/features/bankCo%20Pass%20N%20Play/ui/backCoPassNPlay.dart';
import 'package:flutter_application_1/features/home/ui/widgets/bottomPanel.dart';
import 'package:flutter_application_1/features/home/ui/widgets/playButton.dart';
import 'package:flutter_application_1/features/home/ui/widgets/playerInfo.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedModeIndex =
      0; // 0 = BankCo, 1 = Injera, 2 = Pass & Play, 3 = Play Online

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
    } else if (_selectedModeIndex == 3) {
      // TODO: Navigate to multiplayer lobby when ready
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Online Multiplayer – Coming Soon")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onChangeName: () async {
                    // Refresh UI after name change
                    setState(() {});
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
