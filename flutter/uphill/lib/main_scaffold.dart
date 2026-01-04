import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'login_test.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final AuthService _authService = AuthService();
  bool _checkingAuth = true;

  late final List<Widget> _screens = [
    HomeScreen(key: _homeKey),
    const FeedbackScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final hasAuth = await _authService.loadStoredAuth();
    if (!hasAuth || !_authService.isLoggedIn) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GoogleLoginScreen()),
        );
      }
    } else {
      setState(() => _checkingAuth = false);
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
      backgroundColor: const Color(0xFFE9E8E7),
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 224,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0),
                    _buildNavItem(1),
                    _buildNavItem(2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0 && _currentIndex == 0) {
          _homeKey.currentState?.scrollToCurrentTime();
        }
        setState(() {
          _currentIndex = index;
        });
      },
      child: isSelected
          ? (index == 2
                ? const Icon(Icons.person, color: Colors.black)
                : (index == 1
                      ? const Icon(Icons.list_alt, color: Colors.black)
                      : const Icon(Icons.home, color: Colors.black)))
          : (index == 2
                ? const Icon(Icons.person_outline, color: Colors.grey)
                : (index == 1
                      ? const Icon(Icons.list_alt, color: Colors.grey)
                      : const Icon(Icons.home_outlined, color: Colors.grey))),
    );
  }
}
