/// 홈 화면 위젯
/// 일정 타임라인과 루틴 카드를 표시합니다.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../widgets/date_strip.dart';
import '../widgets/routine_card.dart';
import '../widgets/progress_banner.dart';
import '../constants/app_constants.dart';
import 'routine_flow/routine_step1_screen.dart';
import 'routine_detail_screen.dart';
import 'routine_in_progress_screen.dart';
import '../services/routine_service.dart';
import '../services/auth_service.dart';
import '../services/dummy_auth_service.dart';
import '../models/routine.dart';

/// 홈 화면 위젯
/// 시간대별 루틴 타임라인을 표시합니다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

/// 홈 화면 상태
/// 외부에서 scrollToCurrentTime() 호출을 위해 public으로 선언
class HomeScreenState extends State<HomeScreen> {
  /// 포커스된 날짜
  DateTime _focusedDay = DateTime.now();

  /// 선택된 날짜
  DateTime? _selectedDay;

  /// 모든 루틴 목록
  List<Routine> _allRoutines = [];

  /// 타임라인 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();

  /// 루틴 서비스 싱글톤
  final RoutineService _routineService = RoutineService();

  /// 인증 서비스 싱글톤
  final AuthService _authService = AuthService();
  final DummyAuthService _dummyAuthService = DummyAuthService();

  /// 로딩 상태
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadRoutines();

