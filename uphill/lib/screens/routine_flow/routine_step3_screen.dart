import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../main_scaffold.dart';
import '../../services/routine_service.dart';

class RoutineStep3Screen extends StatefulWidget {
  final String routineTitle;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  
  const RoutineStep3Screen({
    super.key,
    required this.routineTitle,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<RoutineStep3Screen> createState() => _RoutineStep3ScreenState();
}

class _RoutineStep3ScreenState extends State<RoutineStep3Screen> {
  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  final List<bool> selectedDays = List.generate(7, (index) => false);
  bool isAlarmOn = false;
  final RoutineService _routineService = RoutineService();
  bool _isSaving = false;

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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(days.length, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDays[index] = !selectedDays[index];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
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
                            fontSize: 13,
                          ),
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
                onPressed: _isSaving ? null : _saveRoutine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
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

  Future<void> _saveRoutine() async {
    // 선택된 요일이 없으면 경고
    final selectedDayIndices = <int>[];
    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) {
        selectedDayIndices.add(i);  // 0=월, 1=화, ..., 6=일
      }
    }

    if (selectedDayIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("요일을 하나 이상 선택해주세요"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 시작 시간을 HH:MM 형식으로 변환
      final timeStr = '${widget.startTime.hour.toString().padLeft(2, '0')}:${widget.startTime.minute.toString().padLeft(2, '0')}';

      // 카테고리는 기본값으로 설정 (나중에 카테고리 선택 기능 추가 가능)
      await _routineService.createRoutine(
        title: widget.routineTitle,
        time: timeStr,
        category: '일반',
        days: selectedDayIndices,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ 루틴이 생성되었습니다!"),
            backgroundColor: Colors.green,
          ),
        );
        
        // 메인 화면으로 이동 (바텀 네비게이션 포함)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScaffold()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("❌ 루틴 생성 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("루틴 생성 실패: $e"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}
