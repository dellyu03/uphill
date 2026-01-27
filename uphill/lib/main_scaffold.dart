/// 메인 스캐폴드 위젯
/// 바텀 네비게이션 바와 화면 전환을 담당합니다.
library;

import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'login_test.dart';
import 'constants/app_constants.dart';
import 'theme/app_theme.dart';

/// 메인 스캐폴드 위젯
/// 3개 탭 (홈, 피드백, 프로필)을 관리합니다.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  /// 현재 선택된 탭 인덱스
  int _currentIndex = 0;

  /// 홈 화면 상태 접근을 위한 GlobalKey
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  /// 피드백 화면 상태 접근을 위한 GlobalKey
  final GlobalKey<FeedbackScreenState> _feedbackKey =
      GlobalKey<FeedbackScreenState>();

  /// 인증 서비스 싱글톤
  final AuthService _authService = AuthService();

  /// 인증 확인 중 여부
  bool _checkingAuth = true;

  /// 화면 목록
  late final List<Widget> _screens = [
    HomeScreen(key: _homeKey),
    FeedbackScreen(key: _feedbackKey),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  /// 저장된 인증 정보 확인
  /// 로그인되어 있지 않으면 로그인 화면으로 이동합니다.
  Future<void> _checkAuth() async {
    // [Backend 요청] 저장된 인증 정보 로드
    final hasAuth = await _authService.loadStoredAuth();

    if (!hasAuth || !_authService.isLoggedIn) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GoogleLoginScreen()),
        );
      }
    } else {
      if (mounted) {
        setState(() => _checkingAuth = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<UphillColors>()!;

    // 인증 확인 중 로딩 표시
    if (_checkingAuth) {
      return Scaffold(
        backgroundColor: colors.bgMain,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 메인 스캐폴드 - 화면 + 바텀 네비게이션
    return Scaffold(
      backgroundColor: colors.bgMain,
      body: Stack(
        children: [
          // 화면 스택 - 탭별 화면 유지
          IndexedStack(index: _currentIndex, children: _screens),
          // 바텀 네비게이션 바
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  /// 바텀 네비게이션 바 위젯
  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: LayoutConstants.bottomNavBottom,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: LayoutConstants.bottomNavWidth,
          height: LayoutConstants.bottomNavHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              LayoutConstants.largeBorderRadius,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // 네비게이션 아이템 행
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0), // 홈
              _buildNavItem(1), // 피드백
              _buildNavItem(2), // 프로필
            ],
          ),
        ),
      ),
    );
  }

  /// 네비게이션 아이템 위젯
  /// [index] 탭 인덱스 (0: 홈, 1: 피드백, 2: 프로필)
  Widget _buildNavItem(int index) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: _getNavIcon(index, isSelected),
    );
  }

  /// 네비게이션 아이템 탭 핸들러
  void _onNavItemTapped(int index) {
    // 홈탭 재탭 시 현재 시간으로 스크롤
    if (index == 0 && _currentIndex == 0) {
      _homeKey.currentState?.scrollToCurrentTime();
    }

    // 피드백 탭 전환 시 새로고침
    if (index == 1) {
      _feedbackKey.currentState?.refreshFeedback();
    }

    setState(() {
      _currentIndex = index;
    });
  }

  /// 네비게이션 아이콘 반환
  Widget _getNavIcon(int index, bool isSelected) {
    final color = isSelected ? Colors.black : Colors.grey;

    switch (index) {
      case 0:
        return Icon(
          isSelected ? Icons.home : Icons.home_outlined,
          color: color,
        );
      case 1:
        return Icon(Icons.list_alt, color: color);
      case 2:
        return Icon(
          isSelected ? Icons.person : Icons.person_outline,
          color: color,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
