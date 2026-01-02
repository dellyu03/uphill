import 'package:flutter/material.dart';

enum RoutineBadgeType { update, pinned }

class RoutineBadge extends StatelessWidget {
  final RoutineBadgeType type;
  final bool isCompact;

  const RoutineBadge({super.key, required this.type, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    if (type == RoutineBadgeType.pinned) {
      return Icon(
        Icons.push_pin,
        color: Colors.black54,
        size: isCompact ? 16 : 20,
      );
    }

    // Update Badge
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Update',
        style: TextStyle(
          fontSize: isCompact ? 10 : 11,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
