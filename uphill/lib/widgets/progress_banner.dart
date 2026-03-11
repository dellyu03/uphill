import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 현재 진행 중인 루틴을 보여주는 배너 위젯
class ProgressBanner extends StatelessWidget {
  /// 진행 중인 루틴 이름
  final String routineTitle;

  /// 재생 버튼 탭 콜백
  final VoidCallback onPlayTap;

  const ProgressBanner({
    super.key,
    required this.routineTitle,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onPlayTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), // Figma rounded-[20px]
            border: Border.all(color: const Color(0xFFBAC65F), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 6,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 체크 아이콘
              const Icon(Icons.check, color: Color(0xFF7B8A2E), size: 16),
              const SizedBox(width: 8),
              // "현재 {루틴이름} 진행 중.." 텍스트
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '현재 ',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8C8C8C),
                          letterSpacing: -0.48,
                        ),
                      ),
                      TextSpan(
                        text: routineTitle,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF98A340),
                          letterSpacing: -0.48,
                        ),
                      ),
                      TextSpan(
                        text: ' 진행 중..',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8C8C8C),
                          letterSpacing: -0.48,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
