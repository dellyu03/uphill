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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    // Progress Bar (Step 2)
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 4, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
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
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '언제 진행할\n예정이신가요?',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 1. 루틴 성격
                    _buildSectionLabel('루틴 성격'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildToggleOption('변동가능', _isFlexible),
                          ),
                          Expanded(
                            child: _buildToggleOption('불가능', !_isFlexible),
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
                                  color: Colors.black,
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
                                    color: Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatSelectedDays(),
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionLabel('안내 시간'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: DropdownButton<String>(
                            value: _notificationTime,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: _notificationOptions.map((String value) {
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
                                setState(() => _notificationTime = newValue);
                              }
                            },
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
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '설정된 시간에 따라 N분 전부터 IOT사물이 연동됩니다.',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12,
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildToggleOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlexible = (text == '변동가능');
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
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
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.black : const Color(0xFF8E8E93),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          time.format(context),
          style: GoogleFonts.notoSansKr(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
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

  String _formatSelectedDays() {
    if (_selectedDays.length == 7) return '매일';
    if (_selectedDays.isEmpty) return '선택 안함';
    final dayNames = ['월', '화', '수', '목', '금', '토', '일'];
    return _selectedDays.map((d) => dayNames[d]).join(', ');
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
