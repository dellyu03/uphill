import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 온보딩 Step 2: 카메라로 방 인식 확인
class OnboardingStep2Screen extends StatelessWidget {
  const OnboardingStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E8E7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Text(
                '카메라로 방 인식을\n시작할까요?',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansKr(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1B1B),
                  letterSpacing: -0.84,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 60),
              _buildPhoneIllustration(),
              const Spacer(flex: 2),
              _buildButtonRow(context),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneIllustration() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF9CAA7D).withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF9CAA7D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6B7A54), width: 3),
          ),
          child: const Center(
            child: Icon(
              Icons.sentiment_satisfied,
              size: 60,
              color: Color(0xFFE9E8E7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/onboarding/step3',
                  arguments: {'hasCamera': true},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1B1B1B),
                elevation: 0,
                shadowColor: Colors.black.withOpacity(0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                '예',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.48,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/onboarding/step3',
                  arguments: {'hasCamera': false},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1B1B1B),
                elevation: 0,
                shadowColor: Colors.black.withOpacity(0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                '아니요',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.48,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
