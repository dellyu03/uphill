import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/dummy_auth_service.dart';
import '../../main_scaffold.dart';
import 'onboarding_step1_screen.dart';

/// Uphill 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final DummyAuthService _authService = DummyAuthService();
  bool _loading = false;
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    final hasAuth = await _authService.loadStoredAuth();
    if (hasAuth && _authService.isLoggedIn) {
      if (mounted) {
        // 온보딩 완료 여부 확인
        if (_authService.onboardingCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScaffold()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingStep1Screen(),
            ),
          );
        }
      }
    } else {
      setState(() => _checkingAuth = false);
    }
  }

  Future<void> _showAccountSelection() async {
    final emails = _authService.getAvailableEmails();

    final selectedEmail = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          '테스트 계정 선택',
          style: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B1B1B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...emails.map(
              (email) => ListTile(
                title: Text(
                  email,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () => Navigator.pop(context, email),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(
                '새 계정 만들기',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9CAA7D),
                ),
              ),
              onTap: () => Navigator.pop(context, 'new_account'),
            ),
          ],
        ),
      ),
    );

    if (selectedEmail != null) {
      if (selectedEmail == 'new_account') {
        final newEmail =
            'test${DateTime.now().millisecondsSinceEpoch}@test.com';
        await _signInWithEmail(newEmail);
      } else {
        await _signInWithEmail(selectedEmail);
      }
    }
  }

  Future<void> _signInWithEmail(String email) async {
    setState(() => _loading = true);

    try {
      final success = await _authService.signIn(email);

      if (success && _authService.isLoggedIn) {
        if (mounted) {
          // 신규 사용자는 온보딩으로, 기존 사용자는 메인으로
          if (_authService.isNewUser || !_authService.onboardingCompleted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OnboardingStep1Screen(),
              ),
            );
          } else {
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
          SnackBar(content: Text("로그인 실패: $e"), backgroundColor: Colors.red),
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
            onPressed: _loading ? null : _showAccountSelection,
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
            onPressed: _loading ? null : _showAccountSelection,
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
