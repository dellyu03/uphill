import 'package:flutter/material.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  int _selectedDateIndex = 0; // Default to the 1st item (Today)
  int _selectedIndex = 0; // Bottom nav index

  List<Map<String, dynamic>> _dates = [];

  @override
  void initState() {
    super.initState();
    _generateDates();
  }

  void _generateDates() {
    final now = DateTime.now();
    for (int i = 0; i < 14; i++) {
      final date = now.add(Duration(days: i));
      _dates.add({
        'day': date.day.toString(),
        'weekday': _getWeekday(date.weekday),
      });
    }
  }

  String _getWeekday(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  final List<Map<String, dynamic>> _routines = [
    {
      'time': '07:00',
      'title': '기상 및 물 한 잔',
      'category': '건강',
      'color': Colors.orangeAccent,
    },
    {
      'time': '08:00',
      'title': '아침 조깅 30분',
      'category': '운동',
      'color': Colors.blue,
    },
    {
      'time': '09:00',
      'title': '아침 스트레칭 루틴',
      'category': '운동',
      'color': Colors.blueAccent,
    },
    {
      'time': '12:00',
      'title': '건강한 점심 식사',
      'category': '식사',
      'color': Colors.redAccent,
    },
    {
      'time': '14:00',
      'title': '오후 업무 집중',
      'category': '업무',
      'color': Colors.purpleAccent,
    },
    {
      'time': '16:00',
      'title': '오후 스트레칭',
      'category': '운동',
      'color': Colors.lightGreenAccent,
    },
    {
      'time': '19:00',
      'title': '저녁 식사 및 휴식',
      'category': '생활',
      'color': Colors.pinkAccent,
    },
    {
      'time': '21:00',
      'title': '독서 및 일기 쓰기',
      'category': '자기계발',
      'color': Colors.teal,
    },
    {
      'time': '23:00',
      'title': '취침 준비',
      'category': '수면',
      'color': Colors.indigoAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Stack(
                      children: [
                        const Icon(
                          Icons.notifications,
                          size: 30,
                          color: Colors.black87,
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(
                                  color: Color(0xFFF9F9F9),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _dates.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedDateIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDateIndex = index;
                        });
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF3F8A6)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _dates[index]['day'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _dates[index]['weekday'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Text(
                  'Daily routine',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final routine = _routines[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Text(
                              routine['time'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: CustomPaint(
                                painter: DottedLinePainter(),
                                size: const Size(1, double.infinity),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: routine['color'],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      routine['title'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 24.0),
                                  child: Text(
                                    routine['category'],
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ), // Extra space for card height
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: _routines.length),
            ),
            // Add some bottom padding for scrolling
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1F2029),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_outlined, 0),
            _buildNavItem(Icons.map_outlined, 1),
            _buildNavItem(Icons.bookmark_border, 2),
            _buildNavItem(Icons.search, 3),
          ],
        ),
      ),
      extendBody: true, // Allows content to go behind the bottom nav
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F8A6) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 26),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4;
    const dashSpace = 4;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
