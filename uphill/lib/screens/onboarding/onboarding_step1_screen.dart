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
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'SmartThings 사용을 위해\n아래 항목에 동의해주세요',
                style: GoogleFonts.notoSansKr(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1B1B),
                  letterSpacing: -0.72,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 60),
              _buildAgreementCard(),
              const Spacer(),
              _buildNextButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              color: const Color(0xFF1B1B1B),
              letterSpacing: -0.48,
            ),
          ),
          const SizedBox(height: 24),
          _buildMainCheckbox(
            title: '모두 동의',
            value: _allAgree,
            onChanged: _toggleAllAgree,
            isMain: true,
          ),
          const SizedBox(height: 16),
          _buildCheckbox(
            title: '만 16세 이상입니다. (필수)',
            value: _over16,
            onChanged: (value) {
              setState(() => _over16 = value ?? false);
              _updateCheckboxes();
            },
          ),
          const SizedBox(height: 12),
          _buildCheckbox(
            title: '마케팅 정보 활용 동의 (선택)',
            value: _marketing,
            onChanged: (value) {
              setState(() => _marketing = value ?? false);
              _updateCheckboxes();
            },
          ),
          const SizedBox(height: 12),
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
    bool isMain = false,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value
                    ? const Color(0xFF9CAA7D)
                    : const Color(0xFFD1D1D1),
                width: 2,
              ),
              color: value ? const Color(0xFF9CAA7D) : Colors.transparent,
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B1B1B),
                letterSpacing: -0.48,
              ),
            ),
          ),
          if (isMain)
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF9CAA7D),
              size: 24,
            ),
        ],
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
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: value
                    ? const Color(0xFF9CAA7D)
                    : const Color(0xFFD1D1D1),
                width: 2,
              ),
              color: value ? const Color(0xFF9CAA7D) : Colors.transparent,
            ),
            child: value
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1B1B1B),
                letterSpacing: -0.42,
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
      height: 56,
      child: ElevatedButton(
        onPressed: canProceed
            ? () {
                Navigator.pushNamed(context, '/onboarding/step2');
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canProceed
              ? const Color(0xFF4A5568)
              : const Color(0xFFD1D1D1),
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: const Color(0xFFD1D1D1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          '다음',
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.48,
          ),
        ),
      ),
    );
  }
}
