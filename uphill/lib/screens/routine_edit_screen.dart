import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String _selectedPurpose = '운동';
  final List<String> _purposes = ['운동', '독서', '학습', '명상', '건강', '기타'];

  bool _isFlexible = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 13, minute: 0);

  final List<bool> _selectedDays = List.generate(7, (index) => false);
  final List<String> _weekDays = ['월', '화', '수', '목', '금', '토', '일'];

  String _notificationTime = '10분 전';
  final List<String> _notificationOptions = ['5분 전', '10분 전', '30분 전', '1시간 전'];

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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _titleController = TextEditingController(text: widget.title);
    _environmentDescController = TextEditingController();

    _loadRoutineData();
  }

  Future<void> _loadRoutineData() async {
    try {
      final data = await RoutineService().getRoutine(widget.routineId);

      setState(() {
        _titleController.text = data.title;
        _selectedPurpose = data.purpose ?? '운동';
        if (!_purposes.contains(_selectedPurpose)) {
          _purposes.add(_selectedPurpose);
        }

        if (data.time != null) {
          final parts = data.time!.split(':');
          _startTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
        if (data.endTime != null) {
          final parts = data.endTime!.split(':');
          _endTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }

        final List<int> days = data.days;
        for (int i = 0; i < 7; i++) {
          _selectedDays[i] = days.contains(i);
        }

        _isFlexible = data.isFlexible;
        _notificationTime = data.notificationTime ?? '10분 전';

        _selectedRoom = data.space ?? '방 1';
        _environmentDescController.text = data.description ?? '';

        if (data.iotDevices != null) {
          _iotItems = List<Map<String, dynamic>>.from(data.iotDevices!);
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading routine: $e');
      setState(() {
        _isLoading = false;
      });
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          '루틴수정',
          style: GoogleFonts.notoSansKr(
            color: const Color(0xFF292B32),
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: -0.16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF292B32),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildTabBar(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF555555)),
            )
          : TabBarView(
              controller: _tabController,
              children: [_buildRoutineSettings(), _buildSpaceSettings()],
            ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _tabController.index == 0
                          ? const Color(0xFF292B32)
                          : const Color(0xFFD9D9D9),
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  '루틴 설정',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _tabController.index == 0
                        ? const Color(0xFF292B32)
                        : const Color(0xFFB3B3B3),
                    letterSpacing: -0.14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _tabController.index == 1
                          ? const Color(0xFF292B32)
                          : const Color(0xFFD9D9D9),
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  '공간 설정',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _tabController.index == 1
                        ? const Color(0xFF292B32)
                        : const Color(0xFFB3B3B3),
                    letterSpacing: -0.14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineSettings() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Routine Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _titleController.text,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Routine Details Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '루틴 상세',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFC9C9C9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('목적', _selectedPurpose, () {
                        _showPurposeSelector();
                      }),
                      const SizedBox(height: 12),
                      _buildDetailRow('루틴환경', _selectedRoom, () {
                        _showRoomSelector();
                      }),
                      const SizedBox(height: 16),
                      const Text(
                        '추구하는 환경과 활동',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF363636),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _environmentDescController,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFBEBEBE),
                        ),
                        decoration: InputDecoration(
                          hintText: '편안한 분위기에서 스트레칭',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBEBEBE),
                          ),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.03),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFC9C9C9),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFC9C9C9),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF333333),
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Divider
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: const Color(0xFFD9D9D9),
          ),

          const SizedBox(height: 24),

          // Routine Progress Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '루틴 진행',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Routine Nature
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '루틴 성격',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildNatureButton('변동가능', _isFlexible),
                            ),
                            Expanded(
                              child: _buildNatureButton('불가능', !_isFlexible),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Routine Duration Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '루틴 지속 시간',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '루틴 지속 시간',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              _buildTimeBox(_formatTime(_startTime), () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: _startTime,
                                );
                                if (picked != null) {
                                  setState(() => _startTime = picked);
                                }
                              }),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '~',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              _buildTimeBox(_formatTime(_endTime), () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: _endTime,
                                );
                                if (picked != null) {
                                  setState(() => _endTime = picked);
                                }
                              }),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '반복',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: _showDaySelectorDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _getSelectedDaysString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3C3C3C),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Color(0xFF3C3C3C),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notification Time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '안내 시간',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    border: Border.all(color: const Color(0xFFD3D3D3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: _notificationTime,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF3C3C3C),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3C3C3C),
                    ),
                    items: _notificationOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _notificationTime = val!),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '설정된 시간에 따라 N분 전부터 IOT사물이 연동됩니다.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xCC000000),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Completion Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRoutine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF555555),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '완료',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.16,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF363636),
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Color(0xFF363636)),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Color(0xFF363636),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNatureButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlexible = (text == '변동가능');
        });
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: const Color(0xFFD3D3D3))
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? const Color(0xFF3C3C3C)
                : const Color(0xFF3C3C3C).withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBox(String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _showPurposeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목적 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _purposes.length,
            itemBuilder: (context, index) {
              final purpose = _purposes[index];
              return ListTile(
                title: Text(purpose),
                onTap: () {
                  setState(() => _selectedPurpose = purpose);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRoomSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공간 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _rooms.length,
            itemBuilder: (context, index) {
              final room = _rooms[index];
              return ListTile(
                title: Text(room),
                onTap: () {
                  setState(() => _selectedRoom = room);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDaySelectorDialog() {
    showDialog(
      context: context,
      builder: (context) {
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
                    selectedColor: const Color(0xFF333333),
                    checkmarkColor: Colors.white,
                    backgroundColor: const Color(0xFFF1F1F1),
                    labelStyle: TextStyle(
                      color: _selectedDays[index] ? Colors.white : Colors.black,
                    ),
                    onSelected: (selected) {
                      setDialogState(() {
                        _selectedDays[index] = selected;
                      });
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
                  child: const Text(
                    '확인',
                    style: TextStyle(color: Color(0xFF333333)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSpaceSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '공간 변경 솔루션',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // Room solution card with placeholder
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD5D5D5)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '솔루션',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '침대 옆 협탁을 치우고 요가매트를 깔아보세요',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0x99000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF3C3C3C),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'IOT 연동',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          if (_iotItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEAEAEA)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text('연동된 기기가 없습니다.'),
            )
          else
            ..._iotItems.asMap().entries.map(
              (entry) => _buildIotCard(entry.key, entry.value),
            ),

          const SizedBox(height: 16),

          // Add IoT Button
          GestureDetector(
            onTap: () {
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFC8C8C8),
                  style: BorderStyle.solid,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '+IOT 연동 추가하기',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0x99000000)),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildIotCard(int index, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 23),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IOT 사물 (${index + 1})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xE6000000),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '사물 종류',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  border: Border.all(color: const Color(0xFFD3D3D3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      item['type'] ?? '조명',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3C3C3C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: Color(0xFF3C3C3C),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item['hasBrightness'] == true) ...[
            const SizedBox(height: 11),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '밝기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  item['brightness'] >= 0.9 ? '최대 밝기' : '중간 밝기',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 27,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD9D9D9), Color(0xFF737373)],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                Positioned(
                  left:
                      (item['brightness'] as double) *
                      (MediaQuery.of(context).size.width - 130),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFC5C5C5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
