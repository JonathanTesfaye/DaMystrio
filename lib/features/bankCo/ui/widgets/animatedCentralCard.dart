import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo/logic/da_bank_co_state.dart';
import 'package:flutter_application_1/features/bankCo/ui/widgets/cardWidget.dart';

/// A widget that shows the current player's cards with a sequential reveal animation:
/// - First card appears face down, then flips face up
/// - Second card appears face down, then flips face up
/// - Third card (if exists) drops down from above
class AnimatedCentralCards extends StatefulWidget {
  final DaBankCoPlayer player;

  const AnimatedCentralCards({
    super.key, // Change this key to force a full animation reset (e.g., on turn change)
    required this.player,
  });

  @override
  State<AnimatedCentralCards> createState() => _AnimatedCentralCardsState();
}

class _AnimatedCentralCardsState extends State<AnimatedCentralCards> {
  bool _firstCardVisible = false;
  bool _firstCardFaceUp = false;
  bool _secondCardVisible = false;
  bool _secondCardFaceUp = false;
  bool _thirdCardDropped = false;
  bool _animationStarted = false;
  int _previousCardCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCardCount = widget.player.cards.length;
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedCentralCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the key changed, treat as a new turn -> reset everything
    if (oldWidget.key != widget.key) {
      _resetAndRestart();
      return;
    }
    // Same turn, check if a third card appeared
    final newCount = widget.player.cards.length;
    if (newCount == 3 && _previousCardCount == 2 && !_thirdCardDropped) {
      _animateThirdCard();
    }
    _previousCardCount = newCount;
  }

  void _resetAndRestart() {
    setState(() {
      _firstCardVisible = false;
      _firstCardFaceUp = false;
      _secondCardVisible = false;
      _secondCardFaceUp = false;
      _thirdCardDropped = false;
      _animationStarted = false;
    });
    _startAnimation();
  }

  void _startAnimation() {
    if (_animationStarted) return;
    _animationStarted = true;

    final cards = widget.player.cards;
    if (cards.length < 2) return;

    setState(() => _firstCardVisible = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _firstCardFaceUp = true);
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _secondCardVisible = true);
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _secondCardFaceUp = true);
    });

    if (cards.length == 3) _animateThirdCard();
  }

  void _animateThirdCard() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _thirdCardDropped = true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.player.cards;
    if (cards.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 100),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.pureBlack.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.primaryGold, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _firstCardVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: CardWidget(card: cards[0], isFaceUp: _firstCardFaceUp),
              ),
              const SizedBox(width: 16),
              AnimatedOpacity(
                opacity: _secondCardVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: CardWidget(card: cards[1], isFaceUp: _secondCardFaceUp),
              ),
            ],
          ),
          if (cards.length == 3) ...[
            const SizedBox(height: 16),
            AnimatedSlide(
              offset: _thirdCardDropped ? Offset.zero : const Offset(0, 2),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: CardWidget(card: cards[2], isFaceUp: true),
            ),
          ],
        ],
      ),
    );
  }
}
