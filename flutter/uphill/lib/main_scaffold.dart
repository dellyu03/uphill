import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  late final List<Widget> _screens = [
    HomeScreen(key: _homeKey),
    const FeedbackScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
                    _buildNavItem(
                      0,
                      'assets/icons/home_on.svg',
                      'assets/icons/home_off.svg',
                    ),
                    _buildNavItem(
                      1,
                      'assets/icons/feedback_on.svg',
                      'assets/icons/feedback_off.svg',
                    ), // Using feedback icons for retrospective for now
                    _buildNavItem(
                      2,
                      'assets/icons/user_on.svg',
                      'assets/icons/user_off.svg',
                    ), // Assuming user icons exist or fallbacks
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String activeIconPath,
    String inactiveIconPath,
  ) {
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
          ? (index ==
                    2 // Profile icon might be different, let's use standard icons if SVG assets are missing/uncertain, or try to load SVG
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