    // 현재 시간대로 즉시 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToCurrentTime();
    });
  }

  /// 로그인 여부 확인
  bool get _isLoggedIn =>
      _authService.isLoggedIn || _dummyAuthService.isLoggedIn;

  /// 루틴 목록 로드
  /// [Backend 요청] GET /routines - 사용자 루틴 목록 조회
  Future<void> _loadRoutines() async {
    setState(() => _isLoading = true);

    try {
      // 로그인 확인
      if (!_isLoggedIn) {
        final loaded = await _authService.loadStoredAuth();
        final dummyLoaded = await _dummyAuthService.loadStoredAuth();

        if (!loaded && !dummyLoaded) {
          if (mounted) {
            setState(() => _isLoading = false);
          }
          return;
        }
      }

      // [Backend 요청] 루틴 목록 조회
      final routines = await _routineService.getRoutines();

      // 루틴 데이터 가공
      final processedRoutines = _processRoutines(routines);

      if (mounted) {
        setState(() {
          _allRoutines = processedRoutines;
          _isLoading = false;
        });

        // 스크롤 위치 업데이트
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToCurrentTime();
        });
      }
    } catch (e) {
      debugPrint('❌ 루틴 로드 실패: $e');

      if (mounted) {
        setState(() {
          _allRoutines = [];
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('루틴을 불러오는데 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 루틴 데이터 가공 (시간 재처리 등 필요한 경우)
  /// 하지만 이제 Routing 모델 내부 혹은 getter에서 파싱을 지원하므로,
  /// 단순하게 시작/종료 시간이 비어있을 때 채워넣고 Routine을 반환하도록 합니다.
  List<Routine> _processRoutines(List<Routine> routines) {
    return routines.map((routine) {
      String endTime = routine.endTime ?? '';

      if (endTime.isEmpty && routine.time != null && routine.time!.isNotEmpty) {
        // 기본 30분 간격으로 종료 시간 계산
        final timeParts = routine.time!.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final endMinute = minute + RoutineConstants.defaultDurationMinutes;
        final endHour = endMinute >= 60 ? hour + 1 : hour;
        final endMin = endMinute >= 60 ? endMinute - 60 : endMinute;
        endTime =
            '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
      }

      return routine.copyWith(endTime: endTime.isNotEmpty ? endTime : null);
    }).toList();
  }

  /// 선택된 날짜에 해당하는 루틴 필터링
  List<Routine> _getRoutinesForDate(DateTime date) {
    // Dart weekday: 1=월, 2=화, ..., 7=일
    // 시스템: 0=월, 1=화, ..., 6=일
    final dayIndex = date.weekday - 1;

    return _allRoutines.where((routine) {
      if (routine.days.isEmpty) return false;
      return routine.days.contains(dayIndex);
    }).toList();
  }

  /// 현재 진행 중인 루틴 찾기
  /// 현재 시간이 루틴의 시작~종료 시간 사이이면 진행 중으로 판단
  Routine? _getActiveRoutine() {
    final now = DateTime.now();
    final todayRoutines = _getRoutinesForDate(now);
    final nowTotalMins = now.hour * 60 + now.minute;

    for (var routine in todayRoutines) {
      final start = routine.parsedStartTime;
      final end = routine.parsedEndTime;

      if (start == null || end == null) continue;

      final startMins = start.hour * 60 + start.minute;
      final endMins = end.hour * 60 + end.minute;

      if (nowTotalMins >= startMins && nowTotalMins < endMins) {
        return routine;
      }
    }
    return null;
  }

  /// 현재 시간대로 스크롤
  /// 외부에서 호출 가능 (MainScaffold에서 홈탭 재탭 시)
  void scrollToCurrentTime() {
    if (!_scrollController.hasClients) return;

    final now = DateTime.now();
    final routines = _getRoutinesForDate(now);

    double scrollOffset =
        (now.hour - LayoutConstants.startHour) * LayoutConstants.hourHeight;

    // 현재 진행 중인 루틴 찾기
    for (var routine in routines) {
      final start = routine.parsedStartTime;
      final end = routine.parsedEndTime;
      if (start == null || end == null) continue;

      final nowTotalMins = now.hour * 60 + now.minute;
      final startTotalMins = start.hour * 60 + start.minute;
      final endTotalMins = end.hour * 60 + end.minute;

      // 현재 진행 중인 루틴이면 해당 시작 지점으로 이동
      if (nowTotalMins >= startTotalMins && nowTotalMins < endTotalMins) {
        scrollOffset = (startTotalMins / 60) * LayoutConstants.hourHeight;
        break;
      }
    }

    _scrollController.jumpTo(scrollOffset);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<UphillColors>()!;

    // 메인 스캐폴드
    return Scaffold(
      backgroundColor: colors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 앱바 - "Today" 타이틀
            _buildCustomAppBar(),
            // 날짜 선택 스트립
            _buildDateStrip(),
            // 진행 중인 루틴 배너
            _buildProgressBanner(),
            const SizedBox(height: 20),
            // 타임라인 영역
            Expanded(child: RepaintBoundary(child: _buildTimeline())),
          ],
        ),
      ),
      // 루틴 추가 FAB
      floatingActionButton: _buildAddRoutineFab(),
    );
  }

  /// 상단 앱바 위젯
  Widget _buildCustomAppBar() {
    final monthStr = DateFormat(
      'MMMM',
      'en_US',
    ).format(_selectedDay ?? DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                monthStr,
                style: GoogleFonts.montserrat(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF555151),
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFBDBDBD),
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 날짜 선택 스트립 위젯
  Widget _buildDateStrip() {
    return DateStrip(
      selectedDate: _selectedDay ?? DateTime.now(),
      onDateSelected: (date) {
        setState(() {
          _selectedDay = date;
          _focusedDay = date;
        });
      },
    );
  }

  /// 진행 중인 루틴 배너 위젯
  Widget _buildProgressBanner() {
    if (_isLoading) return const SizedBox.shrink();

    final activeRoutine = _getActiveRoutine();
    if (activeRoutine == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ProgressBanner(
        routineTitle: activeRoutine.title,
        onPlayTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoutineInProgressScreen(
                routineId: activeRoutine.id,
                title: activeRoutine.title,
              ),
            ),
          ).then((_) => _loadRoutines());
        },
      ),
    );
  }

  /// 루틴 추가 FAB 위젯
  Widget _buildAddRoutineFab() {
    return FloatingActionButton(
      onPressed: _onAddRoutinePressed,
      backgroundColor: const Color(0xFF484848), // Figma #484848
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  /// 루틴 추가 버튼 핸들러
  Future<void> _onAddRoutinePressed() async {
    // 로그인 확인
    if (!_isLoggedIn) {
      final loaded = await _authService.loadStoredAuth();
      final dummyLoaded = await _dummyAuthService.loadStoredAuth();

      if (!loaded && !dummyLoaded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(TextConstants.loginRequired),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    if (!mounted) return;

    // 루틴 생성 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RoutineStep1Screen()),
    ).then((_) {
      // 루틴 생성 후 목록 새로고침
      _loadRoutines();
    });
  }

  /// 타임라인 위젯
  Widget _buildTimeline() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = DateTime.now();
    final selectedDate = _selectedDay ?? now;
    final routines = _getRoutinesForDate(selectedDate);
    final colors = Theme.of(context).extension<UphillColors>()!;

    // 겹치는 루틴 레이아웃 계산
    final layoutInfo = _calculateRoutineLayout(routines);

    // 타임라인 스크롤 영역
    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        height:
            (LayoutConstants.endHour - LayoutConstants.startHour) *
                LayoutConstants.hourHeight +
            50,
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutConstants.horizontalPadding,
        ),
        child: Stack(
          children: [
            // 시간 라벨
            ..._buildHourLabels(now, colors),
            // 루틴 카드 또는 빈 상태
            if (routines.isEmpty)
              _buildEmptyState()
            else
              ..._buildRoutineCards(routines, layoutInfo),

            // 현재 시간 지시선
            if (selectedDate.year == now.year &&
                selectedDate.month == now.month &&
                selectedDate.day == now.day)
              _buildCurrentTimeIndicator(now),
          ],
        ),
      ),
    );
  }

  /// 시간 라벨 위젯 리스트
  List<Widget> _buildHourLabels(DateTime now, UphillColors colors) {
    return [
      for (int i = LayoutConstants.startHour; i < LayoutConstants.endHour; i++)
        Positioned(
          top: (i - LayoutConstants.startHour) * LayoutConstants.hourHeight,
          left: 0,
          child: SizedBox(
            width: 50,
            // 시간 라벨 텍스트
            child: Text(
              '${i.toString().padLeft(2, '0')}:00',
              style: GoogleFonts.montserrat(
                color: i == now.hour
                    ? const Color(0xFF98A340)
                    : const Color.fromRGBO(0, 0, 0, 0.2), // Figma 20% opacity
                fontSize: 12,
                fontWeight: i == now.hour ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
    ];
  }

  /// 현재 시간 지시선 (빨간 선과 점)
  Widget _buildCurrentTimeIndicator(DateTime now) {
    if (now.hour < LayoutConstants.startHour ||
        now.hour > LayoutConstants.endHour) {
      return const SizedBox.shrink();
    }

    // 시간 라벨의 텍스트가 위아래로 정렬되는 기준을 고려한 오프셋 조정 (대략 +8px)
    final topOffset =
        ((now.hour - LayoutConstants.startHour) * 60 + now.minute) /
            60 *
            LayoutConstants.hourHeight +
        8;

    return Positioned(
      top: topOffset,
      left: 45, // 시간 라벨 이후부터 시작
      right: 0, // 끝까지
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 150, // 진행선 길이 (임의의 길이 혹은 고정 길이)
            height: 3,
            color: const Color(0xFFFF0000), // 리얼 레드
          ),
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Color(0xFFFF0000),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_list_bulleted_rounded,
              size: 48,
              color: Color(0xFFC6C5C3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '등록된 루틴이 없습니다',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 루틴을 추가해보세요',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: const Color(0xFFAEAEB2),
            ),
          ),
        ],
      ),
    );
  }

  /// 루틴 카드 위젯 리스트
  List<Widget> _buildRoutineCards(
    List<Routine> routines,
    List<Map<String, double>> layoutInfo,
  ) {
    final defaultWidth =
        MediaQuery.of(context).size.width -
        LayoutConstants.timelineLeftMargin -
        LayoutConstants.horizontalPadding * 2;

    return routines.asMap().entries.map((entry) {
      final index = entry.key;
      final routine = entry.value;
      final layout = layoutInfo[index];

      final start = routine.parsedStartTime;
      final end = routine.parsedEndTime;
      if (start == null || end == null) return const SizedBox.shrink();

      final startMinutes =
          start.hour * 60 + start.minute - (LayoutConstants.startHour * 60);
      final durationMinutes =
          (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);

      // 계산된 높이 (시간 기반)
      final calculatedHeight =
          (durationMinutes / 60) * LayoutConstants.hourHeight - 8;
      // 최소 높이 65px: 타이틀(15px) + 간격(4px) + 시간(11px) + 패딩(24px) + 여유(11px)
      final cardHeight = calculatedHeight < 65 ? 65.0 : calculatedHeight;

      // 루틴 카드 위치 및 크기
      return Positioned(
        top: (startMinutes / 60) * LayoutConstants.hourHeight,
        left: LayoutConstants.timelineLeftMargin + (layout['offset'] ?? 0.0),
        width: layout['width'] ?? defaultWidth,
        height: cardHeight,
        // 루틴 카드 위젯
        child: RoutineCard(
          title: routine.title,
          timeRange: '${routine.time} - ${routine.endTime}',
          isUpdated: routine.isUpdated,
          isPinned: routine.isPinned,
          onTap: () => _onRoutineCardTapped(routine),
        ),
      );
    }).toList();
  }

  /// 루틴 카드 탭 핸들러
  void _onRoutineCardTapped(Routine routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineDetailScreen(
          routineId: routine.id,
          title: routine.title,
          timeRange: '${routine.time} - ${routine.endTime}',
        ),
      ),
    ).then((_) {
      // 상세 화면에서 돌아온 후 목록 새로고침
      _loadRoutines();
    });
  }

  /// 겹치는 루틴들의 레이아웃 계산
  List<Map<String, double>> _calculateRoutineLayout(List<Routine> routines) {
    final List<Map<String, double>> layout = [];

    for (int i = 0; i < routines.length; i++) {
      final currentRoutine = routines[i];
      final currentStart = currentRoutine.parsedStartTime;
      final currentEnd = currentRoutine.parsedEndTime;
      if (currentStart == null || currentEnd == null) continue;

      final currentStartMins = currentStart.hour * 60 + currentStart.minute;
      final currentEndMins = currentEnd.hour * 60 + currentEnd.minute;

      // 현재 루틴과 겹치는 다른 루틴들 찾기
      final overlapping = <int>[];
      for (int j = 0; j < routines.length; j++) {
        if (i == j) continue;

        final otherRoutine = routines[j];
        final otherStart = otherRoutine.parsedStartTime;
        final otherEnd = otherRoutine.parsedEndTime;
        if (otherStart == null || otherEnd == null) continue;

        final otherStartMins = otherStart.hour * 60 + otherStart.minute;
        final otherEndMins = otherEnd.hour * 60 + otherEnd.minute;

        // 시간이 겹치는지 확인
        if (!(currentEndMins <= otherStartMins ||
            currentStartMins >= otherEndMins)) {
          overlapping.add(j);
        }
      }

      // 사용 가능한 전체 너비 계산
      final availableWidth =
          MediaQuery.of(context).size.width -
          LayoutConstants.timelineLeftMargin -
          LayoutConstants.horizontalPadding * 2;

      // 겹치는 루틴이 없으면 전체 너비 사용
      if (overlapping.isEmpty) {
        layout.add({'offset': 0.0, 'width': availableWidth});
      } else {
        // 겹치는 루틴이 있으면 너비를 나눠서 배치
        final totalOverlapping = overlapping.length + 1;
        int position = 0;

        for (int idx in overlapping) {
          if (idx < i) position++;
        }

        final cardWidth = availableWidth / totalOverlapping;
        final offset = cardWidth * position;

        layout.add({'offset': offset, 'width': cardWidth - 4});
      }
    }

    return layout;
  }
}
