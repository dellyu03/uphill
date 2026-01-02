import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'routine_badge.dart';

class RoutineCard extends StatelessWidget {
  final String title;
  final String timeRange;
  final bool isUpdated;
  final bool isPinned;
  final VoidCallback onTap;

  const RoutineCard({
    super.key,
    required this.title,
    required this.timeRange,
    this.isUpdated = false,
    this.isPinned = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<UphillColors>()!;

    // Determine background color based on state
    Color diffBgColor = colors.routineDefault;
    if (isUpdated) {
      diffBgColor = colors.routineUpdated;
    } else if (isPinned) {
      diffBgColor = colors.routinePinned;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double height = constraints.maxHeight;
        // Adjust layout based on available height
        // Short routines (approx < 70px) need a compact row layout
        final bool isCompact = height < 70;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            // Removed fixed height: 100
            decoration: BoxDecoration(
              color: diffBgColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (isUpdated)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: isCompact ? 0 : 12.0, // Reduce vertical padding
                  ),
                  child: isCompact
                      ? _buildCompactLayout(colors, isUpdated)
                      : _buildFullLayout(colors, isUpdated, height),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactLayout(UphillColors colors, bool isUpdated) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Time in one line or simplified
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textEmphasis,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeRange,
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          if (isUpdated)
            const RoutineBadge(type: RoutineBadgeType.update, isCompact: true)
          else if (isPinned)
            const RoutineBadge(type: RoutineBadgeType.pinned, isCompact: true),
        ],
      ),
    );
  }

  Widget _buildFullLayout(UphillColors colors, bool isUpdated, double height) {
    // Check if we have enough space for spacing
    final bool tightSpacing = height < 90;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: isUpdated || isPinned ? 4 : 8,
        ), // 상단 여백 보정 Padding 대신 사용 가능
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textEmphasis,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isUpdated)
              const RoutineBadge(type: RoutineBadgeType.update)
            else if (isPinned)
              const RoutineBadge(type: RoutineBadgeType.pinned),
          ],
        ),
        SizedBox(height: tightSpacing ? 2 : 6),
        Text(
          timeRange,
          style: TextStyle(fontSize: 13, color: colors.textMuted, height: 1.2),
        ),
      ],
    );
  }
}
