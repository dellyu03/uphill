import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../services/routine_service.dart';
import '../services/auth_service.dart';
import '../services/dummy_auth_service.dart';

/// 피드백 화면 위젯
/// 주간 피드백과 일간 AI 피드백을 표시합니다.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => FeedbackScreenState();
}

/// 피드백 화면 상태
/// 외부에서 refreshFeedback() 호출을 위해 public으로 선언
class FeedbackScreenState extends State<FeedbackScreen>
    with WidgetsBindingObserver {
  /// 루틴 서비스 싱글톤
  final RoutineService _routineService = RoutineService();

  /// 인증 서비스 싱글톤
  final AuthService _authService = AuthService();
  final DummyAuthService _dummyAuthService = DummyAuthService();

  /// 로딩 상태
  bool _isLoading = true;

  /// 에러 메시지
  String? _errorMessage;

  /// 현재 표시 중인 날짜
  late DateTime _currentDate;

  // AI 피드백 데이터
  String _aiFeedbackShort = '';
  String _aiFeedbackFull = '';
  List<String> _recommendedRoutines = [];
  // ignore: unused_field
  int _totalRoutines = 0;
  // ignore: unused_field
  int _totalDurationSeconds = 0;

  String? _backgroundImageUrl;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    _loadDailyFeedback();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 다시 포그라운드로 돌아올 때 피드백 새로고침
    if (state == AppLifecycleState.resumed) {
      _loadDailyFeedback();
    }
  }

  /// 외부에서 피드백 새로고침을 요청할 때 사용
  void refreshFeedback() {
    _loadDailyFeedback();
  }

  /// 로그인 여부 확인
  bool get _isLoggedIn =>
      _authService.isLoggedIn || _dummyAuthService.isLoggedIn;

  /// 일간 피드백 로드
  /// [Backend 요청] GET /executions/daily/{date}/feedback
  Future<void> _loadDailyFeedback() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 로그인 확인
      if (!_isLoggedIn) {
        final loaded = await _authService.loadStoredAuth();
        final dummyLoaded = await _dummyAuthService.loadStoredAuth();

        if (!loaded && !dummyLoaded) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMessage = TextConstants.loginRequired;
          });
          return;
        }
      }

      // 선택된 날짜로 피드백 조회
      final dateStr =
          '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}';

      debugPrint('📋 피드백 조회 시작: $dateStr');

      // [Backend 요청] AI 피드백 조회
      final feedback = await _routineService.getDailyFeedback(dateStr);

      debugPrint('✅ 피드백 응답: $feedback');

      if (!mounted) return;

      _updateFeedbackState(feedback);
    } catch (e) {
      debugPrint('❌ 피드백 로드 실패: $e');
      if (!mounted) return;

      // API 실패해도 기본 피드백 표시
      _setDefaultFeedback();
    }
  }

  /// 피드백 상태 업데이트
  void _updateFeedbackState(Map<String, dynamic> feedback) {
    setState(() {
      _aiFeedbackShort = feedback['ai_feedback_short'] ?? '';
      _aiFeedbackFull = feedback['ai_feedback_full'] ?? '';
      _recommendedRoutines = List<String>.from(
        feedback['recommended_routines'] ?? [],
      );

      final summary = feedback['summary'] as Map<String, dynamic>?;
      if (summary != null) {
        _totalRoutines = summary['total_routines'] ?? 0;
        _totalDurationSeconds = summary['total_duration_seconds'] ?? 0;
      }

      _backgroundImageUrl = feedback['background_image_url'];

      debugPrint('📝 파싱된 피드백 - short: $_aiFeedbackShort');
      debugPrint('📝 추천 루틴: $_recommendedRoutines');

      _isLoading = false;
      _errorMessage = null;
    });
  }

  /// 기본 피드백 설정
  void _setDefaultFeedback() {
    setState(() {
      _isLoading = false;
      _aiFeedbackShort = TextConstants.defaultFeedbackShort;
      _aiFeedbackFull = TextConstants.defaultFeedbackFull;
      _recommendedRoutines = TextConstants.defaultRecommendedRoutines;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<UphillColors>()!;

    // 메인 스캐폴드
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutConstants.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 헤더 - "Feedback" 타이틀
              _buildHeader(),
              const SizedBox(height: 16),
              // Daily 배지 + 날짜 선택
              _buildDateSelector(),
              const SizedBox(height: 24),

              // 피드백 카드는 커스텀 3D 스택 애니메이션과 함께 표시
              Expanded(
                child: _buildAnimatedCardStack(colors),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더 위젯
  Widget _buildHeader() {
    return Text(
      'Feedback',
      style: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF292B32),
        letterSpacing: -0.32,
      ),
    );
  }

  /// 방향을 알기 위한 내부 변수
  bool _isGoingBack = true;

  /// 이전 날짜로 이동 (과거로)
  void _goToPreviousDate() {
    setState(() {
      _isGoingBack = true;
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
    _loadDailyFeedback();
  }

  /// 다음 날짜로 이동 (미래로, 오늘까지만)
  void _goToNextDate() {
    final now = DateTime.now();
    final nextDate = _currentDate.add(const Duration(days: 1));
    
    // 미래 날짜로는 이동 불가
    if (nextDate.year > now.year || 
        (nextDate.year == now.year && nextDate.month > now.month) || 
        (nextDate.year == now.year && nextDate.month == now.month && nextDate.day > now.day)) {
      return;
    }

    setState(() {
      _isGoingBack = false;
      _currentDate = nextDate;
    });
    _loadDailyFeedback();
  }

  /// 날짜 선택 UI (Daily 배지 + 날짜 네비게이션)
  Widget _buildDateSelector() {
    final now = DateTime.now();
    final isToday = _currentDate.year == now.year &&
        _currentDate.month == now.month &&
        _currentDate.day == now.day;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Daily 배지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE5EF9F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Daily',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF292B32),
              letterSpacing: -0.12,
            ),
          ),
        ),
        // 날짜 선택 영역
        Row(
          children: [
            GestureDetector(
              onTap: _goToPreviousDate,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF484846),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_currentDate.month.toString().padLeft(2, '0')}월 ${_currentDate.day.toString().padLeft(2, '0')}일',
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF292B32),
                letterSpacing: -0.16,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isToday ? null : _goToNextDate,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: isToday ? const Color(0xFFD9D9D9) : const Color(0xFF484846),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(UphillColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: const BoxDecoration(
            color: Color(0xFFC0CC90), 
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/img_feedback_empty.png',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.mail_outline,
                  size: 100,
                  color: Colors.white,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          '아직 도착한 피드백이 없어요.',
          style: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A4A4A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 100), 
      ],
    );
  }

  /// 3D 스택 애니메이션을 관리하는 위젯
  Widget _buildAnimatedCardStack(UphillColors colors) {
    // 키 값으로 날짜 문자열 사용 (애니메이션 트리거 용도)
    final dateKey = _currentDate.toIso8601String();

    return TweenAnimationBuilder<double>(
      key: ValueKey(dateKey), // 날짜가 변하면 Tween이 0부터 다시 시작됨
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            // 뒷 배경 카드 크기 설정
            final backWidth = maxWidth - 40;
            final middleWidth = maxWidth - 20;

            // 로딩이나 에러, 빈 상태 처리
            Widget mainContent;
            if (_isLoading) {
              mainContent = _buildLoadingCard(colors);
            } else if (_errorMessage != null) {
              mainContent = _buildErrorCard(colors);
            } else if (_aiFeedbackShort.isEmpty) {
              mainContent = _buildEmptyState(colors);
            } else {
              mainContent = _buildMainInsightCardContent(colors);
            }

            // 과거로 이동 (맨 앞 카드가 벗겨지고, 뒤 카드들이 앞으로 다가옴)
            if (_isGoingBack) {
              // value: 0 -> 1 (애니메이션 진행도)
              // 뒷 카드 (회색 배경) 크기/위치 애니메이션
              final backToMiddleWidth = lerpDouble(backWidth - 20, backWidth, value) ?? backWidth;
              final backToMiddleTop = lerpDouble(-10, 0, value) ?? 0.0;
              
              final middleToFrontWidth = lerpDouble(middleWidth - 20, maxWidth, value) ?? maxWidth;
              final middleToFrontTopOffset = lerpDouble(10, 20, value) ?? 20.0;

              // 맨 앞 카드는 어떻게 벗겨질 것인가? 
              // -> 실제로는 '이전 날짜의 카드'가 맨 뒤에서부터 앞으로 밀려오는 듯한 효과
              // 혹은 '현재(미래) 카드'가 위로 슬라이드 됨.
              // 여기서는 데이터가 바뀌어 버렸으므로, 새로 그려지는 메인 카드는 
              // 뒤에서부터(middle->front) 스케일업 되며 나타나도록 함.
              
              // 나가는 애니메이션을 위해서는 기존 카드를 기억하는 등 구조가 복잡해지므로,
              // 간단하게 Tween 값에 따라 스택 구조 자체에 모션을 줍니다.

              return Stack(
                alignment: Alignment.topCenter,
                children: [
                   // 1번째 카드 (가장 뒤에서 생성되어 다가옴 - 투명도 변화)
                   Positioned(
                    top: backToMiddleTop,
                    child: Opacity(
                      opacity: value, // 0에서 1로 
                      child: Container(
                        width: backToMiddleWidth,
                        height: maxHeight - 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  // 2번째 카드 (첫번째 회색 카드에서 두번째 중간 카드 위치로)
                  Positioned(
                    top: lerpDouble(0, 10, value),
                    child: Container(
                      width: lerpDouble(backWidth, middleWidth, value),
                      height: maxHeight - 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB5B5B5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  // 메인 카드 (중간 카드 위치에서 맨 앞 메인 카드 위치로)
                  Positioned(
                    top: middleToFrontTopOffset,
                    child: Opacity(
                      opacity: value < 0.2 ? value * 5 : 1.0, // 약간 늦게 나타나는 효과
                      child: Transform.scale(
                        scale: lerpDouble(0.9, 1.0, value),
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: middleToFrontWidth,
                          height: maxHeight - 20,
                          child: mainContent,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } 
            // 미래로 이동 (위에서 새 카드가 떨어져 덮히고, 나머지는 뒤로 밀림)
            else {
               return Stack(
                alignment: Alignment.topCenter,
                children: [
                  // 기존 2번째 카드 -> 맨 뒤로 감 (또는 사라짐)
                  Positioned(
                    top: lerpDouble(10, 0, value),
                    child: Opacity(
                      opacity: 1.0 - value, // 서서히 사라짐
                      child: Container(
                        width: lerpDouble(middleWidth, backWidth, value),
                        height: maxHeight - 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  // 기존 프론트 카드 위치(모양) -> 중간 회색 띠로 밀려감
                  Positioned(
                    top: lerpDouble(20, 10, value),
                    child: Container(
                      width: lerpDouble(maxWidth, middleWidth, value),
                      height: maxHeight - 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB5B5B5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  // 새 메인 카드는 위에서부터 날아와서 덮음
                  Positioned(
                    top: 20,
                    child: Transform.translate(
                      offset: Offset(0, lerpDouble(-500.0, 0, value) ?? 0.0), // 천장에서 떨어짐
                      child: SizedBox(
                        width: maxWidth,
                        height: maxHeight - 20,
                        child: mainContent,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  /// 실제 피드백 카드 콘텐츠 렌더링
  Widget _buildMainInsightCardContent(UphillColors colors) {
    // 배경 이미지 프로바이더 결정
    ImageProvider? imageProvider;
    if (_backgroundImageUrl != null) {
      if (_backgroundImageUrl!.startsWith('http')) {
        imageProvider = NetworkImage(_backgroundImageUrl!);
      } else {
        imageProvider = AssetImage(_backgroundImageUrl!);
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(30),
        image: imageProvider != null
            ? DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Colors.black38, // 이미지 어둡게 처리
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          // 상단 더블 화살표 아이콘 (상단 중앙)
          Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: _goToPreviousDate, // 위 화살표 누르면 날짜 넘어가며 애니메이션 발동
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16, left: 32, right: 32), 
                child: Icon(
                  Icons.keyboard_double_arrow_up_rounded,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 32,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // New/None 배지 및 텍스트는 임시 하드코딩
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A7154).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'New!',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // 날짜
                    Text(
                      '${_currentDate.month}/${_currentDate.day.toString().padLeft(2, '0')}',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // 메인 피드백 텍스트
                Text(
                  _aiFeedbackShort.isNotEmpty
                      ? _aiFeedbackShort
                      : '오늘의 루틴을 완료해보세요',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // 서브 피드백 텍스트 (추천 문구)
                Text(
                  _aiFeedbackFull.isNotEmpty
                      ? _aiFeedbackFull
                      : '루틴을 수행하면 더 정확한 피드백을 받을 수 있어요.',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),

                // 피드백 더보기 버튼
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        '더보기',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 카드 위젯
  Widget _buildLoadingCard(UphillColors colors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  /// 에러 카드 위젯
  Widget _buildErrorCard(UphillColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? '오류가 발생했습니다.',
              style: GoogleFonts.notoSansKr(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadDailyFeedback,
              child: Text(
                '다시 시도',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

