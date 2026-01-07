import 'package:flutter/material.dart';
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
    // Generate dates: Today - 2 days to Today + 4 days (Total 7)
    // Or just a static week based on mockup logic
    final now = DateTime.now();
    // Normalize now to midnight
    final today = DateTime(now.year, now.month, now.day);

    // Generate list around selectedDate or Today
    // Let's create a range of dates.
    final dates = List.generate(7, (index) {
      return today.add(
        Duration(days: index - 2),
      ); // 2 days before, 4 days after
    });

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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
    final colors = Theme.of(context).extension<UphillColors>()!;
    final dayStr = DateFormat('d').format(date);
    final weekStr = DateFormat('E').format(date).toUpperCase(); // SUN, MON...

    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: isSelected ? colors.dateSelectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(30), // Capsule shape
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayStr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black87 : Colors.black38,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weekStr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.black87 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
