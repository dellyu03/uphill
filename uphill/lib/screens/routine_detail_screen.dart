import 'package:flutter/material.dart';
import '../services/routine_service.dart';
import 'routine_edit_screen.dart';
import 'routine_in_progress_screen.dart';
import '../theme/app_theme.dart';

class RoutineDetailScreen extends StatefulWidget {
  final String routineId;
  final String title;
  final String timeRange;

  const RoutineDetailScreen({
    super.key,
    required this.routineId,
    required this.title,
    required this.timeRange,
  });

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  late Future<Map<String, dynamic>> _routineFuture;

  @override
  void initState() {
    super.initState();
    _loadRoutine();
  }

  void _loadRoutine() {
    setState(() {
      _routineFuture = RoutineService().getRoutine(widget.routineId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final theme = Theme.of(context);
    final uphillColors = theme.extension<UphillColors>();
    final textColor = uphillColors?.textEmphasis ?? Colors.black;
    final mutedColor = uphillColors?.textMuted ?? Colors.grey;
    final cardBgColor = Colors.white;
    final borderColor = uphillColors?.dateSelectedBg ?? Colors.black12;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: textColor),
            onPressed: _showMoreOptions,
          ),
        ],
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
          final purpose = data['purpose'] ?? '기타';
          final space = data['space'] ?? '설정되지 않음';
          final description = data['description'] ?? '';
          final iotDevices = List<Map<String, dynamic>>.from(
            data['iot_devices'] ?? [],
          );
          final isFlexible = data['is_flexible'] ?? true;
          final notificationTime = data['notification_time'] ?? '알림 없음';
          final days = List<int>.from(data['days'] ?? []);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Title & Time Section
                      Text(
                        data['title'] ?? widget.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          widget.timeRange, // Or reconstruct from data['time']
                          style: TextStyle(
                            fontSize: 14,
                            color: mutedColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle('루틴 정보', textColor),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('목적', purpose, textColor, mutedColor),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              '성격',
                              isFlexible ? '변동가능' : '고정',
                              textColor,
                              mutedColor,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              '반복',
                              _formatDays(days),
                              textColor,
                              mutedColor,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              '알림',
                              notificationTime,
                              textColor,
                              mutedColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle('공간 및 환경', textColor),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('공간', space, textColor, mutedColor),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                '환경 설명',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: mutedColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      if (iotDevices.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _buildSectionTitle('IoT 기기', textColor),
                        const SizedBox(height: 12),
                        ...iotDevices.map(
                          (device) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.power, // Placeholder icon
                                  color: textColor,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        device['type'] ?? '기기',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: textColor,
                                        ),
                                      ),
                                      if (device['hasBrightness'] == true)
                                        Text(
                                          '밝기: ${(device['brightness'] * 100).toInt()}%',
                                          style: TextStyle(
                                            color: mutedColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: true, // Dummy status
                                  onChanged: (val) {},
                                  activeColor: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100), // Bottom padding for button
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoutineInProgressScreen(
                            routineId: widget.routineId,
                            title: data['title'] ?? widget.title,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '루틴 시작하기',
                      style: TextStyle(
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

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color textColor,
    Color mutedColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: mutedColor, fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDays(List<int> days) {
    if (days.length == 7) return '매일';
    if (days.isEmpty) return '선택 안함';
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    return days.map((d) => weekDays[d]).join(', ');
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('수정하기'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutineEditScreen(
                        routineId: widget.routineId,
                        title: widget.title,
                        timeRange: widget.timeRange,
                      ),
                    ),
                  ).then((updated) {
                    if (updated == true) {
                      _loadRoutine(); // Reload data
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('삭제하기', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('루틴 삭제'),
                        content: Text('\'${widget.title}\' 루틴을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('삭제'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed == true && context.mounted) {
                    try {
                      await RoutineService().deleteRoutine(widget.routineId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('루틴이 삭제되었습니다'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context, true);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('삭제 실패: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
