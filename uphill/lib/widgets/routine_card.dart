import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'routine_badge.dart';

class RoutineCard extends StatelessWidget {
  final String title;
  final String timeRange;
  final bool isUpdated;
  final bool isPinned;
  final VoidCallback? onTap;

  const RoutineCard({
    super.key,
    required this.title,
    required this.timeRange,
    this.isUpdated = false,
    this.isPinned = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<UphillColors>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 60, // 최소 높이 60px
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isUpdated
                    ? null
                    : (isPinned ? colors.routinePinned : colors.routineDefault),
                gradient: isUpdated
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(196, 200, 165, 0.4),
                          Color.fromRGBO(201, 207, 173, 1.0),
                        ],
                        stops: [0.37, 1.0],
                      )
                    : null,
                borderRadius: BorderRadius.circular(10), // 20 -> 10
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: isUpdated ? 4 : 6,
                    offset: Offset(0, isUpdated ? 1 : 1),
                  ),
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.02),
                    blurRadius: 4,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  if (isUpdated)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(255, 254, 211, 0),
                                Color.fromRGBO(255, 254, 211, 0.2),
                              ],
                              stops: [0.53, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isPinned
                                      ? Colors.white
                                      : const Color(0xFF515151),
                                  letterSpacing: -0.45,
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
                        const SizedBox(height: 4),
                        Text(
                          timeRange,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 11,
                            color: isPinned
                                ? Colors.white.withValues(alpha: 0.4)
                                : const Color.fromRGBO(27, 27, 27, 0.4),
                            height: 1.2,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.33,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
