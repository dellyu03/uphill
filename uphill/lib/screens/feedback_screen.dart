/// 피드백 화면 위젯
/// AI 피드백 및 일일 인사이트를 표시합니다.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../services/routine_service.dart';
import '../services/auth_service.dart';

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

  /// 로딩 상태
  bool _isLoading = true;

  /// 에러 메시지
  String? _errorMessage;

  // AI 피드백 데이터
  String _aiFeedbackShort = '';
  String _aiFeedbackFull = '';
  List<String> _recommendedRoutines = [];
  int _totalRoutines = 0;
  int _totalDurationSeconds = 0;

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
      if (!_authService.isLoggedIn) {
        final loaded = await _authService.loadStoredAuth();
        if (!loaded) {
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
      _recommendedRoutines =
          List<String>.from(feedback['recommended_routines'] ?? []);

      final summary = feedback['summary'] as Map<String, dynamic>?;
      if (summary != null) {
        _totalRoutines = summary['total_routines'] ?? 0;
        _totalDurationSeconds = summary['total_duration_seconds'] ?? 0;
      }

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

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
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
              // 주간 피드백 카드
              _buildWeeklyCard(colors),
              const SizedBox(height: 16),
              // 일간 AI 피드백 카드
              Expanded(child: _buildInsightCard(colors)),
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
        fontWeight: FontWeight.bold,
        color: const Color(0xFF4A4A4A),
      ),
    );
  }

  /// 주간 피드백 카드 위젯
  Widget _buildWeeklyCard(UphillColors colors) {
    final now = DateTime.now();
    final dateDisplay =
        '${now.month.toString().padLeft(2, '0')} ${now.day.toString().padLeft(2, '0')}';

    // 주간 피드백 카드 컨테이너
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.feedbackCardWeekBg,
        borderRadius: BorderRadius.circular(LayoutConstants.largeBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 텍스트
          Text(
            dateDisplay,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.feedbackCardWeekText,
            ),
          ),
          const SizedBox(height: 4),
          // "Weekly feedback" 타이틀
          Text(
            'Weekly feedback',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.feedbackCardWeekText,
            ),
          ),
          const SizedBox(height: 16),
          // Check 버튼
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.feedbackBtnCheckBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    LayoutConstants.cardBorderRadius,
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                'Check',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.feedbackBtnCheckText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 일간 인사이트 카드 위젯
  Widget _buildInsightCard(UphillColors colors) {
    // 로딩 상태
    if (_isLoading) {
      return _buildLoadingCard(colors);
    }

    // 에러 상태
    if (_errorMessage != null) {
      return _buildErrorCard(colors);
    }

    // 정상 상태
    return _buildContentCard(colors);
  }

  /// 로딩 카드 위젯
  Widget _buildLoadingCard(UphillColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.feedbackCardDailyBg,
        borderRadius: BorderRadius.circular(LayoutConstants.largeBorderRadius),
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
        color: colors.feedbackCardDailyBg,
        borderRadius: BorderRadius.circular(LayoutConstants.largeBorderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 에러 아이콘
            Icon(
              Icons.error_outline,
              color: colors.feedbackCardDailyText,
              size: 48,
            ),
            const SizedBox(height: 16),
            // 에러 메시지
            Text(
              _errorMessage!,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: colors.feedbackCardDailyText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // 다시 시도 버튼
            TextButton(
              onPressed: _loadDailyFeedback,
              child: Text(
                '다시 시도',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.feedbackCardDailyText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 콘텐츠 카드 위젯
  Widget _buildContentCard(UphillColors colors) {
    final now = DateTime.now();

    // 추천 루틴 한마디 생성
    final recommendationText = _buildRecommendationText();

    // 일간 피드백 카드 컨테이너
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.feedbackCardDailyBg,
        borderRadius: BorderRadius.circular(LayoutConstants.largeBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New 배지
          _buildNewBadge(colors),
          const Spacer(),
          // 날짜
          Text(
            _formatDate(now),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: colors.feedbackCardDailyText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          // AI 한 줄 피드백
          Text(
            _aiFeedbackShort.isNotEmpty
                ? _aiFeedbackShort
                : '오늘의 피드백을 준비 중이에요',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colors.feedbackCardDailyText,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // 추천 루틴 한마디
          Text(
            recommendationText.isNotEmpty
                ? recommendationText
                : '루틴을 완료하면 맞춤 추천을 받을 수 있어요!',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: colors.feedbackCardDailyText.withValues(alpha: 0.7),
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          // 피드백 더보기 버튼
          _buildMoreButton(colors),
        ],
      ),
    );
  }

  /// New 배지 위젯
  Widget _buildNewBadge(UphillColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.feedbackBadgeNewBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'New!',
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.feedbackBadgeNewText,
        ),
      ),
    );
  }

  /// 추천 텍스트 생성
  String _buildRecommendationText() {
    if (_recommendedRoutines.isEmpty) return '';

    var text = "'${_recommendedRoutines.first}' 루틴을 추가해 보는 건 어떨까요?";
    if (_recommendedRoutines.length > 1) {
      text +=
          " ${_recommendedRoutines.sublist(1).map((r) => "'$r'").join(', ')}도 추천해요!";
    }
    return text;
  }

  /// 더보기 버튼 위젯
  Widget _buildMoreButton(UphillColors colors) {
    return GestureDetector(
      onTap: () {
        // TODO: 더보기 기능 구현
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('더보기 기능은 준비 중이에요'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Row(
        children: [
          // "피드백 더보기" 텍스트
          Text(
            '피드백 더보기',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.feedbackCardDailyText,
            ),
          ),
          const SizedBox(width: 4),
          // 화살표 아이콘
          Icon(
            Icons.arrow_forward,
            size: 16,
            color: colors.feedbackCardDailyText,
          ),
        ],
      ),
    );
  }
}
