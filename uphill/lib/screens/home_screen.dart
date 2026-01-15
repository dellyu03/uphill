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
  List<Map<String, dynamic>> _allRoutines = [];  // 모든 루틴 저장
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

      // 모든 루틴을 저장 (요일 정보 포함)
      final processedRoutines = routines.map((routine) {
        final time = routine['time'] as String;
        // 시간만 있는 경우, 30분 간격으로 가정
        final timeParts = time.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final endMinute = minute + 30;
        final endHour = endMinute >= 60 ? hour + 1 : hour;
        final endMin = endMinute >= 60 ? endMinute - 60 : endMinute;

        // days가 null이면 빈 리스트로 처리
        final days = routine['days'] != null
            ? List<int>.from(routine['days'])
            : <int>[];

        return {
          'id': routine['id'],
          'title': routine['title'],
          'start': time,
          'end': '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}',
          'category': routine['category'],
          'color': routine['color'],
          'days': days,  // 반복 요일 (0=월, 1=화, ..., 6=일)
          'isUpdated': false,
          'isPinned': false,
        };
      }).toList();

      setState(() {
        _allRoutines = processedRoutines;
        _isLoading = false;
      });

      // 스크롤 위치 업데이트
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToCurrentTime();
      });
    } catch (e) {
      debugPrint("❌ 루틴 로드 실패: $e");
      setState(() {
        _allRoutines = [];
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

  // 선택된 날짜에 해당하는 루틴만 필터링
  List<Map<String, dynamic>> _getRoutinesForDate(DateTime date) {
    // Dart weekday: 1=월, 2=화, ..., 7=일
    // 우리 시스템: 0=월, 1=화, ..., 6=일
    final dayIndex = date.weekday - 1;

    return _allRoutines.where((routine) {
      final days = routine['days'] as List<int>;
      // days가 비어있으면 표시하지 않음 (요일 미설정 루틴)
      if (days.isEmpty) return false;
      return days.contains(dayIndex);
    }).toList();
  }

  void scrollToCurrentTime() {
    if (_scrollController.hasClients) {
      final now = DateTime.now();
      final routines = _getRoutinesForDate(now);

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
    final selectedDate = _selectedDay ?? now;
    final routines = _getRoutinesForDate(selectedDate);
    final colors = Theme.of(context).extension<UphillColors>()!;

    // Timeline Config
    const double hourHeight = 110.0; // Slightly taller for spacing
    const int startHour = 0;
    const int endHour = 24;
    const double leftMargin = 70.0;

    // 겹치는 루틴 처리를 위한 레이아웃 계산
    final layoutInfo = _calculateRoutineLayout(routines);

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
              ...routines.asMap().entries.map((entry) {
                final index = entry.key;
                final routine = entry.value;
                final layout = layoutInfo[index];

                final start = _parseTime(routine['start'] as String);
                final end = _parseTime(routine['end'] as String);

                final startMinutes =
                    start.hour * 60 + start.minute - (startHour * 60);
                final durationMinutes =
                    (end.hour * 60 + end.minute) -
                    (start.hour * 60 + start.minute);

                // 기본 너비 계산
                final defaultWidth = MediaQuery.of(context).size.width - leftMargin - 40.0;

                return Positioned(
                  top: (startMinutes / 60) * hourHeight,
                  left: leftMargin + (layout['offset'] ?? 0.0),
                  width: layout['width'] ?? defaultWidth,
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
                            routineId: routine['id'].toString(),
                            title: routine['title'],
                            timeRange:
                                '${routine['start']} - ${routine['end']}',
                          ),
                        ),
                      ).then((_) {
                        // 상세 화면에서 돌아온 후 목록 새로고침
                        _loadRoutines();
                      });
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // 겹치는 루틴들의 레이아웃 계산
  List<Map<String, double>> _calculateRoutineLayout(List<Map<String, dynamic>> routines) {
    final List<Map<String, double>> layout = [];

    for (int i = 0; i < routines.length; i++) {
      final currentRoutine = routines[i];
      final currentStart = _parseTime(currentRoutine['start'] as String);
      final currentEnd = _parseTime(currentRoutine['end'] as String);
      final currentStartMins = currentStart.hour * 60 + currentStart.minute;
      final currentEndMins = currentEnd.hour * 60 + currentEnd.minute;

      // 현재 루틴과 겹치는 다른 루틴들 찾기
      final overlapping = <int>[];
      for (int j = 0; j < routines.length; j++) {
        if (i == j) continue;

        final otherRoutine = routines[j];
        final otherStart = _parseTime(otherRoutine['start'] as String);
        final otherEnd = _parseTime(otherRoutine['end'] as String);
        final otherStartMins = otherStart.hour * 60 + otherStart.minute;
        final otherEndMins = otherEnd.hour * 60 + otherEnd.minute;

        // 시간이 겹치는지 확인
        if (!(currentEndMins <= otherStartMins || currentStartMins >= otherEndMins)) {
          overlapping.add(j);
        }
      }

      // 사용 가능한 전체 너비 계산 (좌측 margin 70, 좌우 padding 40 제외)
      final availableWidth = MediaQuery.of(context).size.width - 70.0 - 40.0;

      // 겹치는 루틴이 없으면 전체 너비 사용
      if (overlapping.isEmpty) {
        layout.add({'offset': 0.0, 'width': availableWidth});
      } else {
        // 겹치는 루틴이 있으면 너비를 나눠서 배치
        final totalOverlapping = overlapping.length + 1;
        int position = 0;

        // 현재 루틴의 위치 찾기 (인덱스 순서대로)
        for (int idx in overlapping) {
          if (idx < i) position++;
        }

        final cardWidth = availableWidth / totalOverlapping;
        final offset = cardWidth * position;

        layout.add({'offset': offset, 'width': cardWidth - 4}); // 4px 간격
      }
    }

    return layout;
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
