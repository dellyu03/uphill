import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/dummy_auth_service.dart';
import '../../main_scaffold.dart';

/// 온보딩 Step 4: 아침 시작 시간 설정
class OnboardingStep4Screen extends StatefulWidget {
  const OnboardingStep4Screen({super.key});

  @override
  State<OnboardingStep4Screen> createState() => _OnboardingStep4ScreenState();
}

class _OnboardingStep4ScreenState extends State<OnboardingStep4Screen> {
  int _selectedHour = 9;
  int _selectedMinute = 0;
  String _selectedPeriod = 'AM';

  final DummyAuthService _authService = DummyAuthService();

  void _onHourChanged(int index) {
    setState(() {
      _selectedHour = index + 1;
    });
  }

  void _onMinuteChanged(int index) {
    setState(() {
      _selectedMinute = index;
    });
  }

  void _onPeriodChanged(int index) {
    setState(() {
      _selectedPeriod = index == 0 ? 'AM' : 'PM';
    });
  }

  Future<void> _completeOnboarding() async {
    // 이전 화면들에서 전달받은 데이터
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final onboardingData = {
      'name': args?['name'] ?? '사용자',
      'age': args?['age'] ?? 0,
      'gender': args?['gender'] ?? '미설정',
      'hasCamera': args?['hasCamera'] ?? false,
      'morningStartTime': {
        'hour': _selectedHour,
        'minute': _selectedMinute,
        'period': _selectedPeriod,
      },
      'completedAt': DateTime.now().toIso8601String(),
    };

    // 온보딩 완료 처리
    await _authService.completeOnboarding(onboardingData: onboardingData);

    if (mounted) {
      // 메인 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScaffold()),
        (route) => false,
      );
    }
  }

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
                    begin: const Alignment(0, -0.6),
                    end: const Alignment(0, 1.2),
                    colors: [
                      const Color(0xFFBDDE54).withValues(alpha: 0),
                      const Color(0xFFC7DE5D).withValues(alpha: 0.196),
                      const Color(0xFFEAF0C2).withValues(alpha: 0.6),
                      const Color(0xFFD4E090).withValues(alpha: 0.6),
                      const Color(0xFFAABB49).withValues(alpha: 0.6),
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
                    const SizedBox(height: 20),
                    _buildTopBar(),
                    const SizedBox(height: 32),
                    Text(
                      '저녁은\n몇시에 마무리하나요?',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF787878),
                        letterSpacing: -0.64,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    _buildTimePicker(),
                    const Spacer(),
                    _buildCompleteButton(),
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

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 24,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildProgressBar()),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFFB8D761),
              borderRadius: BorderRadius.circular(2.25),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFFB8D761),
              borderRadius: BorderRadius.circular(2.25),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(2.25),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour picker
              _buildWheelPicker(
                itemCount: 12,
                selectedValue: _selectedHour - 1,
                onSelectedItemChanged: _onHourChanged,
                builder: (index) {
                  final hour = index + 1;
                  final isSelected = _selectedHour == hour;
                  return _buildTimeItem(hour.toString(), isSelected);
                },
              ),
              const SizedBox(width: 24),
              // Minute picker
              _buildWheelPicker(
                itemCount: 60,
                selectedValue: _selectedMinute,
                onSelectedItemChanged: _onMinuteChanged,
                builder: (index) {
                  final isSelected = _selectedMinute == index;
                  return _buildTimeItem(
                    index.toString().padLeft(2, '0'),
                    isSelected,
                  );
                },
              ),
              const SizedBox(width: 24),
              // AM/PM picker
              _buildWheelPicker(
                itemCount: 2,
                selectedValue: _selectedPeriod == 'AM' ? 0 : 1,
                onSelectedItemChanged: _onPeriodChanged,
                builder: (index) {
                  final period = index == 0 ? 'AM' : 'PM';
                  final isSelected = _selectedPeriod == period;
                  return _buildTimeItem(period, isSelected);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String text, bool isSelected) {
    return Center(
      child: Container(
        width: 100, // Matching padding logic of Figma
        height: 56,
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              )
            : null,
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.notoSansKr(
            fontSize: 24,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: const Color(0xFF111111),
            letterSpacing: -0.48,
          ),
        ),
      ),
    );
  }

  Widget _buildWheelPicker({
    required int itemCount,
    required int selectedValue,
    required ValueChanged<int> onSelectedItemChanged,
    required Widget Function(int) builder,
  }) {
    return SizedBox(
      width: 100,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: selectedValue),
        itemExtent: 70,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) => builder(index),
          childCount: itemCount,
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _completeOnboarding,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF9CAA7D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          '선택완료',
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
