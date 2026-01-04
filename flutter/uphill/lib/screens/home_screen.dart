import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/date_strip.dart';
import '../widgets/routine_card.dart';
import 'routine_flow/routine_step1_screen.dart';
import 'routine_detail_screen.dart';
import '../services/routine_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _routines = {};
  final ScrollController _scrollController = ScrollController();
  final RoutineService _routineService = RoutineService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadRoutines();

    // 현재 시간대로 즉시 이동 (슬라이딩 효과 없이)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToCurrentTime();
    });
  }

  Future<void> _loadRoutines() async {
    setState(() => _isLoading = true);
    try {
      // 로그인 확인
      if (!_authService.isLoggedIn) {
        final loaded = await _authService.loadStoredAuth();
        if (!loaded) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final routines = await _routineService.getRoutines();
      
      // 루틴을 날짜별로 그룹화 (현재는 오늘 날짜에만 표시)
      final today = _normalizeDate(DateTime.now());
      final routinesForToday = routines.map((routine) {
        final time = routine['time'] as String;
        // 시간만 있는 경우, 30분 간격으로 가정
        final timeParts = time.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final endMinute = minute + 30;
        final endHour = endMinute >= 60 ? hour + 1 : hour;
        final endMin = endMinute >= 60 ? endMinute - 60 : endMinute;
        
        return {
          'id': routine['id'],
          'title': routine['title'],
          'start': time,
          'end': '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}',
          'category': routine['category'],
          'color': routine['color'],
          'isUpdated': false,
          'isPinned': false,
        };
      }).toList();

      setState(() {
        _routines = {today: routinesForToday};
        _isLoading = false;
      });

      // 스크롤 위치 업데이트
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToCurrentTime();
      });
    } catch (e) {
      debugPrint("❌ 루틴 로드 실패: $e");
      setState(() {
        _routines = {};
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("루틴을 불러오는데 실패했습니다: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        onPressed: () async {
          // 로그인 확인
          if (!_authService.isLoggedIn) {
            final loaded = await _authService.loadStoredAuth();
            if (!loaded) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("로그인이 필요합니다"),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              return;
            }
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RoutineStep1Screen()),
          ).then((_) {
            // 루틴 생성 후 목록 새로고침
            _loadRoutines();
          });
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTimeline() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
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
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Today',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
