import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 온보딩 Step 3: 사용자 정보 입력 (이름, 나이, 성별)
class OnboardingStep3Screen extends StatefulWidget {
  const OnboardingStep3Screen({super.key});

  @override
  State<OnboardingStep3Screen> createState() => _OnboardingStep3ScreenState();
}

class _OnboardingStep3ScreenState extends State<OnboardingStep3Screen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool get canProceed {
    return _nameController.text.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _selectedGender != null;
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.only(
              top: 40,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGenderOption('여성', setModalState),
                const SizedBox(height: 20),
                _buildGenderOption('남성', setModalState),
                const SizedBox(height: 20),
                _buildGenderOption('선택 안함', setModalState),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedGender != null) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB0B97C),
                      foregroundColor: Colors.white,
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderOption(String gender, StateSetter setModalState) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _selectedGender = gender;
        });
        setState(() {}); // Update main screen state
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEEEEE) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          gender,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansKr(
            fontSize: 24,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? const Color(0xFF111111)
                : const Color(0xFFBBBBBB),
            letterSpacing: -0.48,
          ),
        ),
      ),
    );
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
                      '당신에 대해\n입력해주세요.',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF787878),
                        letterSpacing: -0.64,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildTextField(controller: _nameController, hint: '이름'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ageController,
                      hint: '나이',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    _buildGenderField(),
                    const Spacer(),
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
              color: const Color(0xFFD9D9D9).withValues(alpha: 0.8),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: (_) => setState(() {}),
        textAlign: TextAlign.center,
        style: GoogleFonts.notoSansKr(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4A4A4A),
          letterSpacing: -0.32,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A4A4A),
            letterSpacing: -0.32,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return GestureDetector(
      onTap: _showGenderPicker,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          _selectedGender ?? '성별',
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A4A4A),
            letterSpacing: -0.32,
          ),
        ),
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
                Navigator.pushNamed(
                  context,
                  '/onboarding/step4',
                  arguments: {
                    'name': _nameController.text,
                    'age': int.tryParse(_ageController.text) ?? 0,
                    'gender': _selectedGender,
                  },
                );
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
