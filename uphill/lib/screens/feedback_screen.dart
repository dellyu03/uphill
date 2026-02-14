/// 피드백 화면 위젯
/// AI 피드백 및 일일 인사이트를 표시합니다.
library;

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

      // 오늘 날짜로 피드백 조회
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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
      backgroundColor: colors.bgMain,
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
              const SizedBox(height: 24),

              // 피드백 데이터가 없으면 빈 상태 표시
              if (_aiFeedbackShort.isEmpty && !_isLoading)
                Expanded(child: _buildEmptyState(colors))
              else ...[
                // 주간 피드백 카드
                _buildWeeklyCard(colors),
                const SizedBox(height: 16),
                // 일간 AI 피드백 카드
                Expanded(child: _buildInsightCard(colors)),
              ],
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
      TextConstants.feedbackTitle,
      style: GoogleFonts.montserrat(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF555151),
      ),
    );
  }

  /// 빈 상태 위젯 (Figma 646:1225)
  Widget _buildEmptyState(UphillColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 빈 상태 이미지 (Mailbox)
        // 실제 이미지가 없으므로 아이콘으로 대체, 추후 이미지 asset으로 교체 필요
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFC0CC90), // Figma 유사 색상
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
        // 안내 텍스트
        Text(
          '아직 도착한 피드백이 없어요.',
          style: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A4A4A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 100), // 시각적 중심 보정
      ],
    );
  }

  /// 주간 피드백 카드 위젯 (Figma 487:2499 Top Card)
  Widget _buildWeeklyCard(UphillColors colors) {
    // Figma 상 날짜 예시: 12 04
    final now = DateTime.now();
    final dateDisplay =
        '${now.month.toString().padLeft(2, '0')} ${now.day.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9), // Figma Design Color
        borderRadius: BorderRadius.circular(30), // Figma Radius
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 텍스트
          Text(
            dateDisplay,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF636363),
            ),
          ),
          const SizedBox(height: 4),
          // "Weekly feedback" 타이틀
          Text(
            'Weekly feedback',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF636363),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          // Check 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF434343), // Figma Design Color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                'Check',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 일간 인사이트 카드 위젯 (Figma 487:2499 Bottom Card)
  Widget _buildInsightCard(UphillColors colors) {
    // 로딩 상태
    if (_isLoading) {
      return _buildLoadingCard(colors);
    }

    // 에러 상태
    if (_errorMessage != null) {
      return _buildErrorCard(colors);
    }

    final now = DateTime.now();

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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // New 배지
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A7154).withOpacity(0.9),
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
                      '${now.month}/${now.day.toString().padLeft(2, '0')}',
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
                    color: Colors.white.withOpacity(0.8),
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
                        '피드백 더보기',
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
      padding: const EdgeInsets.all(24),
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
