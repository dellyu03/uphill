import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UphillColors extends ThemeExtension<UphillColors> {
  final Color bgMain;
  final Color routineUpdated;
  final Color routineDefault;
  final Color routinePinned;
  final Color textEmphasis;
  final Color textMuted;
  final Color dateSelectedBg;
  final Color timeHighlight;
  final Color feedbackCardWeekBg;
  final Color feedbackCardWeekText;
  final Color feedbackBtnCheckBg;
  final Color feedbackBtnCheckText;
  final Color feedbackCardDailyBg;
  final Color feedbackCardDailyText;
  final Color feedbackBadgeNewBg;
  final Color feedbackBadgeNewText;

  const UphillColors({
    required this.bgMain,
    required this.routineUpdated,
    required this.routineDefault,
    required this.routinePinned,
    required this.textEmphasis,
    required this.textMuted,
    required this.dateSelectedBg,
    required this.timeHighlight,
    required this.feedbackCardWeekBg,
    required this.feedbackCardWeekText,
    required this.feedbackBtnCheckBg,
    required this.feedbackBtnCheckText,
    required this.feedbackCardDailyBg,
    required this.feedbackCardDailyText,
    required this.feedbackBadgeNewBg,
    required this.feedbackBadgeNewText,
  });

  @override
  UphillColors copyWith({
    Color? bgMain,
    Color? routineUpdated,
    Color? routineDefault,
    Color? routinePinned,
    Color? textEmphasis,
    Color? textMuted,
    Color? dateSelectedBg,
    Color? timeHighlight,
    Color? feedbackCardWeekBg,
    Color? feedbackCardWeekText,
    Color? feedbackBtnCheckBg,
    Color? feedbackBtnCheckText,
    Color? feedbackCardDailyBg,
    Color? feedbackCardDailyText,
    Color? feedbackBadgeNewBg,
    Color? feedbackBadgeNewText,
  }) {
    return UphillColors(
      bgMain: bgMain ?? this.bgMain,
      routineUpdated: routineUpdated ?? this.routineUpdated,
      routineDefault: routineDefault ?? this.routineDefault,
      routinePinned: routinePinned ?? this.routinePinned,
      textEmphasis: textEmphasis ?? this.textEmphasis,
      textMuted: textMuted ?? this.textMuted,
      dateSelectedBg: dateSelectedBg ?? this.dateSelectedBg,
      timeHighlight: timeHighlight ?? this.timeHighlight,
      feedbackCardWeekBg: feedbackCardWeekBg ?? this.feedbackCardWeekBg,
      feedbackCardWeekText: feedbackCardWeekText ?? this.feedbackCardWeekText,
      feedbackBtnCheckBg: feedbackBtnCheckBg ?? this.feedbackBtnCheckBg,
      feedbackBtnCheckText: feedbackBtnCheckText ?? this.feedbackBtnCheckText,
      feedbackCardDailyBg: feedbackCardDailyBg ?? this.feedbackCardDailyBg,
      feedbackCardDailyText:
          feedbackCardDailyText ?? this.feedbackCardDailyText,
      feedbackBadgeNewBg: feedbackBadgeNewBg ?? this.feedbackBadgeNewBg,
      feedbackBadgeNewText: feedbackBadgeNewText ?? this.feedbackBadgeNewText,
    );
  }

  @override
  UphillColors lerp(ThemeExtension<UphillColors>? other, double t) {
    if (other is! UphillColors) {
      return this;
    }
    return UphillColors(
      bgMain: Color.lerp(bgMain, other.bgMain, t)!,
      routineUpdated: Color.lerp(routineUpdated, other.routineUpdated, t)!,
      routineDefault: Color.lerp(routineDefault, other.routineDefault, t)!,
      routinePinned: Color.lerp(routinePinned, other.routinePinned, t)!,
      textEmphasis: Color.lerp(textEmphasis, other.textEmphasis, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      dateSelectedBg: Color.lerp(dateSelectedBg, other.dateSelectedBg, t)!,
      timeHighlight: Color.lerp(timeHighlight, other.timeHighlight, t)!,
      feedbackCardWeekBg: Color.lerp(
        feedbackCardWeekBg,
        other.feedbackCardWeekBg,
        t,
      )!,
      feedbackCardWeekText: Color.lerp(
        feedbackCardWeekText,
        other.feedbackCardWeekText,
        t,
      )!,
      feedbackBtnCheckBg: Color.lerp(
        feedbackBtnCheckBg,
        other.feedbackBtnCheckBg,
        t,
      )!,
      feedbackBtnCheckText: Color.lerp(
        feedbackBtnCheckText,
        other.feedbackBtnCheckText,
        t,
      )!,
      feedbackCardDailyBg: Color.lerp(
        feedbackCardDailyBg,
        other.feedbackCardDailyBg,
        t,
      )!,
      feedbackCardDailyText: Color.lerp(
        feedbackCardDailyText,
        other.feedbackCardDailyText,
        t,
      )!,
      feedbackBadgeNewBg: Color.lerp(
        feedbackBadgeNewBg,
        other.feedbackBadgeNewBg,
        t,
      )!,
      feedbackBadgeNewText: Color.lerp(
        feedbackBadgeNewText,
        other.feedbackBadgeNewText,
        t,
      )!,
    );
  }

  // Pre-defined light theme colors based on requirements
  static const light = UphillColors(
    bgMain: Color(0xFFE9E8E7),
    routineUpdated: Color(0xFFB3B5A0), // Sage Green
    routineDefault: Color(0xFFF8F8F8), // Off White
    routinePinned: Color(0xFFDAD9D4), // Grey
    textEmphasis: Colors.black,
    textMuted: Colors.black54,
    dateSelectedBg: Color(0xFFD6DABA), // Beige Green from Figma
    timeHighlight: Color(0xFF98A340), // Olive Green
    // Feedback Screen Colors
    feedbackCardWeekBg: Color(0xFFD9D9D9),
    feedbackCardWeekText: Color(0xFF636363),
    feedbackBtnCheckBg: Color(0xFF434343),
    feedbackBtnCheckText: Color(0xFFFFFFFF),
    feedbackCardDailyBg: Color(0x33000000), // 20% opacity black
    feedbackCardDailyText: Color(0xFFFFFFFF),
    feedbackBadgeNewBg: Color(0xFFB9C292),
    feedbackBadgeNewText: Color(0xFFFFFFFF),
  );
}

class UphillTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.montserratTextTheme(),
      // Change seed color from deepPurple to something neutral or brand-aligned
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF333333),
        primary: const Color(0xFF333333),
        secondary: const Color(0xFF333333),
        surface: const Color(0xFFF6F6F6),
        outline: const Color(0xFFD3D3D3),
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F6F6),

      // Text Selection Theme (Cursor, Selection Handle)
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFF333333),
        selectionColor: Color(0x33333333),
        selectionHandleColor: Color(0xFF333333),
      ),

      // Input Decoration Theme (TextFields)
      inputDecorationTheme: InputDecorationTheme(
        activeIndicatorBorder: const BorderSide(color: Color(0xFF333333)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF333333)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Time Picker Theme
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteTextColor: const Color(0xFF333333),
        hourMinuteColor: const Color(0xFFF4F4F4),
        dialHandColor: const Color(0xFF333333),
        dialBackgroundColor: const Color(0xFFF4F4F4),
        dayPeriodTextColor: const Color(0xFF333333),
        dayPeriodColor: const Color(0xFFF4F4F4), // Am/Pm selector background
        dayPeriodBorderSide: const BorderSide(color: Color(0xFFD3D3D3)),
        confirmButtonStyle: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(const Color(0xFF333333)),
        ),
        cancelButtonStyle: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(const Color(0xFF666666)),
        ),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF333333);
          }
          return null;
        }),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF333333);
          }
          return null;
        }),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF333333);
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF333333).withValues(alpha: 0.5);
          }
          return null;
        }),
      ),

      // Extensions
      extensions: const <ThemeExtension<dynamic>>[UphillColors.light],
    );
  }
}
