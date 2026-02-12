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

  // 0: 공간 (Space), 1: 물품 (Item)
  int _selectedTab = 0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _routineFuture = _routineService.getRoutine(widget.routineId);
  }

  Future<void> _handleComplete() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    try {
      // 완료 처리 (기존 로직 재사용, 시간은 0 또는 임의값)
      await _routineService.createExecution(
        routineId: widget.routineId,
        routineTitle: widget.title,
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
        durationSeconds: 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('루틴이 완료되었습니다!'),
            backgroundColor: Colors.green,
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
        title: Text(
          '루틴 진행',
          style: GoogleFonts.notoSansKr(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _routineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('루틴 정보를 찾을 수 없습니다.'));
          }

          final data = snapshot.data!;
          final title = data['title'] ?? widget.title;
          final startTime = data['time'] ?? '00:00';
          final endTime = data['end_time'] ?? '00:00';
          // 만약 end_time이 없다면 기본 로직대로 +30분 등 처리 가능하나,
          // 여기서는 서버/저장된 데이터 우선.

          final isFlexible =
              data['is_flexible'] ==
              true; // bool or String check needed based on API
          // API might return 'true' string or boolean. Safe check:
          // In previous code it was passed as boolean to createRoutine. Assuming dynamic map.

          final days = List<int>.from(data['days'] ?? []);
          final space = data['space'] ?? '설정되지 않음';
          final iotDevices = data['iot_devices'] as List<dynamic>? ?? [];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // 1. Title & Time
                      Center(
                        child: Column(
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTimeRange(startTime, endTime),
                              style: GoogleFonts.notoSansKr(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(
                            isFlexible ? '변동가능' : '고정',
                            const Color(0xFFE0E0E0),
                            Colors.black,
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            _formatDays(days),
                            const Color(0xFFFFF4E5),
                            const Color(0xFFFF9500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // 3. Toggle Switch (Space / Item)
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: _selectedTab == 0
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Container(
                                width:
                                    MediaQuery.of(context).size.width / 2 -
                                    24, // Half width approximation
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedTab = 0),
                                    behavior: HitTestBehavior.translucent,
                                    child: Center(
                                      child: Text(
                                        '공간',
                                        style: GoogleFonts.notoSansKr(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedTab == 0
                                              ? Colors.black
                                              : const Color(0xFF8E8E93),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedTab = 1),
                                    behavior: HitTestBehavior.translucent,
                                    child: Center(
                                      child: Text(
                                        '물품',
                                        style: GoogleFonts.notoSansKr(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedTab == 1
                                              ? Colors.black
                                              : const Color(0xFF8E8E93),
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
                      const SizedBox(height: 32),

                      // 4. Content Area
                      if (_selectedTab == 0)
                        _buildSpaceContent(space)
                      else
                        _buildItemContent(iotDevices),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isCompleting ? null : _handleComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _isCompleting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '루틴 완료',
                            style: GoogleFonts.notoSansKr(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSansKr(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSpaceContent(String space) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Icon(
              Icons.meeting_room,
              size: 48,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            space,
            style: GoogleFonts.notoSansKr(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이 공간에서 루틴을 진행해주세요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemContent(List<dynamic> devices) {
    if (devices.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              '연동된 물품이 없습니다.',
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                color: const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: devices.map((device) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.devices_other, color: Colors.black),
              const SizedBox(width: 12),
              Text(
                device.toString(), // Assuming device name or map
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatTimeRange(String start, String end) {
    // start, end format: "HH:mm"
    // Convert to "오후/오전 HH:mm"
    // This is a simple formatter
    try {
      final s = _parseTime(start);
      final e = _parseTime(end);
      return '${_formatTimeOfDay(s)} - ${_formatTimeOfDay(e)}';
    } catch (_) {
      return '$start - $end';
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? '오전' : '오후';
    // 12:00 -> 12:00
    // 0:00 -> 12:00
    final displayHour = hour == 0 ? 12 : hour;
    return '$period $displayHour:$minute';
  }

  String _formatDays(List<int> days) {
    if (days.length == 7) return '매일';
    if (days.isEmpty) return '선택 안함';
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    return days.map((d) => weekDays[d]).join(', ');
  }
}
