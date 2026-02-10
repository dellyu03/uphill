import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class DateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Generate dates: Today - 2 days to Today + 4 days (Total 7)
    final today = DateTime(now.year, now.month, now.day);

    final dates = List.generate(7, (index) {
      return today.add(Duration(days: index - 2));
    });

    return SizedBox(
      height: 70, // Figma height approx (66px + padding)
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ), // Increased padding
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10), // Gaps
        itemBuilder: (context, index) {
          final date = dates[index];
          final bool isSelected =
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: _DateItem(date: date, isSelected: isSelected),
          );
        },
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;

  const _DateItem({required this.date, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    // Figma Colors inferred
    // Selected: Background almost black/dark grey, Text White
    // Unselected: Transparent, Text Grey

    final colors = Theme.of(context).extension<UphillColors>()!;
    final dayStr = DateFormat('d').format(date);
    final weekStr = DateFormat('E', 'en_US').format(date).toUpperCase();

    return Container(
      width: 52, // Figma width
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ), // Margin for shadow if needed
      decoration: BoxDecoration(
        color: isSelected ? colors.dateSelectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.transparent),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day Number
          Text(
            dayStr,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF504D4D)
                  : const Color(0xFFC6C5C3),
            ),
          ),
          const SizedBox(height: 2),
          // Weekday
          Text(
            weekStr,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF424242)
                  : const Color(0xFFC6C5C3),
            ),
          ),
        ],
      ),
    );
  }
}
