import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/routine_service.dart';
import '../models/routine.dart';

class RoutineInProgressScreen extends StatefulWidget {
  final String routineId;
  final String title;

  const RoutineInProgressScreen({
    super.key,
    required this.routineId,
    required this.title,
  });

  @override
  State<RoutineInProgressScreen> createState() =>
      _RoutineInProgressScreenState();
}

class _RoutineInProgressScreenState extends State<RoutineInProgressScreen> {
  final RoutineService _routineService = RoutineService();
  late Future<Routine> _routineFuture;

  // Timer State
  Timer? _timer;

  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _routineFuture = _routineService.getRoutine(widget.routineId);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Trigger rebuild to update elapsed time display
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    try {
      // Fetch data to calculate duration from scheduled time
      final data = await _routineFuture;
      final timeStr = data.time ?? '00:00';
      final now = DateTime.now();
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Calculate Scheduled Start Time for Today
      final routineStartTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      final duration = now.difference(routineStartTime);

      await _routineService.createExecution(
        routineId: widget.routineId,
        routineTitle: widget.title,
        startedAt: routineStartTime,
        endedAt: now,
        durationSeconds: duration.inSeconds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('루틴이 완료되었습니다!'),
            backgroundColor: Color(0xFF4E4E4E),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("❌ 루틴 완료 처리 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('완료 처리 실패: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isCompleting = false);
      }
    }
  }

  // Helper to get Space Image
  String _getSpaceImage(String space) {
    // User requested specific floor plan image.
    // The user stated they would provide the image, so we expect 'assets/images/floor_plan.png' to exist.
    return 'assets/images/floor_plan.png';
  }

  // Helper to get Solution Text
  String _getSpaceSolution(String space) {
    if (space.contains('침대') || space.contains('방')) {
      return '더욱 원활한 기상을 위해 침대 앞 협탁을 정리하고, 스트레칭 공간을 확보해보세요.';
    } else if (space.contains('책상') || space.contains('서재')) {
      return '집중력을 높이기 위해 책상 위 불필요한 물건을 정리하고 시작해보세요.';
    } else if (space.contains('거실')) {
      return '편안한 마음가짐을 위해 조도를 낮추고 소음 요소를 차단해보세요.';
    } else if (space.contains('주방') || space.contains('부엌')) {
      return '건강한 하루를 위해 미지근한 물 한 잔을 먼저 준비해보세요.';
    }
    return '더욱 원활한 루틴 진행을 위해 주변 환경을 정돈하고, 방해 요소를 제거해보세요.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), // Updated to #F8F8F8
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // Hide default app bar space to use Stack properly
      ),
      body: FutureBuilder<Routine>(
        future: _routineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('루틴 정보를 불러올 수 없습니다.'));
          }
          final data = snapshot.data!;
          final title = data.title;
          final space = data.space ?? '공간';

          final solutionText = _getSpaceSolution(space);
          final spaceImage = _getSpaceImage(space);

          return Stack(
            children: [
              // Scrollable Content
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60), // Top padding
                      // Header Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ), // Top margin down from SafeArea
                            // Badge: "현재 루틴"
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE5EF9F,
                                ), // Updated Background Color
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '현재 루틴',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF292B32),
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Title: Routine Name
                            Text(
                              title,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF555151),
                                letterSpacing: -0.24,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20), // 40 -> 20
                      // 1. Space Image (Dynamic based on space)
                      Center(
                        child: Container(
                          width: double
                              .infinity, // Expand to take max width available (padding will constrain)
                          height: 293, // maintain height
                          child: Image.asset(
                            spaceImage,
                            fit: BoxFit
                                .contain, // cover -> contain to respect layout like the figma design
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if image not found
                              return Image.asset(
                                'assets/images/google_icon.png', // Temporary safe fallback or simply a colored box
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 32), // 40 -> 32
                      // 2. Solution Card (Dynamic text)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '공간 변경 루틴 솔루션', // Adapting title
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF666666),
                                  letterSpacing: -0.16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                solutionText, // Providing actionable text based on space
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFB3B3B3),
                                  letterSpacing: -0.14,
                                  height: 1.57, // 22px / 14px
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 60), // 40 -> 60
                      // Bottom Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '종료 시간', // 시작 시간 -> 종료 시간
                              style: GoogleFonts.notoSansKr(
                                fontSize: 16,
                                color: const Color(0xFF666666),
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                // Parse Start Time from 'time' field (e.g. "07:00")
                                final timeStr = data.time ?? '00:00';
                                final now = DateTime.now();
                                final parts = timeStr.split(':');
                                final hour = int.parse(parts[0]);
                                final minute = int.parse(parts[1]);

                                // Create DateTime for Today at Routine Time
                                final routineStartTime = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  hour,
                                  minute,
                                );
                                final elapsed = now.difference(
                                  routineStartTime,
                                );

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // End Time (Black)
                                        Text(
                                          _formatDateTime(routineStartTime),
                                          style: GoogleFonts.inter(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF4D4D4D),
                                            letterSpacing: -0.64,
                                          ),
                                        ),
                                        // Elapsed Time (Red)
                                        Text(
                                          '+${(elapsed.inMinutes).toString()}m',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            color: const Color(0xFFFF6E6E),
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: -0.16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: _isCompleting
                                          ? null
                                          : _handleComplete,
                                      child: Container(
                                        width: 80,
                                        height: 44,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF555555),
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                        ),
                                        child: _isCompleting
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                '완료',
                                                style: GoogleFonts.notoSansKr(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                  letterSpacing: -0.14,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Back Button (Floating)
              Positioned(
                top: 50,
                right: 20, // left -> right
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close_rounded,
                      color: Color(0xFF292B32),
                      size: 24,
                    ), // arrow_back_ios -> close
                  ),
                ),
              ),

              // Timeline Visual Decoration (Check Box)
              // Positioning this absolutely as per Figma might be tricky on different screens via Stack/Positioned logic
              // within a ScrollView. For now, omitting the complex dashed box overlay or finding a better place for it.
              // To fully match Figma, one would need exact coordinates relative to the screen.
              // Given this is a scrolling view, we can place it relative to the solution card if needed.
              // I will add a simplified visual anchor near the bottom section if appropriate.
            ],
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
