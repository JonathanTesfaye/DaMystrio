import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/appTheme.dart';

enum PointerDirection { up, down, left, right }

class ActionBubble extends StatelessWidget {
  final String message;
  final PointerDirection pointerDirection;

  const ActionBubble({
    super.key,
    required this.message,
    required this.pointerDirection,
  });

  TextStyle _getMessageStyle() {
    if (message.contains('won') || message.contains('wins')) {
      return AppTheme.captionGold.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.win,
      );
    } else if (message.contains('loses') || message.contains('lost')) {
      return AppTheme.captionGold.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.lose,
      );
    } else {
      return AppTheme.captionGold.copyWith(fontSize: 12);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.pureBlack.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.primaryGold, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildArrow(),
          const SizedBox(width: 12),
          Flexible(
            child: Text(message, style: _getMessageStyle(), softWrap: true),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    IconData arrow;
    switch (pointerDirection) {
      case PointerDirection.up:
        arrow = Icons.arrow_upward;
        break;
      case PointerDirection.down:
        arrow = Icons.arrow_downward;
        break;
      case PointerDirection.left:
        arrow = Icons.arrow_back;
        break;
      case PointerDirection.right:
        arrow = Icons.arrow_forward;
        break;
    }
    return Icon(arrow, color: AppTheme.primaryGold, size: 20);
  }
}
