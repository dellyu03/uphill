import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum RoutineBadgeType { update, pinned }

class RoutineBadge extends StatelessWidget {
  final RoutineBadgeType type;
  final bool isCompact;

  const RoutineBadge({super.key, required this.type, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    if (type == RoutineBadgeType.pinned) {
      return Transform.rotate(
        angle: 41.11 * pi / 180,
        child: Icon(
          Icons.push_pin,
          color: Colors.white.withValues(alpha: 0.7),
          size: isCompact ? 16 : 20,
        ),
      );
    }

    // Update Badge — Figma: white bg, dark text
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Update',
        style: GoogleFonts.notoSansKr(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: const Color.fromRGBO(88, 88, 88, 0.9),
          letterSpacing: -0.33,
        ),
      ),
    );
  }
}
