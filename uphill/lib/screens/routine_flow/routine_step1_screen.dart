import 'package:flutter/material.dart';
import 'routine_step2_screen.dart';

class RoutineStep1Screen extends StatefulWidget {
  const RoutineStep1Screen({super.key});

  @override
  State<RoutineStep1Screen> createState() => _RoutineStep1ScreenState();
}

class _RoutineStep1ScreenState extends State<RoutineStep1Screen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6), // SVG Background
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
            // Progress Bar (Simplified for now)
            Row(
              children: [
                Expanded(child: Container(height: 4, color: Colors.black)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 4, color: Colors.grey[300])),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 4, color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              '루틴 이름을\n입력해주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '예) 모닝 독서',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("루틴 이름을 입력해주세요"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutineStep2Screen(
                        routineTitle: _nameController.text.trim(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '다음',
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
