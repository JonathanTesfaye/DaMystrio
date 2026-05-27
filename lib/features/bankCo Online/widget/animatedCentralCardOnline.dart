import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';
import 'package:flutter_application_1/features/bankCo%20Online/logic/OnlineMatchState.dart';
import 'package:flutter_application_1/features/bankCo%20Online/widget/cardWidgetOnline.dart';

class AnimatedCentralCards extends StatefulWidget {
  final OnlinePlayer player;
  final void Function(String rank, String suit)? onCardTap;

  const AnimatedCentralCards({super.key, required this.player, this.onCardTap});

  @override
  State<AnimatedCentralCards> createState() => _AnimatedCentralCardsState();
}

class _AnimatedCentralCardsState extends State<AnimatedCentralCards> {
  bool _firstCardVisible = false;
  bool _firstCardFaceUp = false;
  bool _secondCardVisible = false;
  bool _secondCardFaceUp = false;
  bool _thirdCardVisible = false; // renamed from _thirdCardDropped
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
    if (oldWidget.key != widget.key) {
      _resetAndRestart();
      return;
    }
    final newCount = widget.player.cards.length;
    if (newCount == 3 && _previousCardCount == 2 && !_thirdCardVisible) {
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
      _thirdCardVisible = false;
      _animationStarted = false;
    });
    _startAnimation();
  }

  void _startAnimation() {
    if (_animationStarted) return;
    _animationStarted = true;

    final cards = widget.player.cards;
    if (cards.length < 2) return;

    Future.delayed(Duration.zero, () {
      if (mounted) setState(() => _firstCardVisible = true);
    });
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
    // No slide – just make the third card appear after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _thirdCardVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.player.cards;
    if (cards.isEmpty) return const SizedBox.shrink();

    Widget _buildTapWrapper(Widget child, int index) {
      if (index >= cards.length) return child;
      final card = cards[index];
      return GestureDetector(
        onTap: () => widget.onCardTap?.call(card.rank, card.suit),
        child: child,
      );
    }

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
              _buildTapWrapper(
                AnimatedOpacity(
                  opacity: _firstCardVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: CardWidget(card: cards[0], isFaceUp: _firstCardFaceUp),
                ),
                0,
              ),
              const SizedBox(width: 16),
              _buildTapWrapper(
                AnimatedOpacity(
                  opacity: _secondCardVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: CardWidget(
                    card: cards[1],
                    isFaceUp: _secondCardFaceUp,
                  ),
                ),
                1,
              ),
            ],
          ),
          if (cards.length == 3) ...[
            const SizedBox(height: 16),
            _buildTapWrapper(
              AnimatedOpacity(
                opacity: _thirdCardVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: CardWidget(card: cards[2], isFaceUp: true),
              ),
              2,
            ),
          ],
        ],
      ),
    );
  }
}
