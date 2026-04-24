import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/cardModel.dart';
import 'package:flip_card/flip_card.dart';

class CardWidget extends StatefulWidget {
  final CardModel card;
  final bool isFaceUp;

  CardWidget({super.key, required this.card, required this.isFaceUp});

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isFaceUp && widget.isFaceUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && cardKey.currentState != null) {
          cardKey.currentState!.toggleCard();
        }
      });
    }
  }

  String getCardImage() {
    String value;

    switch (widget.card.value) {
      case 1:
        value = "ace";
        break;
      case 11:
        value = "jack";
        break;
      case 12:
        value = "queen";
        break;
      case 13:
        value = "king";
        break;
      default:
        value = widget.card.value.toString();
    }
    return "lib/assets/cards/${value}_of_${widget.card.suit}.png";
  }

  Widget buildCardContainer(Widget child) {
    return Container(
      margin: const EdgeInsets.all(6),
      width: 40,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 3)),
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
      autoFlipDuration: Duration(milliseconds: 500),
      direction: FlipDirection.HORIZONTAL,
      front: buildCardContainer(
        Image.asset('lib/assets/cards/card _back_blue.png', fit: BoxFit.cover),
      ),
      back: buildCardContainer(Image.asset(getCardImage(), fit: BoxFit.cover)),
    );
  }
}
