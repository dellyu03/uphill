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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.3, 0.49, 0.67, 1.0],
            colors: [
              Color(0x00BDDE54), // rgba(189, 222, 84, 0)
              Color(0x54C7DE5D), // rgba(199, 222, 93, 0.33)
              Color(0xFFEAF0C2), // rgb(234, 240, 194)
              Color(0xFFD4E090), // rgb(212, 224, 144)
              Color(0xFFAABB49), // rgb(170, 187, 73)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),

                // 헤더 텍스트
                _buildHeader(),

                const Spacer(),

                // 일러스트레이션 (Figma의 경우 배경 곡선이 들어가나, 에센셜한 부분만 유지)
                Center(child: _buildIllustration()),

                const Spacer(),

                // 버튼들
                _buildButtons(),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '나에게\n맞추어 지는 루틴',
            style: GoogleFonts.notoSansKr(
              fontSize: 40,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4A4A4A),
              letterSpacing: -0.8,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Uphill',
            style: GoogleFonts.montserrat(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1.44,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 200,
      // 기존 일러스트 또는 피그마 상의 원형 그래픽으로 대체 가능하므로 투명 처리해 둡니다.
      child: Container(),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Google 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _showAccountSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFADBE3E),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/google_icon.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.g_mobiledata,
                                size: 24,
                                color: Colors.blue,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '구글 계정으로 시작하기',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFADBE3E),
                          letterSpacing: -0.32,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 14),

        // 회원가입 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _showAccountSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              '회원가입하기',
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF797979),
                letterSpacing: -0.32,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
