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
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '루틴 등록',
          style: GoogleFonts.notoSans(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Progress Bar (Step 3 - Full)
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 4, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(height: 4, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(height: 4, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'IOT사물 연동\n설정해주세요',
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Floor Plan Placeholder
                    // Figma design shows a specific floor plan. Using a placeholder for now.
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apartment,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "공간 도면",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Space Solution
                    Text(
                      '공간 변경 솔루션',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
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
                                '솔루션',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '침대 옆 협탁을 치우고 요가매트를 깔아보세요',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // IoT Device List
                    Text(
                      'IOT 연동',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_iotDevices.length > 1)
                                  GestureDetector(
                                    onTap: () => _removeIoTDevice(index),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    '사물 종류',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
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
                                              style: GoogleFonts.notoSans(
                                                fontSize: 14,
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
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '밝기',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '최대 밝기', // Or dynamic based on value
                                    style: GoogleFonts.notoSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: double.infinity,
                                child: CupertinoSlider(
                                  value: device['value'] as double,
                                  min: 0,
                                  max: 100,
                                  activeColor: Colors.grey[600],
                                  thumbColor: Colors.white,
                                  onChanged: (val) {
                                    setState(() {
                                      device['value'] = val;
                                    });
                                  },
                                ),
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
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle
                                .solid, // Dashed unsupported in standard container, using solid grey for now or custom painter if needed. keeping simple.
                            // Actually user might want dashed. But solid grey light is okay.
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+ IOT 연동 추가하기',
                          style: GoogleFonts.notoSans(
                            color: Colors.grey[600],
                            fontSize: 14,
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
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF383B45,
                    ), // Dark grey from design
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
                          style: GoogleFonts.notoSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
