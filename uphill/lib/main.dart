/// Uphill 앱 진입점
/// Firebase 초기화 및 앱 테마 설정을 담당합니다.
library;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'screens/onboarding/login_screen.dart';
import 'screens/onboarding/onboarding_step1_screen.dart';
import 'screens/onboarding/onboarding_step2_screen.dart';
import 'screens/onboarding/onboarding_step3_screen.dart';
import 'screens/onboarding/onboarding_step4_screen.dart';
import 'theme/app_theme.dart';
import 'constants/app_constants.dart';

/// 앱 메인 함수
/// Firebase 초기화 후 앱을 실행합니다.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

/// 앱 루트 위젯
/// MaterialApp 설정 및 테마를 정의합니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp - 앱 전역 설정
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      // 앱 테마 설정
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
        extensions: const <ThemeExtension<dynamic>>[UphillColors.light],
      ),
      // 메인 화면
      home: const LoginScreen(),
      // 라우트 설정
      routes: {
        '/onboarding/step1': (context) => const OnboardingStep1Screen(),
        '/onboarding/step2': (context) => const OnboardingStep2Screen(),
        '/onboarding/step3': (context) => const OnboardingStep3Screen(),
        '/onboarding/step4': (context) => const OnboardingStep4Screen(),
      },
    );
  }
}
