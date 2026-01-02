import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../home_screen.dart';

class RoutineStep3Screen extends StatefulWidget {
  const RoutineStep3Screen({super.key});

  @override
  State<RoutineStep3Screen> createState() => _RoutineStep3ScreenState();
}

class _RoutineStep3ScreenState extends State<RoutineStep3Screen> {
  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  final List<bool> selectedDays = List.generate(7, (index) => false);
  bool isAlarmOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '루틴 등록',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Progress Bar (Step 3)
            Row(
              children: [
                Expanded(child: Container(height: 4, color: Colors.black)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 4, color: Colors.black)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 4, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              '요일과 알림을\n설정해주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            // Day Selector
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(days.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDays[index] = !selectedDays[index];
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: selectedDays[index]
                            ? Colors.black
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedDays[index]
                              ? Colors.black
                              : Colors.grey[300]!,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        days[index],
                        style: TextStyle(
                          color: selectedDays[index]
                              ? Colors.white
                              : Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            // Alarm Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '시작 알림 받기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  CupertinoSwitch(
                    value: isAlarmOn,
                    activeColor: Colors.black,
                    onChanged: (value) {
                      setState(() {
                        isAlarmOn = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to Home (and conceptually save)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '완료',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
