import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routine_badge.dart';

/// 루틴 카드 위젯
/// 3가지 타입을 지원합니다:
/// 1. Updated (올리브) — isUpdated: true
///    연두색 그라데이션 배경 + Update 배지, 일정 충돌 시 시간대 추천
/// 2. Pinned (고정) — isPinned: true
///    다크(#3D3D3D) 배경 + 핀 아이콘, 변경 불가
/// 3. Normal (일반) — 기본
///    흰색 배경 + 미세한 그림자, 충돌 시 이동 가능
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        decoration: _buildDecoration(),
        child: Stack(
          children: [
            // 콘텐츠
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isPinned
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
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
    );
  }

  BoxDecoration _buildDecoration() {
    if (isUpdated) {
      // 올리브 업데이트 카드 — Figma: 단색 E1EB96
      return BoxDecoration(
        color: const Color(0xFFE1EB96),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      );
    } else if (isPinned) {
      // 고정 루틴 카드 — Figma: #3D3D3D
      return BoxDecoration(
        color: const Color(0xFF3D3D3D),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      );
    } else {
      // 일반 루틴 카드 — Figma: white
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      );
    }
  }
}
