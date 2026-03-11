/// 메인 스캐폴드 위젯
/// 바텀 네비게이션 바와 화면 전환을 담당합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'screens/home_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/profile_screen.dart';
import 'services/dummy_auth_service.dart';
import 'screens/onboarding/login_screen.dart';
import 'constants/app_constants.dart';

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
  final DummyAuthService _authService = DummyAuthService();

  /// 인증 확인 중 여부
  bool _checkingAuth = true;

  /// 화면 목록
  late final List<Widget> _screens = [
    HomeScreen(key: _homeKey),
    FeedbackScreen(key: _feedbackKey),
    const ProfileScreen(),
  ];

  /// 페이지 컨트롤러
  late final PageController _pageController = PageController(
    initialPage: _currentIndex,
  );

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
    // 인증 확인 중 로딩 표시
    if (_checkingAuth) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF555555)),
        ),
      );
    }

    // 메인 스캐폴드 - 화면 + 바텀 네비게이션
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          // 화면 스택 - PageView로 변경하여 슬라이딩 효과 적용
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(), // 부드러운 스크롤 효과
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: _screens,
          ),
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
      behavior: HitTestBehavior.opaque, // 터치 영역 확장
      child: Container(
        padding: const EdgeInsets.all(12), // 터치 영역 확보
        child: _getNavIcon(index, isSelected),
      ),
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

    // 페이지 전환 애니메이션
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // setState는 onPageChanged에서 처리됨
  }

  /// 네비게이션 아이콘 반환
  Widget _getNavIcon(int index, bool isSelected) {
    // 선택 여부에 따른 아이콘 경로 설정
    String iconPath = '';

    switch (index) {
      case 0:
        iconPath = isSelected
            ? 'assets/icons/home_on.svg'
            : 'assets/icons/home_off.svg';
        break;
      case 1:
        iconPath = isSelected
            ? 'assets/icons/feedback_on.svg'
            : 'assets/icons/feedback_off.svg';
        break;
      case 2:
        // 프로필은 on/off가 따로 없는 경우 단일 아이콘 사용
        iconPath = 'assets/icons/profile.svg';
        break;
    }

    // SVG 아이콘 반환
    if (iconPath.isNotEmpty) {
      return SvgPicture.asset(
        iconPath,
        width: 28,
        height: 28,
        // 프로필 아이콘의 경우 선택 시 색상 변경이 필요하다면 colorFilter 사용
        // 현재는 디자인에 따라 원본 색상 유지
        colorFilter: index == 2 && isSelected
            ? const ColorFilter.mode(Colors.black, BlendMode.srcIn)
            : null,
      );
    }

    return const SizedBox.shrink();
  }
}
