import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../main_scaffold.dart';
import 'onboarding_step1_screen.dart';

/// Uphill 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _loading = false;
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    try {
      // 타임아웃 10초 설정
      final hasAuth = await _authService.loadStoredAuth().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⚠️ 인증 정보 로드 타임아웃');
          return false;
        },
      );

      if (hasAuth && _authService.isLoggedIn) {
        if (mounted) {
          // 기존 사용자는 온보딩 완료된 것으로 간주하고 메인으로
          debugPrint('✅ 자동 로그인 성공 - 메인 화면으로 이동');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScaffold()),
          );
        }
      } else {
        if (mounted) {
          debugPrint('ℹ️ 저장된 인증 정보 없음 - 로그인 화면 표시');
          setState(() => _checkingAuth = false);
        }
      }
    } catch (e) {
      debugPrint('❌ 인증 확인 중 에러: $e');
      if (mounted) {
        setState(() => _checkingAuth = false);
      }
    }
  }

  /// Google 로그인 실행
  /// [Backend 요청] POST /auth/google
  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);

    try {
      // Google Sign In 및 백엔드 인증
      final success = await _authService.signIn();

      if (success && _authService.isLoggedIn) {
        if (mounted) {
          // 신규 사용자면 온보딩으로, 기존 사용자면 메인으로
          if (_authService.isNewUser) {
            debugPrint('✅ 신규 사용자 - 온보딩으로 이동');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OnboardingStep1Screen(),
              ),
            );
          } else {
            debugPrint('✅ 기존 사용자 - 메인 화면으로 이동');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScaffold()),
            );
          }
        }
      } else {
        throw Exception("로그인에 실패했습니다");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("로그인 실패: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(
        backgroundColor: Color(0xFFE9E8E7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // 헤더 텍스트
              _buildHeader(),

              const SizedBox(height: 40),

              // 일러스트레이션
              _buildIllustration(),

              const Spacer(flex: 2),

              // 버튼들
              _buildButtons(),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          '나에게',
          style: GoogleFonts.notoSansKr(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B1B1B),
            letterSpacing: -0.72,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '맞춰 지는 루틴',
          style: GoogleFonts.notoSansKr(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B1B1B),
            letterSpacing: -0.72,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Uphill',
          style: GoogleFonts.montserrat(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF9CAA7D),
            letterSpacing: -1.44,
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 280,
      child: Image.asset(
        'assets/images/manager_desk.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback illustration using Icon
          return Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 120,
                  color: const Color(0xFF1B1B1B).withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Icon(
                  Icons.person,
                  size: 80,
                  color: const Color(0xFF1B1B1B).withValues(alpha: 0.8),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Google 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : _signInWithGoogle,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B1B1B),
              elevation: 0,
              shadowColor: Colors.black.withValues(alpha: 0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            child: _loading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1B1B1B),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        color: Colors.white,
                        child: Image.asset(
                          'assets/images/google_icon.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '구글 계정으로 시작하기',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B1B1B),
                          letterSpacing: -0.48,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // 회원가입 버튼
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : _signInWithGoogle,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B1B1B),
              elevation: 0,
              shadowColor: Colors.black.withValues(alpha: 0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            child: Text(
              '회원가입하기',
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B1B1B),
                letterSpacing: -0.48,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
