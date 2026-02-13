import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/routine_service.dart';

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
  late Future<Map<String, dynamic>> _routineFuture;

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
      final timeStr = data['time'] as String? ?? '00:00';
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
      backgroundColor: const Color(0xFFFBFBFB), // Updated to #FBFBFB
      body: FutureBuilder<Map<String, dynamic>>(
        future: _routineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }

          final data = snapshot.data ?? {};
          final title = data['title'] ?? widget.title;
          final space = data['space'] ?? '공간';

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
                            // Badge: "현재 루틴"
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD8E29C),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '현재 루틴',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Subtitle: "진행 중인 루틴"
                            Text(
                              '진행 중인 루틴',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 18,
                                color: const Color(
                                  0x66555151,
                                ), // approx 0.4 opacity
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Title: Routine Name
                            Text(
                              title,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 29,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF555151),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 1. Space Image (Dynamic based on space)
                      Center(
                        child: Container(
                          width: 336,
                          height: 293,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // Soft rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              spaceImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback if image not found
                                return Image.asset(
                                  'assets/images/google_icon.png', // Temporary safe fallback or simply a colored box
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 2. Solution Card (Dynamic text)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$space 루틴 솔루션', // Adapting title
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xE6515151), // 0.9 opacity
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                solutionText, // Providing actionable text based on space
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 14,
                                  color: const Color(0x99515151), // 0.6 opacity
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Bottom Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '시작 시간',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 18,
                                color: const Color(0x99000000),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Builder(
                              builder: (context) {
                                // Parse Start Time from 'time' field (e.g. "07:00")
                                final timeStr =
                                    data['time'] as String? ?? '00:00';
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
                                        // Start Time (Black)
                                        Text(
                                          _formatDateTime(routineStartTime),
                                          style: GoogleFonts.inter(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                            color: Colors
                                                .black, // Explicitly Black
                                          ),
                                        ),
                                        // Elapsed Time (Red)
                                        Text(
                                          '+${(elapsed.inMinutes).toString()}m',
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            color: const Color(0xFFFF6E6E),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: _isCompleting
                                          ? null
                                          : _handleComplete,
                                      child: Container(
                                        width: 81,
                                        height: 46,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4E4E4E),
                                          borderRadius: BorderRadius.circular(
                                            23,
                                          ),
                                        ),
                                        child: _isCompleting
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                '완료',
                                                style: GoogleFonts.notoSansKr(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
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
                left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back_ios, color: Colors.black54),
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
