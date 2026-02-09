import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
      height: 85, // Figma Height adjusted
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

    final dayStr = DateFormat('d').format(date);
    final weekStr = DateFormat('E').format(date).toUpperCase();

    return Container(
      width: 54, // Figma width approx
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ), // Margin for shadow if needed
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF434343)
            : Colors.transparent, // Dark grey for selected
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
              color: isSelected ? Colors.white : const Color(0xFFC6C5C3),
            ),
          ),
          const SizedBox(height: 2),
          // Weekday
          Text(
            weekStr,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFFC6C5C3),
            ),
          ),
        ],
      ),
    );
  }
}
