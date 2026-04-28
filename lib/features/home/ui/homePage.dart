import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo/backCo.dart';
import 'package:flutter_application_1/features/bankCo/logic/gameController.dart';
import 'package:flutter_application_1/features/home/ui/widgets/bottomPanel.dart';
import 'package:flutter_application_1/features/home/ui/widgets/playButton.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/playerInfo.dart';
import 'package:flutter_application_1/features/bankCo/ui/Poker.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'lib/assets/images/HomeHero.png',
                fit: BoxFit.fitHeight,
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

            //  PLAY BUTTON
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.48,
              left: 0,
              right: 0,
              child: Center(
                child: PlayButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => GameController()..init([]),
                          child: const PokerPage2(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            //  BOTTOM PANEL
            Positioned(bottom: 20, left: 0, right: 0, child: BottomPanel()),
          ],
        ),
      ),
    );
  }
}
