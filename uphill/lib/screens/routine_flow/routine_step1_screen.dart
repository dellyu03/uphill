import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routine_step2_screen.dart';

class RoutineStep1Screen extends StatefulWidget {
  const RoutineStep1Screen({super.key});

  @override
  State<RoutineStep1Screen> createState() => _RoutineStep1ScreenState();
}

class _RoutineStep1ScreenState extends State<RoutineStep1Screen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedPurpose = '운동'; // Default or empty
  String _selectedSpace = '방 1';

  final List<String> _purposes = ['운동', '독서', '공부', '명상', '기타'];
  final List<String> _spaces = ['방 1', '거실', '주방', '침실', '서재'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '루틴 설정',
          style: GoogleFonts.notoSansKr(
            color: const Color(0xFF292B32),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC0C28D),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3E3E0),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3E3E0),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 52),
                    Text(
                      '어떤 루틴을\n진행할 예정이신가요?',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 30, // 24 -> 30
                        fontWeight: FontWeight.w500, // bold -> Medium(500)
                        height: 1.5,
                        letterSpacing: -0.3,
                        color: const Color(0xFF292B32),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 1. 루틴명
                    _buildSectionLabel('루틴명'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hintText: '예) 아침 스트레칭 루틴',
                    ),
                    const SizedBox(height: 32),

                    // 2. 루틴 상세 (목적)
                    _buildSectionLabel('루틴 상세'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '목적',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 14,
                            fontWeight: FontWeight.w500, // Medium
                            color: const Color.fromRGBO(69, 69, 66, 0.8),
                            letterSpacing: -0.14,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _showPurposeSelectionSheet,
                          borderRadius: BorderRadius.circular(12), // 8 -> 12
                          child: Container(
                            width: 160,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE6E6E6),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedPurpose,
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF484846),
                                    letterSpacing: -0.14,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF484846),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 3. 루틴 진행 환경
                    _buildSectionLabel('루틴 진행 환경'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12), // Figma 12px
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(
                              0,
                              0,
                              0,
                              0.04,
                            ), // 0px_2px_8px_0px
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                          const BoxShadow(
                            color: Color.fromRGBO(
                              0,
                              0,
                              0,
                              0.04,
                            ), // 0px_0px_4px_0px
                            blurRadius: 4,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            '루틴 환경',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14,
                              fontWeight: FontWeight.w500, // Medium
                              color: const Color.fromRGBO(69, 69, 66, 0.8),
                              letterSpacing: -0.14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '공간',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14,
                              fontWeight: FontWeight.w500, // Medium
                              color: const Color.fromRGBO(69, 69, 66, 0.8),
                              letterSpacing: -0.14,
                            ),
                          ),
                          const SizedBox(width: 10), // gap 10
                          Container(
                            height: 48,
                            width: 140, // 140 고정
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE6E6E6),
                              ), // Gray border
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSpace,
                                isExpanded: true, // 화살표 균등 배분
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF484846),
                                  size: 16,
                                ),
                                items: _spaces.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.notoSansKr(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF484846),
                                        letterSpacing: -0.14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  if (newValue != null) {
                                    setState(() => _selectedSpace = newValue);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 4. 추구하는 환경과 활동
                    _buildSectionLabel('추구하는 환경과 활동'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hintText: 'EX) 편안한 분위기에서의 가벼운 스트레칭',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // Bottom Button
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB0B97C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '다음',
                    style: GoogleFonts.notoSansKr(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.w600, // bold -> Semibold(600)
        color: const Color(0xFF484846),
        letterSpacing: -0.14,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.notoSansKr(
        fontSize: 16,
        color: const Color(0xFF292B32),
        fontWeight: FontWeight.w500,
      ),
      cursorColor: const Color(0xFF98A340), // 커서 색상을 앱 메인 컬러로 설정
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.notoSansKr(
          color: const Color.fromRGBO(136, 136, 128, 0.8),
          fontSize: 14, // 16 -> 14
        ),
        filled: true,
        fillColor: const Color(0xFFEEEEED), // 배경 변경
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), // 12 -> 14
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF98A340)), // 포커스시 테두리 색상
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  void _showPurposeSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '목적 선택',
                style: GoogleFonts.notoSansKr(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF292B32),
                  letterSpacing: -0.18,
                ),
              ),
              const SizedBox(height: 16),
              ..._purposes.map((purpose) {
                final isSelected = _selectedPurpose == purpose;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    purpose,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF98A340)
                          : const Color(0xFF292B32),
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedPurpose = purpose);
                    Navigator.pop(context);
                  },
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF98A340))
                      : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _onNextPressed() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("루틴 이름을 입력해주세요"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Navigate to Step 2 with data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineStep2Screen(
          routineTitle: _nameController.text.trim(),
          purpose: _selectedPurpose,
          space: _selectedSpace,
          description: _descriptionController.text.trim(),
        ),
      ),
    );
  }
}
