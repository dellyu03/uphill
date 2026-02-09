import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/routine_service.dart';

class RoutineEditScreen extends StatefulWidget {
  final String routineId;
  final String title;
  final String timeRange;

  const RoutineEditScreen({
    super.key,
    required this.routineId,
    required this.title,
    required this.timeRange,
  });

  @override
  State<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends State<RoutineEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // ===== Routine Settings State =====
  late TextEditingController _titleController;
  String _selectedPurpose = '운동'; // Default
  final List<String> _purposes = [
    '운동',
    '독서',
    '학습',
    '명상',
    '건강',
    '기타',
  ]; // Example list

  bool _isFlexible = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 13, minute: 0);

  // Mon, Tue, Wed, Thu, Fri, Sat, Sun
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  final List<String> _weekDays = ['월', '화', '수', '목', '금', '토', '일'];

  String _notificationTime = '10분 전';
  final List<String> _notificationOptions = ['5분 전', '10분 전', '30분 전', '1시간 전'];
  bool _isNotificationEnabled = true;

  // ===== Space Settings State =====
  String _selectedRoom = '방 1';
  final List<String> _rooms = ['방 1', '방 2', '거실', '주방', '서재'];
  late TextEditingController _environmentDescController;

  // IoT Items
  List<Map<String, dynamic>> _iotItems = [];
  final List<String> _iotTypes = ['조명', '커튼', '스피커', '에어컨', '공기청정기'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _titleController = TextEditingController(text: widget.title);
    _environmentDescController = TextEditingController();

    _loadRoutineData();
  }

  Future<void> _loadRoutineData() async {
    try {
      final data = await RoutineService().getRoutine(widget.routineId);

      setState(() {
        // Load Routine Settings
        _titleController.text = data['title'] ?? widget.title;
        _selectedPurpose = data['purpose'] ?? '운동';
        if (!_purposes.contains(_selectedPurpose)) {
          _purposes.add(_selectedPurpose);
        }

        // Time parsing (HH:mm)
        if (data['time'] != null) {
          final parts = data['time'].split(':');
          _startTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
        if (data['end_time'] != null) {
          final parts = data['end_time'].split(':');
          _endTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }

        // Days
        final List<dynamic> days = data['days'] ?? [];
        for (int i = 0; i < 7; i++) {
          _selectedDays[i] = days.contains(i);
        }

        _isFlexible = data['is_flexible'] ?? true;
        _notificationTime = data['notification_time'] ?? '10분 전';

        // Load Space Settings
        _selectedRoom = data['space'] ?? '방 1';
        _environmentDescController.text = data['description'] ?? '';

        if (data['iot_devices'] != null) {
          _iotItems = List<Map<String, dynamic>>.from(data['iot_devices']);
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading routine: $e');
      setState(() {
        _isLoading = false;
      });
      // Fallback or error handling
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _environmentDescController.dispose();
    super.dispose();
  }

  Future<void> _saveRoutine() async {
    try {
      // 시간 형식 변환
      final startTimeStr =
          '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
      final endTimeStr =
          '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

      List<int> days = [];
      for (int i = 0; i < 7; i++) {
        if (_selectedDays[i]) days.add(i);
      }

      await RoutineService().updateRoutine(
        routineId: widget.routineId,
        title: _titleController.text,
        time: startTimeStr,
        endTime: endTimeStr,
        category: _selectedPurpose,
        purpose: _selectedPurpose,
        days: days,
        space: _selectedRoom,
        description: _environmentDescController.text,
        isFlexible: _isFlexible,
        notificationTime: _notificationTime,
        iotDevices: _iotItems,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('루틴이 수정되었습니다')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('수정 실패: $e')));
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _getSelectedDaysString() {
    List<String> selected = [];
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) selected.add(_weekDays[i]);
    }
    if (selected.isEmpty) return '선택 안함';
    if (selected.length == 7) return '매일';
    return selected.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    // If getting theme text emphasis color
    final theme = Theme.of(context);
    final uphillColors = theme.extension<UphillColors>();
    final textColor = uphillColors?.textEmphasis ?? Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '루틴 수정',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveRoutine,
            child: const Text(
              '완료',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: textColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: textColor,
          tabs: const [
            Tab(text: '루틴 설정'),
            Tab(text: '공간 설정'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRoutineSettings(uphillColors),
                _buildSpaceSettings(uphillColors),
              ],
            ),
    );
  }

  Widget _buildRoutineSettings(UphillColors? colors) {
    final textColor = colors?.textEmphasis ?? Colors.black;
    final mutedColor = colors?.textMuted ?? Colors.grey;
    final borderColor = colors?.dateSelectedBg ?? Colors.black12;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('루틴명', textColor),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: '루틴 이름을 입력하세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildLabel('목적', textColor),
          Wrap(
            spacing: 8,
            children: _purposes.map((purpose) {
              final isSelected = _selectedPurpose == purpose;
              return ChoiceChip(
                label: Text(purpose),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPurpose = purpose;
                  });
                },
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('루틴 성격', textColor),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildSegmentButton('변동가능', _isFlexible),
                    _buildSegmentButton('불가능', !_isFlexible),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          _buildLabel('시간 설정', textColor),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildTimeRow(
                  '시작 시간',
                  _startTime,
                  (time) => setState(() => _startTime = time),
                ),
                const Divider(),
                _buildTimeRow(
                  '종료 시간',
                  _endTime,
                  (time) => setState(() => _endTime = time),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          _buildLabel('반복 요일', textColor),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getSelectedDaysString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                InkWell(
                  onTap: _showDaySelectorDialog,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          _buildLabel('알림 설정', textColor),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _notificationTime,
            items: _notificationOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => _notificationTime = val!),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _isNotificationEnabled,
                onChanged: (val) =>
                    setState(() => _isNotificationEnabled = val!),
                activeColor: textColor,
              ),
              Expanded(
                child: Text(
                  'IoT 기기 연동 알림 받기',
                  style: TextStyle(color: mutedColor, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSpaceSettings(UphillColors? colors) {
    // Basic placeholder for now, re-implementing Step 3 logic
    final textColor = colors?.textEmphasis ?? Colors.black;
    final borderColor = colors?.dateSelectedBg ?? Colors.black12;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('공간 선택', textColor),
          DropdownButtonFormField<String>(
            value: _selectedRoom,
            items: _rooms
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => _selectedRoom = val!),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 24),
          _buildLabel('환경 설명', textColor),
          TextField(
            controller: _environmentDescController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '이 루틴을 위한 환경을 묘사해주세요.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 32),
          _buildLabel('IoT 기기 관리', textColor),
          const SizedBox(height: 12),
          if (_iotItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('연동된 기기가 없습니다.'),
            )
          else
            ..._iotItems.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.power),
                  title: Text(item['type'] ?? 'Unknown'),
                  subtitle: item['hasBrightness'] == true
                      ? Text('밝기: ${(item['brightness'] * 100).toInt()}%')
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _iotItems.remove(item);
                      });
                    },
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('기기 선택'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _iotTypes.length,
                        itemBuilder: (context, index) {
                          final type = _iotTypes[index];
                          return ListTile(
                            title: Text(type),
                            onTap: () {
                              setState(() {
                                _iotItems.add({
                                  'type': type,
                                  'brightness': 0.5,
                                  'hasBrightness': type == '조명',
                                });
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('기기 추가'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSegmentButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlexible = (text == '변동가능');
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
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        TextButton(
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (picked != null) onChanged(picked);
          },
          child: Text(
            _formatTime(time),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _showDaySelectorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Use StatefulBuilder to handle dialog state
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('반복 요일 선택'),
              content: Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  return FilterChip(
                    label: Text(_weekDays[index]),
                    selected: _selectedDays[index],
                    onSelected: (selected) {
                      setDialogState(() {
                        _selectedDays[index] = selected;
                      });
                      // Update main state as well
                      setState(() {
                        _selectedDays[index] = selected;
                      });
                    },
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
}
