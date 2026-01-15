import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/routine_service.dart';
import '../services/auth_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> with WidgetsBindingObserver {
  final RoutineService _routineService = RoutineService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String? _errorMessage;

  // AI 피드백 데이터
  String _aiFeedbackShort = "";
  String _aiFeedbackFull = "";
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
            _errorMessage = "로그인이 필요합니다";
          });
          return;
        }
      }

      // 오늘 날짜로 피드백 조회
      final today = DateTime.now();
      final dateStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      debugPrint("📋 피드백 조회 시작: $dateStr");

      final feedback = await _routineService.getDailyFeedback(dateStr);

      debugPrint("✅ 피드백 응답: $feedback");

      if (!mounted) return;
      setState(() {
        _aiFeedbackShort = feedback['ai_feedback_short'] ?? "";
        _aiFeedbackFull = feedback['ai_feedback_full'] ?? "";
        _recommendedRoutines =
            List<String>.from(feedback['recommended_routines'] ?? []);

        final summary = feedback['summary'] as Map<String, dynamic>?;
        if (summary != null) {
          _totalRoutines = summary['total_routines'] ?? 0;
          _totalDurationSeconds = summary['total_duration_seconds'] ?? 0;
        }

        debugPrint("📝 파싱된 피드백 - short: $_aiFeedbackShort");
        debugPrint("📝 추천 루틴: $_recommendedRoutines");

        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint("❌ 피드백 로드 실패: $e");
      if (!mounted) return;

      // API 실패해도 기본 피드백 표시
      setState(() {
        _isLoading = false;
        _aiFeedbackShort = "오늘 하루도 화이팅!";
        _aiFeedbackFull = "루틴을 완료하면 맞춤 피드백을 받을 수 있어요.";
        _recommendedRoutines = ["스트레칭", "물 마시기", "명상"];
        _errorMessage = null; // 에러 메시지 대신 기본 피드백 표시
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return "$minutes분";
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return "$hours시간 $remainingMinutes분";
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<UphillColors>()!;

    return Scaffold(
      backgroundColor: colors.bgMain,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Text(
                'Feedback',
                style: GoogleFonts.montserrat(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 24),

              // Weekly Feedback Card
              _buildWeeklyCard(colors),

              const SizedBox(height: 16),

              // Daily AI Feedback Card
              Expanded(child: _buildInsightCard(colors)),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyCard(UphillColors colors) {
    final now = DateTime.now();
    final dateDisplay =
        "${now.month.toString().padLeft(2, '0')} ${now.day.toString().padLeft(2, '0')}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.feedbackCardWeekBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateDisplay,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.feedbackCardWeekText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Weekly feedback',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.feedbackCardWeekText,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.feedbackBtnCheckBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
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

  Widget _buildInsightCard(UphillColors colors) {
    final now = DateTime.now();

    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.feedbackCardDailyBg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.feedbackCardDailyBg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: colors.feedbackCardDailyText, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: colors.feedbackCardDailyText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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

    // 추천 루틴 한마디 생성
    String recommendationText = "";
    if (_recommendedRoutines.isNotEmpty) {
      recommendationText = "'${_recommendedRoutines.first}' 루틴을 추가해 보는 건 어떨까요?";
      if (_recommendedRoutines.length > 1) {
        recommendationText += " ${_recommendedRoutines.sublist(1).map((r) => "'$r'").join(', ')}도 추천해요!";
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.feedbackCardDailyBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New Badge
          Container(
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
          ),

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
            _aiFeedbackShort.isNotEmpty ? _aiFeedbackShort : "오늘의 피드백을 준비 중이에요",
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
                : "루틴을 완료하면 맞춤 추천을 받을 수 있어요!",
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: colors.feedbackCardDailyText.withValues(alpha: 0.7),
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // 피드백 더보기 (미구현)
          GestureDetector(
            onTap: () {
              // TODO: 더보기 기능 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("더보기 기능은 준비 중이에요"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              children: [
                Text(
                  '피드백 더보기',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.feedbackCardDailyText,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: colors.feedbackCardDailyText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
