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
    final dayStr = DateFormat('d').format(date);
    final weekStr = DateFormat('E', 'en_US').format(date).toUpperCase();

    return Container(
      width: 44, // Figma constraint adjusted
      height: 60,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE1EB96) : Colors.transparent,
        borderRadius: BorderRadius.circular(isSelected ? 8 : 20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day Number
          Text(
            dayStr,
            style: GoogleFonts.notoSansKr(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF3D3D3D)
                  : const Color(0xFFC6C5C3),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          // Weekday
          Text(
            weekStr,
            style: GoogleFonts.notoSansKr(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF3D3D3D)
                  : const Color(0xFFC6C5C3),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
