import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'main_scaffold.dart';
import 'theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GoogleLoginApp());
}

class GoogleLoginApp extends StatelessWidget {
  const GoogleLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uphill',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
        extensions: const <ThemeExtension<dynamic>>[UphillColors.light],
      ),
      home: const GoogleLoginScreen(),
    );
  }
}

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  final AuthService _authService = AuthService();
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
      // 이미 로그인되어 있으면 메인 화면으로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScaffold()),
        );
      }
    } else {
      setState(() => _checkingAuth = false);
    }
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);

    try {
      final success = await _authService.signIn();

      if (success && _authService.isLoggedIn) {
        debugPrint("🎉 구글 로그인 전체 플로우 완료!");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ 구글 로그인 성공!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // 메인 화면으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScaffold()),
          );
        }
      } else {
        throw Exception("로그인에 실패했습니다");
      }
    } catch (e, stack) {
      debugPrint("=" * 60);
      debugPrint("❌ 에러 발생!");
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stack");
      debugPrint("=" * 60);

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE9E8E7),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Uphill',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '루틴을 통해 더 나은 하루를 만들어보세요',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                if (_loading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.login,
                                color: Colors.white,
                                size: 24,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Google로 로그인',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
