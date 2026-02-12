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
              minHeight: 65, // 최소 높이 65px 루틴 이름과 루틴 시간의 최소 높이
            ),
            child: Container(
              decoration: BoxDecoration(
                // Type 1: Default (no gradient)
                // Type 2: Pinned (no gradient, different bg color)
                // Type 3: Updated (gradient background)
                color: isUpdated
                    ? null
                    : (isPinned ? colors.routinePinned : colors.routineDefault),
                gradient: isUpdated
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color.fromRGBO(196, 200, 165, 0.4),
                          const Color.fromRGBO(201, 207, 173, 1.0),
                        ],
                        stops: const [0.37, 1.0],
                      )
                    : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: isUpdated ? 4 : 6,
                    offset: Offset(0, isUpdated ? 1 : 1),
                  ),
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Additional gradient layer for updated cards (yellow tint)
                  if (isUpdated)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color.fromRGBO(255, 254, 211, 0),
                                const Color.fromRGBO(255, 254, 211, 0.2),
                              ],
                              stops: const [0.53, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Content - always use vertical layout
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start, // 상단 정렬로 변경
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
                                  color: const Color(0xFF515151),
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
                        const SizedBox(height: 4), // Figma: gap-[4px]
                        Text(
                          timeRange,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 11,
                            color: const Color.fromRGBO(27, 27, 27, 0.4),
                            height: 1.2,
                            fontWeight: FontWeight.w400,
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
