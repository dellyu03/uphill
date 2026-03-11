import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routine_step3_screen.dart';

class RoutineStep2Screen extends StatefulWidget {
  final String routineTitle;
  final String purpose;
  final String space;
  final String description;

  const RoutineStep2Screen({
    super.key,
    required this.routineTitle,
    required this.purpose,
    required this.space,
    required this.description,
  });

  @override
  State<RoutineStep2Screen> createState() => _RoutineStep2ScreenState();
}

class _RoutineStep2ScreenState extends State<RoutineStep2Screen> {
  // State variables
  bool _isFlexible = true; // '변동가능' vs '불가능'
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  List<int> _selectedDays = [
    1,
    2,
    3,
  ]; // Mon, Tue, Wed (0=Sun if backend uses it, or 1=Mon) - Let's assume 0=Sun, 1=Mon...
  String _notificationTime = '10분 전';

  final List<String> _notificationOptions = ['5분 전', '10분 전', '15분 전', '30분 전'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), // 1단계와 동일
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ), // 24 -> 20
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Bar (Step 2)
                    Row(
                      children: [
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
                      ],
                    ),
                    const SizedBox(height: 52), // 32 -> 52
                    Text(
                      '언제 루틴을 진행할\n예정이신가요?',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 30, // 24 -> 30
                        fontWeight: FontWeight.w500, // bold -> Medium(500)
                        height: 1.5,
                        letterSpacing: -0.3,
                        color: const Color(0xFF292B32),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 1. 루틴 성격
                    _buildSectionLabel('루틴 성격'),
                    const SizedBox(height: 12),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEED),
                        borderRadius: BorderRadius.circular(12), // 8 -> 12
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildToggleOption('변동 가능', _isFlexible),
                          ),
                          Expanded(
                            child: _buildToggleOption('변동 불가능', !_isFlexible),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 2. 루틴 지속 시간
                    _buildSectionLabel('루틴 지속 시간'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        children: [
                          // Time Row
                          Row(
                            children: [
                              Text(
                                '루틴 지속 시간',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color.fromRGBO(69, 69, 66, 0.8),
                                  letterSpacing: -0.14,
                                ),
                              ),
                              const Spacer(),
                              _buildTimeButton(
                                _startTime,
                                (val) => setState(() => _startTime = val),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text('~'),
                              ),
                              _buildTimeButton(
                                _endTime,
                                (val) => setState(() => _endTime = val),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          // Repeat Row
                          InkWell(
                            onTap: _showDaySelectionDialog,
                            child: Row(
                              children: [
                                Text(
                                  '반복',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color.fromRGBO(
                                      69,
                                      69,
                                      66,
                                      0.8,
                                    ),
                                    letterSpacing: -0.14,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    for (int d in _selectedDays)
                                      Container(
                                        margin: const EdgeInsets.only(left: 4),
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE5EF9F),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          [
                                            '월',
                                            '화',
                                            '수',
                                            '목',
                                            '금',
                                            '토',
                                            '일',
                                          ][d],
                                          style: GoogleFonts.notoSansKr(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF484846),
                                            letterSpacing: -0.14,
                                          ),
                                        ),
                                      ),
                                    if (_selectedDays.isEmpty)
                                      Text(
                                        '선택 안함',
                                        style: GoogleFonts.notoSansKr(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color.fromRGBO(
                                            69,
                                            69,
                                            66,
                                            0.8,
                                          ),
                                          letterSpacing: -0.14,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  size: 16,
                                  color: Color(0xFFC6C5C3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3. 안내 시간
                    _buildSectionLabel('안내 시간'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE6E6E6),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _notificationTime,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF484846),
                                  size: 16,
                                ),
                                items: _notificationOptions.map((String value) {
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
                                    setState(
                                      () => _notificationTime = newValue,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFFB3B3B3), // info icon color
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '설정된 시간에 따라 N분 전부터 IOT사물이 연동됩니다.',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12, // 12px
                              color: const Color.fromRGBO(179, 179, 179, 1),
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 70),
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
        fontWeight: FontWeight.w600, // Semibold
        color: const Color(0xFF484846),
        letterSpacing: -0.14,
      ),
    );
  }

  Widget _buildToggleOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlexible = (text == '변동 가능');
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4, // shadow settings
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.notoSansKr(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF484846)
                : const Color.fromRGBO(136, 136, 128, 0.8),
            letterSpacing: -0.14,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(TimeOfDay time, Function(TimeOfDay) onChanged) {
    return InkWell(
      onTap: () => _showTimePicker(time, onChanged),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF292B32),
                letterSpacing: -0.14,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_right_rounded,
              color: Color(0xFFC6C5C3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker(TimeOfDay initialTime, Function(TimeOfDay) onChanged) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                  2024,
                  1,
                  1,
                  initialTime.hour,
                  initialTime.minute,
                ),
                onDateTimeChanged: (val) {
                  onChanged(TimeOfDay.fromDateTime(val));
                },
              ),
            ),
            CupertinoButton(
              child: const Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDaySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final tempDays = List<int>.from(_selectedDays);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('반복 요일 선택'),
              content: Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  // 0: Mon, 1: Tue, ... 6: Sun (Matching system standard)
                  final dayNames = ['월', '화', '수', '목', '금', '토', '일'];
                  final isSelected = tempDays.contains(index);
                  return FilterChip(
                    label: Text(dayNames[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setStateDialog(() {
                        if (selected) {
                          tempDays.add(index);
                        } else {
                          tempDays.remove(index);
                        }
                        tempDays.sort();
                      });
                    },
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDays = tempDays;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onNextPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineStep3Screen(
          routineTitle: widget.routineTitle,
          purpose: widget.purpose,
          space: widget.space,
          description: widget.description,
          isFlexible: _isFlexible,
          startTime: _startTime,
          endTime: _endTime,
          selectedDays: _selectedDays,
          notificationTime: _notificationTime,
        ),
      ),
    );
  }
}
