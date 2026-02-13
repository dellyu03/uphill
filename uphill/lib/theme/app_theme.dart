import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UphillColors extends ThemeExtension<UphillColors> {
  final Color bgMain;
  final Color routineDefault;
  final Color routinePinned;
  final Color dateSelectedBg;
  final Color timeHighlight;

  const UphillColors({
    required this.bgMain,
    required this.routineDefault,
    required this.routinePinned,
    required this.dateSelectedBg,
    required this.timeHighlight,
  });

  @override
  UphillColors copyWith({
    Color? bgMain,
    Color? routineDefault,
    Color? routinePinned,
    Color? dateSelectedBg,
    Color? timeHighlight,
  }) {
    return UphillColors(
      bgMain: bgMain ?? this.bgMain,
      routineDefault: routineDefault ?? this.routineDefault,
      routinePinned: routinePinned ?? this.routinePinned,
      dateSelectedBg: dateSelectedBg ?? this.dateSelectedBg,
      timeHighlight: timeHighlight ?? this.timeHighlight,
    );
  }

  @override
  UphillColors lerp(ThemeExtension<UphillColors>? other, double t) {
    if (other is! UphillColors) {
      return this;
    }
    return UphillColors(
      bgMain: Color.lerp(bgMain, other.bgMain, t)!,
      routineDefault: Color.lerp(routineDefault, other.routineDefault, t)!,
      routinePinned: Color.lerp(routinePinned, other.routinePinned, t)!,
      dateSelectedBg: Color.lerp(dateSelectedBg, other.dateSelectedBg, t)!,
      timeHighlight: Color.lerp(timeHighlight, other.timeHighlight, t)!,
    );
  }

  // Pre-defined light theme colors based on requirements
  static const light = UphillColors(
    bgMain: Color(0xFFFBFBFB),
    routineDefault: Color(0xFFF8F8F8), // Off White
    routinePinned: Color(0xFFDAD9D4), // Grey
    dateSelectedBg: Color(0xFFD6DABA), // Beige Green from Figma
    timeHighlight: Color(0xFF98A340), // Olive Green
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
        surface: const Color(0xFFFBFBFB),
        outline: const Color(0xFFD3D3D3),
      ),
      scaffoldBackgroundColor: const Color(0xFFFBFBFB),

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
