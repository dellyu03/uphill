import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main_scaffold.dart';
import '../../services/routine_service.dart';

class RoutineStep3Screen extends StatefulWidget {
  final String routineTitle;

  // Step 1 Data
  final String purpose;
  final String space;
  final String description;

  // Step 2 Data
  final bool isFlexible;
  final TimeOfDay startTime;
  final TimeOfDay?
  endTime; // Can be null if not flexible or not set? Actually mandatory in design but let's see. logic says mandatory.
  final List<int> selectedDays; // Indices
  final String? notificationTime;

  const RoutineStep3Screen({
    super.key,
    required this.routineTitle,
    required this.purpose,
    required this.space,
    required this.description,
    required this.isFlexible,
    required this.startTime,
    required this.endTime,
    required this.selectedDays,
    this.notificationTime,
  });

  @override
  State<RoutineStep3Screen> createState() => _RoutineStep3ScreenState();
}

class _RoutineStep3ScreenState extends State<RoutineStep3Screen> {
  final RoutineService _routineService = RoutineService();
  bool _isSaving = false;

  // IoT Devices State
  // Structure: { 'type': '조명', 'value': 50 }
  final List<Map<String, dynamic>> _iotDevices = [
    {'type': '조명', 'value': 80.0}, // Default 1 item
  ];

  final List<String> _deviceTypes = ['조명', '커튼', '공기청정기', '가습기', '스피커'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '루틴 설정',
          style: GoogleFonts.notoSansKr(
            color: const Color(0xFF292B32),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Bar (Step 3 - Full)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3E3E0),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3E3E0),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC0C28D),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 52),
                    Text(
                      'IOT사물 연동을\n설정해주세요',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        letterSpacing: -0.3,
                        color: const Color(0xFF292B32),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Floor Plan Placeholder (Image placeholder)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/floor_plan_placeholder.png',
                          ), // Add proper image later
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "공간 도면 영역",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Space Solution
                    Text(
                      '공간 변경 솔루션',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF484846),
                        letterSpacing: -0.14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '솔루션',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF484846),
                                    letterSpacing: -0.14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '침대 옆 협탁을 치우고 요가매트를 깔아보세요',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color.fromRGBO(
                                      136,
                                      136,
                                      128,
                                      0.8,
                                    ),
                                    letterSpacing: -0.14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Color(0xFF484846),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // IoT Device List
                    Text(
                      '루틴 성격',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF484846),
                        letterSpacing: -0.14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(_iotDevices.length, (index) {
                      final device = _iotDevices[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'IOT 사물 (${index + 1})',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF484846),
                                    letterSpacing: -0.14,
                                  ),
                                ),
                                if (_iotDevices.length > 1)
                                  GestureDetector(
                                    onTap: () => _removeIoTDevice(index),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: Color(0xFFB3B3B3),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  '사물 종류',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF484846),
                                    letterSpacing: -0.12,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Container(
                                    height: 44,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE6E6E6),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: device['type'],
                                        isExpanded: true,
                                        items: _deviceTypes.map((type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: Text(
                                              type,
                                              style: GoogleFonts.notoSansKr(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF484846),
                                                letterSpacing: -0.12,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              device['type'] = value;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (device['type'] == '조명') ...[
                              const SizedBox(height: 24),
                              // Divider
                              const Divider(
                                color: Color(0xFFE6E6E6),
                                height: 1,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '조명 설정',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF484846),
                                  letterSpacing: -0.12,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '밝기',
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color.fromRGBO(
                                        136,
                                        136,
                                        128,
                                        0.8,
                                      ),
                                      letterSpacing: -0.12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: CupertinoSlider(
                                      value: device['value'] as double,
                                      min: 0,
                                      max: 100,
                                      activeColor: const Color(0xFFE5EF9F),
                                      thumbColor: Colors.white,
                                      onChanged: (val) {
                                        setState(() {
                                          device['value'] = val;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(device['value'] as double).toInt()}%',
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF484846),
                                      letterSpacing: -0.12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '색온도',
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color.fromRGBO(
                                        136,
                                        136,
                                        128,
                                        0.8,
                                      ),
                                      letterSpacing: -0.12,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFB84D),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '4,500K',
                                        style: GoogleFonts.notoSansKr(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF484846),
                                          letterSpacing: -0.12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_right_rounded,
                                        color: Color(0xFFC6C5C3),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }),

                    // Add Button
                    GestureDetector(
                      onTap: _addIoTDevice,
                      child: Container(
                        height: 56, // 50 -> 56
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8), // Same as bg
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFCCCCCC),
                            style: BorderStyle.solid,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+ IOT 연동 추가하기',
                          style: GoogleFonts.notoSansKr(
                            // notoSans -> Ks
                            color: const Color(0xFF999999),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),

            // Fixed Bottom Button
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB0B97C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          '완료',
                          style: GoogleFonts.notoSansKr(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addIoTDevice() {
    setState(() {
      _iotDevices.add({'type': '조명', 'value': 50.0});
    });
  }

  void _removeIoTDevice(int index) {
    setState(() {
      _iotDevices.removeAt(index);
    });
  }

  Future<void> _saveRoutine() async {
    setState(() => _isSaving = true);

    try {
      // 1. Convert TimeOfDay to String HH:MM
      final startTimeStr =
          '${widget.startTime.hour.toString().padLeft(2, '0')}:${widget.startTime.minute.toString().padLeft(2, '0')}';

      String? endTimeStr;
      if (widget.endTime != null) {
        endTimeStr =
            '${widget.endTime!.hour.toString().padLeft(2, '0')}:${widget.endTime!.minute.toString().padLeft(2, '0')}';
      }

      // 3. Call Service
      await _routineService.createRoutine(
        title: widget.routineTitle,
        time: startTimeStr, // Main start time
        category: '일반', // Fixed for now
        days: widget.selectedDays, // Already List<int>
        // Extended Fields
        purpose: widget.purpose,
        space: widget.space,
        description: widget.description,
        isFlexible: widget.isFlexible,
        endTime: endTimeStr,
        notificationTime: widget.notificationTime, // Already String?
        iotDevices: _iotDevices,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ 루틴이 생성되었습니다!"),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Home/Main
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
          SnackBar(content: Text("루틴 생성 실패: $e"), backgroundColor: Colors.red),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}
