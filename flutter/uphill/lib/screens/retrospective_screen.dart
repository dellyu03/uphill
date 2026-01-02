import 'package:flutter/material.dart';

class RetrospectiveScreen extends StatelessWidget {
  const RetrospectiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFE9E8E7),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: const Text(
                  'Feedback',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: const Color(0xFF484848),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
          backgroundColor: const Color(0xFF484848),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFeedbackList({required bool isWeekly}) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
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
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.more_horiz, color: Colors.black26),
                ],
              ),
              const SizedBox(height: 16),
              // Image Placeholder
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withOpacity(0.03)),
                ),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.black.withOpacity(0.1),
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isWeekly ? 'Weekly Routine Review' : '오늘의 운동 루틴 회고',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isWeekly
                    ? '이번 주는 전체적으로 목표를 달성했다. 다음 주는 강도를 조금 더 높여보자.'
                    : '오늘은 컨디션이 좋아서 목표보다 더 많이 운동했다. 뿌듯하다.',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.6,
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
