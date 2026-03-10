import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 온보딩 Step 1: SmartThings 사용 권한 동의
class OnboardingStep1Screen extends StatefulWidget {
  const OnboardingStep1Screen({super.key});

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen> {
  bool _allAgree = false;
  bool _over16 = false;
  bool _marketing = false;
  bool _dataCollection = false;

  void _toggleAllAgree(bool? value) {
    setState(() {
      _allAgree = value ?? false;
      _over16 = _allAgree;
      _marketing = _allAgree;
      _dataCollection = _allAgree;
    });
  }

  void _updateCheckboxes() {
    setState(() {
      _allAgree = _over16 && _marketing && _dataCollection;
    });
  }

  bool get canProceed => _over16 && _dataCollection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFFF8F8F8)),
        child: Stack(
          children: [
            // Background Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(
                      0,
                      -0.6,
                    ), // Adjust to match CSS angle
                    end: const Alignment(0, 1.2),
                    colors: [
                      const Color(0xFFBDDE54).withValues(alpha: 0),
                      const Color(0xFFC7DE5D).withValues(alpha: 0.165),
                      const Color(0xFFEAF0C2).withValues(alpha: 0.5),
                      const Color(0xFFD4E090).withValues(alpha: 0.5),
                      const Color(0xFFAABB49).withValues(alpha: 0.5),
                    ],
                    stops: const [0.1048, 0.2995, 0.4909, 0.6743, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 70,
                    ), // StatusBar + Top padding margin
                    // Top Icon Placeholder (List & Check)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA5BB3D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.playlist_add_check,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'SmartThings ',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4A4A4A),
                              letterSpacing: -0.56,
                            ),
                          ),
                          TextSpan(
                            text: '사용을 위해\n아래 항목에 동의해주세요',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF787878),
                              letterSpacing: -0.56,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Agreement Card
                    _buildAgreementCard(),
                    const Spacer(),
                    // Next Button
                    _buildNextButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreementCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '서비스 이용을 위한 확인',
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6F9A00),
              letterSpacing: -0.48,
            ),
          ),
          const SizedBox(height: 20),
          _buildMainCheckbox(
            title: '모두 동의',
            value: _allAgree,
            onChanged: _toggleAllAgree,
          ),
          const SizedBox(height: 20),
          _buildCheckbox(
            title: '만 16세 이상입니다. (필수)',
            value: _over16,
            onChanged: (value) {
              setState(() => _over16 = value ?? false);
              _updateCheckboxes();
            },
          ),
          const SizedBox(height: 16),
          _buildCheckbox(
            title: '마케팅 정보 활용 동의 (선택)',
            value: _marketing,
            onChanged: (value) {
              setState(() => _marketing = value ?? false);
              _updateCheckboxes();
            },
          ),
          const SizedBox(height: 16),
          _buildCheckbox(
            title: '사용자 데이터 수집 동의',
            value: _dataCollection,
            onChanged: (value) {
              setState(() => _dataCollection = value ?? false);
              _updateCheckboxes();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A4A4A),
                letterSpacing: -0.36,
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD1D1D1), width: 1.5),
                color: value
                    ? const Color(0xFFBDDE54)
                    : Colors.transparent, // Active Check Color
              ),
              child: value
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD1D1D1), width: 1.5),
              color: value ? const Color(0xFFBDDE54) : Colors.transparent,
            ),
            child: value
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF666666),
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canProceed
            ? () {
                Navigator.pushNamed(context, '/onboarding/step2');
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF9CAA7D),
          elevation: 0,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
          disabledForegroundColor: const Color(
            0xFF9CAA7D,
          ).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          '다음',
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.32,
          ),
        ),
      ),
    );
  }
}
