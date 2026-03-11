import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetrospectiveScreen extends StatelessWidget {
  const RetrospectiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Feedback',
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF292B32),
                    letterSpacing: -0.32,
                  ),
                ),
              ),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: const Color(0xFF555555),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFFB3B3B3),
                    labelStyle: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Daily'),
                      Tab(text: 'Weekly'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    _buildFeedbackList(isWeekly: false), // Daily
                    _buildFeedbackList(isWeekly: true), // Weekly
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add new retrospective
          },
          backgroundColor: const Color(0xFF555555),
          shape: const CircleBorder(),
          elevation: 2,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFeedbackList({required bool isWeekly}) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isWeekly
                        ? '2023. 10. Week ${4 - index}'
                        : '2023. 10. ${24 - index}',
                    style: GoogleFonts.notoSansKr(
                      color: const Color(0xFFB3B3B3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.12,
                    ),
                  ),
                  const Icon(
                    Icons.more_horiz,
                    color: Color(0xFFC6C5C3),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Image Placeholder
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isWeekly ? 'Weekly Routine Review' : '오늘의 운동 루틴 회고',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF292B32),
                  letterSpacing: -0.16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isWeekly
                    ? '이번 주는 전체적으로 목표를 달성했다. 다음 주는 강도를 조금 더 높여보자.'
                    : '오늘은 컨디션이 좋아서 목표보다 더 많이 운동했다. 뿌듯하다.',
                style: GoogleFonts.notoSansKr(
                  color: const Color(0xFFB3B3B3),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: -0.14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
