import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/date_strip.dart';
import '../widgets/routine_card.dart';
import 'routine_flow/routine_step1_screen.dart';
import 'routine_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Map<DateTime, List<Map<String, dynamic>>> _routines;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeMockData();

    // 현재 시간대로 즉시 이동 (슬라이딩 효과 없이)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToCurrentTime();
    });
  }

  void scrollToCurrentTime() {
    if (_scrollController.hasClients) {
      final now = DateTime.now();
      final today = _normalizeDate(now);
      final routines = _routines[today] ?? [];

      const double hourHeight = 110.0;
      const int startHour = 0;
      double scrollOffset = (now.hour - startHour) * hourHeight;

      // 현재 진행 중인 루틴 찾기
      for (var routine in routines) {
        final start = _parseTime(routine['start'] as String);
        final end = _parseTime(routine['end'] as String);

        // 현재 시간(분) 계산
        final nowTotalMins = now.hour * 60 + now.minute;
        final startTotalMins = start.hour * 60 + start.minute;
        final endTotalMins = end.hour * 60 + end.minute;

        // 현재 진행 중인 루틴인 경우 해당 루틴의 시작 지점으로 이동
        if (nowTotalMins >= startTotalMins && nowTotalMins < endTotalMins) {
          scrollOffset = (startTotalMins / 60) * hourHeight;
          break;
        }
      }

      _scrollController.jumpTo(scrollOffset);
    }
  }

  void _initializeMockData() {
    final today = _normalizeDate(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));

    // 루틴 상태 데이터: isUpdated, isPinned
    _routines = {
      today: [
        {
          'title': '아침 스트레칭 루틴',
          'start': '08:00',
          'end': '09:30',
          'isUpdated': true,
          'isPinned': false,
        },
        {
          'title': '아침 스트레칭 루틴', // Standard
          'start': '09:30',
          'end': '10:30',
          'isUpdated': false,
          'isPinned': false,
        },
        {
          'title': '아침 스트레칭 루틴', // Updated again for demo
          'start': '11:00',
          'end': '12:00',
          'isUpdated': true,
          'isPinned': false,
        },
        {
          'title': '아침 스트레칭 루틴', // Pinned
          'start': '12:00',
          'end': '13:30',
          'isUpdated': false,
          'isPinned': true,
        },
        {
          'title': '아침 스트레칭 루틴', // Standard
          'start': '13:30',
          'end': '15:00',
          'isUpdated': false,
          'isPinned': false,
        },
      ],
      tomorrow: [
        {
          'title': 'Morning Yoga',
          'start': '08:00',
          'end': '09:00',
          'isUpdated': true,
          'isPinned': false,
        },
      ],
    };
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<UphillColors>()!;

    return Scaffold(
      backgroundColor: colors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),

            // Date Section
            DateStrip(
              selectedDate: _selectedDay ?? DateTime.now(),
              onDateSelected: (date) {
                setState(() {
                  _selectedDay = date;
                  _focusedDay = date;
                });
              },
            ),

            const SizedBox(height: 20),
            Expanded(child: RepaintBoundary(child: _buildTimeline())),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RoutineStep1Screen()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTimeline() {
    final now = DateTime.now();
    final selectedDate = _normalizeDate(_selectedDay ?? now);
    final routines = _routines[selectedDate] ?? [];
    final colors = Theme.of(context).extension<UphillColors>()!;

    // Timeline Config
    const double hourHeight = 110.0; // Slightly taller for spacing
    const int startHour = 0;
    const int endHour = 24;
    const double leftMargin = 70.0;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        height: (endHour - startHour) * hourHeight + 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            // 1. Hour Labels
            for (int i = startHour; i < endHour; i++)
              Positioned(
                top: (i - startHour) * hourHeight,
                left: 0,
                child: SizedBox(
                  width: 50,
                  child: Text(
                    '${i.toString().padLeft(2, '0')}:00',
                    style: TextStyle(
                      // Time Section: Highlight current hour
                      color: i == now.hour
                          ? colors.timeHighlight
                          : Colors.black38,
                      fontSize: 13,
                      fontWeight: i == now.hour
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),

            // 2. Routine Cards
            if (routines.isEmpty)
              const Positioned(
                top: 50,
                left: leftMargin,
                child: Text(
                  'No routines assigned.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ...routines.map((routine) {
                final start = _parseTime(routine['start'] as String);
                final end = _parseTime(routine['end'] as String);

                final startMinutes =
                    start.hour * 60 + start.minute - (startHour * 60);
                final durationMinutes =
                    (end.hour * 60 + end.minute) -
                    (start.hour * 60 + start.minute);

                return Positioned(
                  top: (startMinutes / 60) * hourHeight,
                  left: leftMargin,
                  right: 0,
                  height:
                      (durationMinutes / 60) * hourHeight - 8, // margin bottom
                  child: RoutineCard(
                    title: routine['title'],
                    timeRange: '${routine['start']} - ${routine['end']}',
                    isUpdated: routine['isUpdated'] ?? false,
                    isPinned: routine['isPinned'] ?? false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoutineDetailScreen(
                            title: routine['title'],
                            timeRange:
                                '${routine['start']} - ${routine['end']}',
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Today',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600, // Matching the image's lighter bold
              color: Color(0xFF4A4A4A), // Dark Grey
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.signal_cellular_alt,
              color: Colors.black,
            ), // Dummy status icon
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
