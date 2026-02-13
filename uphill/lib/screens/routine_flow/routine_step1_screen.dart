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
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '루틴 등록',
          style: GoogleFonts.notoSansKr(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 10),
                    // Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 4, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            color: const Color(0xFFE0E0E0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            color: const Color(0xFFE0E0E0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '어떤 루틴을\n진행할 예정이신가요?',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: Colors.black,
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
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _showPurposeSelectionSheet,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                            child: Text(
                              _selectedPurpose,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '루틴환경',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '공간',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedSpace,
                              underline: const SizedBox(),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: _spaces.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.notoSansKr(fontSize: 14),
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
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '다음',
                    style: GoogleFonts.notoSansKr(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
        fontWeight: FontWeight.bold,
        color: Colors.black,
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
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.notoSansKr(color: const Color(0xFFC6C5C3)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  void _showPurposeSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                ),
              ),
              const SizedBox(height: 16),
              ..._purposes.map(
                (purpose) => ListTile(
                  title: Text(purpose, style: GoogleFonts.notoSansKr()),
                  onTap: () {
                    setState(() => _selectedPurpose = purpose);
                    Navigator.pop(context);
                  },
                  trailing: _selectedPurpose == purpose
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                ),
              ),
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
