import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'routine_step3_screen.dart';

class RoutineStep2Screen extends StatefulWidget {
  final String routineTitle;
  
  const RoutineStep2Screen({super.key, required this.routineTitle});

  @override
  State<RoutineStep2Screen> createState() => _RoutineStep2ScreenState();
}

class _RoutineStep2ScreenState extends State<RoutineStep2Screen> {
  TimeOfDay startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 8, minute: 0);

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
            // Progress Bar (Step 2)
            Row(
              children: [
                Expanded(child: Container(height: 4, color: Colors.black)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 4, color: Colors.black)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 4, color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              '시간을\n설정해주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            _buildTimePicker('시작 시간', startTime, (newTime) {
              setState(() => startTime = newTime);
            }),
            const SizedBox(height: 24),
            _buildTimePicker('종료 시간', endTime, (newTime) {
              setState(() => endTime = newTime);
            }),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutineStep3Screen(
                        routineTitle: widget.routineTitle,
                        startTime: startTime,
                        endTime: endTime,
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

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showTimePicker(context, time, onTimeChanged),
            child: Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimePicker(
    BuildContext context,
    TimeOfDay initialTime,
    Function(TimeOfDay) onTimeChanged,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                  2024,
                  1,
                  1,
                  initialTime.hour,
                  initialTime.minute,
                ),
                onDateTimeChanged: (val) {
                  onTimeChanged(TimeOfDay.fromDateTime(val));
                },
              ),
            ),
            CupertinoButton(
              child: const Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
