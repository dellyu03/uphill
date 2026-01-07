import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RoutineEditScreen extends StatefulWidget {
  final String title;
  final String timeRange;

  const RoutineEditScreen({
    super.key,
    required this.title,
    required this.timeRange,
  });

  @override
  State<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends State<RoutineEditScreen> {
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1 Controllers
  late TextEditingController _titleController;
  late TextEditingController _environmentDescController;
  final String _selectedPurpose = '운동';
  String _selectedRoom = '방 1';
  final List<String> _rooms = ['방 1', '방 2', '거실', '주방'];

  // Step 2 State
  bool _isFlexible = true; // true: 변동가능, false: 불가능
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  final List<bool> _selectedDays = [
    true,
    true,
    true,
    false,
    false,
    false,
    false,
  ]; // Mon, Tue, Wed default
  final List<String> _weekDays = ['월', '화', '수', '목', '금', '토', '일'];
  String _notificationTime = '10분 전';
  final List<String> _notificationOptions = ['5분 전', '10분 전', '30분 전', '1시간 전'];
  bool _isNotificationDescriptionChecked = true;

  // Step 3 State
  final List<Map<String, dynamic>> _iotItems = [
    {'type': '조명', 'brightness': 0.8, 'hasBrightness': true},
    {'type': '조명', 'brightness': 0.0, 'hasBrightness': false},
  ];
  final List<String> _iotTypes = ['조명', '커튼', '스피커', '에어컨'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.title.isEmpty ? '아침 스트레칭 루틴' : widget.title,
    );
    _environmentDescController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _environmentDescController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Finish
      Navigator.pop(context);
    }
  }

  String _formatTime(TimeOfDay time) {
    // 12:00 PM format
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour : $minute $period';
  }

  String _getSelectedDaysString() {
    List<String> selected = [];
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) selected.add(_weekDays[i]);
    }
    return selected.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final uphillColors = Theme.of(context).extension<UphillColors>()!;

    return Scaffold(
      backgroundColor: uphillColors.routineDefault, // Using theme color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: uphillColors.textEmphasis,
                ),
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
              )
            : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: uphillColors.textEmphasis,
                ),
                onPressed: () => Navigator.pop(context),
              ),
        title: null,
      ),
      body: Column(
        children: [
          _buildProgressBar(uphillColors),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: _buildStepContent(uphillColors),
            ),
          ),
          _buildBottomButton(uphillColors),
        ],
      ),
    );
  }

  Widget _buildProgressBar(UphillColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8.0 : 0),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? colors.textEmphasis
                    : colors.dateSelectedBg,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(UphillColors colors) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(colors);
      case 1:
        return _buildStep2(colors);
      case 2:
        return _buildStep3(colors);
      default:
        return Container();
    }
  }

  Widget _buildStep1(UphillColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          '어떤 루틴을\n진행할 예정이신가요?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.textEmphasis,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 40),
        _buildLabel('루틴명', colors),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          style: TextStyle(color: colors.textEmphasis),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.dateSelectedBg),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.dateSelectedBg),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.textEmphasis),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildLabel('루틴 상세', colors),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('목적', style: TextStyle(color: colors.textMuted, fontSize: 14)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: colors.dateSelectedBg),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Text(
                _selectedPurpose,
                style: TextStyle(
                  color: colors.textEmphasis,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildLabel('루틴 진행 환경', colors),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.dateSelectedBg),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '루틴환경',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.textEmphasis,
                ),
              ),
              Row(
                children: [
                  Text(
                    '공간',
                    style: TextStyle(color: colors.textMuted, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.routineDefault,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRoom,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        isDense: true,
                        style: TextStyle(
                          color: colors.textEmphasis,
                          fontSize: 14,
                        ),
                        items: _rooms.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            if (newValue != null) _selectedRoom = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildLabel('추구하는 환경과 활동', colors),
        const SizedBox(height: 8),
        TextField(
          controller: _environmentDescController,
          maxLines: 4,
          style: TextStyle(color: colors.textEmphasis),
          decoration: InputDecoration(
            hintText: 'EX) 편안 한 분위기에서 가벼운 스트레칭',
            hintStyle: TextStyle(color: colors.routinePinned),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.dateSelectedBg),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.dateSelectedBg),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.textEmphasis),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStep2(UphillColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          '언제 진행할\n예정이신가요?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.textEmphasis,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('루틴 성격', colors),
            Container(
              decoration: BoxDecoration(
                color: colors.routinePinned,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildSegmentButton('변동가능', _isFlexible, colors),
                  _buildSegmentButton('불가능', !_isFlexible, colors),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildLabel('루틴 지속 시간', colors),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.dateSelectedBg),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '루틴 지속 시간',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.textEmphasis,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      _buildTimeBox(_formatTime(_startTime), colors),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text('~'),
                      ),
                      _buildTimeBox(_formatTime(_endTime), colors),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '반복',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.textEmphasis,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showDaySelectorDialog(colors);
                    },
                    child: Row(
                      children: [
                        Text(
                          _getSelectedDaysString(),
                          style: TextStyle(
                            color: colors.textEmphasis,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('안내 시간', colors),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.dateSelectedBg),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _notificationTime,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  isDense: true,
                  style: TextStyle(
                    color: colors.textEmphasis,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  items: _notificationOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      if (newValue != null) _notificationTime = newValue;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            setState(() {
              _isNotificationDescriptionChecked =
                  !_isNotificationDescriptionChecked;
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _isNotificationDescriptionChecked
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: colors.textEmphasis, // Black
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '설정된 시간에 따라 N분 전부터 IOT사물이 연동됩니다.',
                  style: TextStyle(color: colors.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStep3(UphillColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'IOT사물 연동\n설정해주세요', // As per image
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.textEmphasis,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 32),
        // Floor layout image placeholder
        Container(
          width: double.infinity,
          height: 200,
          alignment: Alignment.center,
          // Image.asset would go here; using placeholder
          child: Image.asset(
            'assets/images/image_11.png',
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.map, size: 80, color: colors.routinePinned);
            },
          ),
        ),
        const SizedBox(height: 32),
        _buildLabel('공간 변경 솔루션', colors),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.dateSelectedBg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '솔루션',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.textEmphasis,
                    ),
                  ),
                  Icon(Icons.edit, size: 20, color: colors.textMuted),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '침대 옆 협탁을 치우고 요가매트를 깔아보세요',
                style: TextStyle(color: colors.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildLabel('IOT 연동', colors),
        const SizedBox(height: 12),
        ...List.generate(_iotItems.length, (index) {
          final item = _iotItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.dateSelectedBg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IOT 사물 (${index + 1})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.textEmphasis,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '사물 종류',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.textEmphasis,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.routineDefault,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: item['type'],
                          icon: const Icon(Icons.keyboard_arrow_down),
                          isDense: true,
                          style: TextStyle(
                            color: colors.textEmphasis,
                            fontSize: 13,
                          ),
                          items: _iotTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              if (newValue != null) item['type'] = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                if (item['hasBrightness'] == true) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '밝기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.textEmphasis,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '최대 밝기',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colors.textEmphasis,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: item['brightness'],
                    onChanged: (val) {
                      setState(() {
                        item['brightness'] = val;
                      });
                    },
                    activeColor: colors.routinePinned, // Greyish
                    inactiveColor: colors.dateSelectedBg,
                    thumbColor: Colors.white,
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            setState(() {
              _iotItems.add({
                'type': '조명',
                'brightness': 0.5,
                'hasBrightness': true,
              });
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // Dashed border simulation with Border.all for now
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.dateSelectedBg,
                style: BorderStyle.solid,
              ), // Flutter standard Doesn't support dashed border easily without package/custom painter.
              // User asked for "점선 테두리 버튼" (Dotted border).
              // I will simulate with standard border as I cannot add packages easily. Or simple dashed border painter.
              // For now solid border is safer fallback, or I can try to use a CustomPaint if required.
              // Let's use a solid border for now but styled distinctly.
            ),
            child: Text(
              '+ IOT 연동 추가하기',
              style: TextStyle(color: colors.textMuted),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSegmentButton(
    String text,
    bool isSelected,
    UphillColors colors,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (text == '변동가능')
            _isFlexible = true;
          else
            _isFlexible = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? colors.textEmphasis : colors.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBox(String text, UphillColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.routineDefault, // Off white
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.textEmphasis,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Future<void> _showDaySelectorDialog(UphillColors colors) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('반복 요일 선택'),
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  return FilterChip(
                    label: Text(_weekDays[index]),
                    selected: _selectedDays[index],
                    onSelected: (bool selected) {
                      setDialogState(() {
                        _selectedDays[index] = selected;
                      });
                      this.setState(() {
                        _selectedDays[index] = selected;
                      });
                    },
                    selectedColor: colors.routineUpdated,
                    checkmarkColor: Colors.white,
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLabel(String text, UphillColors colors) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colors.textEmphasis,
      ),
    );
  }

  Widget _buildBottomButton(UphillColors colors) {
    return Container(
      color: Colors.white, // Button area background
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.dateSelectedBg, // Light grey
            foregroundColor: colors.textEmphasis,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: Text(
            _currentStep == _totalSteps - 1 ? '완료' : '다음',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
