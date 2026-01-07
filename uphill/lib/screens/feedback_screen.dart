import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<UphillColors>()!;

    return Scaffold(
      backgroundColor: colors.bgMain,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Text(
                'Feedback',
                style: GoogleFonts.montserrat(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A4A4A), // Consistent header color
                ),
              ),
              const SizedBox(height: 24),

              // Weekly Feedback Card
              _buildWeeklyCard(colors),

              const SizedBox(height: 16),

              // Detailed Insight Card
              Expanded(child: _buildInsightCard(colors)),

              const SizedBox(height: 80), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyCard(UphillColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.feedbackCardWeekBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '12 04',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.feedbackCardWeekText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Weekly feedback',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600, // SemiBold
              color: colors.feedbackCardWeekText,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.feedbackBtnCheckBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                'Check',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.feedbackBtnCheckText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(UphillColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.feedbackCardDailyBg, // Should be darker grey
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.feedbackBadgeNewBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'New!',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.feedbackBadgeNewText,
              ),
            ),
          ),

          const Spacer(), // Push content to bottom

          Text(
            '12/04',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: colors.feedbackCardDailyText.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '침대에서 너무 많은\n시간을 보내고 있어요',
            style: GoogleFonts.montserrat(
              // Korean font needed? GoogleFonts might not support Hangul well in Montserrat.
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.feedbackCardDailyText,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '이러이러한 루틴을 추가해 보는것이 어떤가요?이러이러한 루틴을 추가해 보는것이 어떤가요?이러이러한 루틴을 추가해 보는것이...',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: colors.feedbackCardDailyText.withOpacity(0.7),
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  '피드백 더보기',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.feedbackCardDailyText,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: colors.feedbackCardDailyText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
