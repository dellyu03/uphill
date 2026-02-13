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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildProgressBar(),
              const SizedBox(height: 32),
              Text(
                '아침은\n몇시에 시작하나요?',
                style: GoogleFonts.notoSansKr(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1B1B),
                  letterSpacing: -0.84,
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
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D1D1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return SizedBox(
      height: 220,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hour picker
          _buildWheelPicker(
            itemCount: 12,
            selectedValue: _selectedHour - 1,
            onSelectedItemChanged: _onHourChanged,
            builder: (index) {
              final hour = index + 1;
              return Center(
                child: Text(
                  hour.toString(),
                  style: GoogleFonts.notoSansKr(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: _selectedHour == hour
                        ? const Color(0xFF1B1B1B)
                        : const Color(0xFF1B1B1B).withValues(alpha: 0.3),
                    letterSpacing: -0.96,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 32),
          // Minute picker
          _buildWheelPicker(
            itemCount: 60,
            selectedValue: _selectedMinute,
            onSelectedItemChanged: _onMinuteChanged,
            builder: (index) {
              return Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: GoogleFonts.notoSansKr(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: _selectedMinute == index
                        ? const Color(0xFF1B1B1B)
                        : const Color(0xFF1B1B1B).withValues(alpha: 0.3),
                    letterSpacing: -0.96,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 32),
          // AM/PM picker
          _buildWheelPicker(
            itemCount: 2,
            selectedValue: _selectedPeriod == 'AM' ? 0 : 1,
            onSelectedItemChanged: _onPeriodChanged,
            builder: (index) {
              final period = index == 0 ? 'AM' : 'PM';
              return Center(
                child: Text(
                  period,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: _selectedPeriod == period
                        ? const Color(0xFF1B1B1B)
                        : const Color(0xFF1B1B1B).withValues(alpha: 0.3),
                    letterSpacing: -0.96,
                  ),
                ),
              );
            },
          ),
        ],
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
      width: 80,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: selectedValue),
        itemExtent: 60,
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
      height: 56,
      child: ElevatedButton(
        onPressed: _completeOnboarding,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1B1B1B),
          elevation: 0,
          shadowColor: Colors.black.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          '다음으로',
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
