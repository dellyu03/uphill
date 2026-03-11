import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/routine_service.dart';
import '../models/routine.dart';
import 'routine_edit_screen.dart';

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
  late Future<Routine> _routineFuture;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: _buildAppBar(),
      body: FutureBuilder<Routine>(
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
          final title = data.title;
          final purpose = data.purpose ?? '운동';
          final description = data.description ?? '설명이 없습니다.';
          final space = data.space ?? '설정되지 않음';
          final days = data.days;

          final startTime = data.time ?? '00:00';
          final endTime = data.endTime ?? '00:00';

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // 1. Header Area
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge: "생성된 루틴"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EF9F),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '생성된 루틴',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF292B32),
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF292B32),
                              letterSpacing: -0.24,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. Info Area (Purpose, Description)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '목적 | $purpose',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF484846),
                              letterSpacing: -0.12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromRGBO(136, 136, 128, 0.8),
                              letterSpacing: -0.12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 3. Visual Section (Image + Graphics)
                    _buildVisualSection(),

                    const SizedBox(height: 20),

                    // 4. Environment
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '루틴환경',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF484846),
                              letterSpacing: -0.14,
                            ),
                          ),
                          Text(
                            space,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF484846),
                              letterSpacing: -0.14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 5. Solution Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildSolutionCard(),
                    ),

                    const SizedBox(height: 32),

                    // 6. Time & Repeat Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '루틴 지속 시간',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF484846),
                              letterSpacing: -0.16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTimeCard(startTime, endTime, _formatDays(days)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Floating Button - removed for this design as Figma doesn't show it prominently
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF292B32),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.edit_outlined,
            color: Color(0xFF292B32),
            size: 22,
          ),
          onPressed: () {
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
                _loadRoutine();
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFF292B32),
            size: 22,
          ),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('루틴 삭제'),
                  content: Text('"${widget.title}" 루틴을 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('삭제'),
                    ),
                  ],
                );
              },
            );
            if (confirmed == true && mounted) {
              try {
                await RoutineService().deleteRoutine(widget.routineId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('루틴이 삭제되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (mounted) {
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
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildVisualSection() {
    return SizedBox(
      width: double.infinity,
      height: 280,
      child: Center(
        child: Image.asset(
          'assets/images/floor_plan.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 291,
              height: 253,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '이미지 준비중',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSolutionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '공간 변경 루틴 솔루션',
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF666666),
              letterSpacing: -0.16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '더욱 원활한 운동을 위해 침대 앞 협탁을 책상 쪽으로 치우고, 요가 매트를 깔아 보세요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFB3B3B3),
              letterSpacing: -0.14,
              height: 1.57,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(String start, String end, String days) {
    final dayNames = ['월', '화', '수', '목', '금', '토', '일'];
    final activeDays = days.split(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Repeat Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '반복',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF484846),
                  letterSpacing: -0.14,
                ),
              ),
              Row(
                children: [
                  ...dayNames.map((day) {
                    final isActive = activeDays.contains(day) || days == '매일';
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFE5EF9F)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isActive
                              ? null
                              : Border.all(color: const Color(0xFFE6E6E6)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          day,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? const Color(0xFF484846)
                                : const Color(0xFFB3B3B3),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFC6C5C3),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),
          // Time Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '루틴 지속 시간',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF484846),
                  letterSpacing: -0.14,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${start.isEmpty ? '--:--' : start}  ~  ${end.isEmpty ? '--:--' : end}',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF484846),
                      letterSpacing: -0.14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFC6C5C3),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDays(List<int> days) {
    if (days.length == 7) return '매일';
    if (days.isEmpty) return '선택 안함';
    final weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    return days.map((d) => weekDays[d]).join(', ');
  }
}
