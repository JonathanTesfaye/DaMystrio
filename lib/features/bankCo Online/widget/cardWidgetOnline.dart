import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_application_1/features/bankCo%20Online/model/cardModelOnline.dart';

class CardWidget extends StatefulWidget {
  final CardModelOnline card;
  final bool isFaceUp;

  const CardWidget({super.key, required this.card, required this.isFaceUp});

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  bool _isDisposed = false; // add this

  @override
  void didUpdateWidget(covariant CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDisposed && !oldWidget.isFaceUp && widget.isFaceUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted && cardKey.currentState != null) {
          cardKey.currentState!.toggleCard();
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  String _suitToImageName(String suitSymbol) {
    switch (suitSymbol) {
      case '♠':
        return 'spades';
      case '♥':
        return 'hearts';
      case '♦':
        return 'diamonds';
      case '♣':
        return 'clubs';
      default:
        return suitSymbol;
    }
  }

  String getCardImage() {
    String value;
    final label = widget.card.label.toLowerCase();
    switch (label) {
      case 'a':
        value = 'ace';
        break;
      case 'j':
        value = 'jack';
        break;
      case 'q':
        value = 'queen';
        break;
      case 'k':
        value = 'king';
        break;
      default:
        value = label;
    }
    final suitName = _suitToImageName(widget.card.suit);
    return "lib/assets/cards/${value}_of_$suitName.png";
  }

  Widget buildCardContainer(Widget child) {
    return Container(
      margin: const EdgeInsets.all(6),
      width: 40,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(5), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      key: cardKey,
      flipOnTouch: false,
      fill: Fill.fillBack,
      autoFlipDuration: const Duration(milliseconds: 500),
      direction: FlipDirection.HORIZONTAL,
      front: buildCardContainer(
        Image.asset('lib/assets/cards/CardBack.png', fit: BoxFit.cover),
      ),
      back: buildCardContainer(Image.asset(getCardImage(), fit: BoxFit.cover)),
    );
  }
}
