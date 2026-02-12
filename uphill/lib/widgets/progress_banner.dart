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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onPlayTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), // Figma rounded-[20px]
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 6,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              // 체크 아이콘
              // Figma imgVector840, small size around 10-12px
              const Icon(Icons.check, color: Color(0xFF7B8A2E), size: 14),
              const SizedBox(width: 10),
              // "현재 {루틴이름} 진행 중.." 텍스트
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '현재 ',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8C8C8C),
                        ),
                      ),
                      TextSpan(
                        text: routineTitle,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF98A340),
                        ),
                      ),
                      TextSpan(
                        text: ' 진행 중..',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8C8C8C),
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 10),
              // 재생 버튼
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5D3C6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF5A5A5A),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
