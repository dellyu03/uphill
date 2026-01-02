import 'package:flutter/material.dart';
import 'main_scaffold.dart';
import 'theme/app_theme.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uphill Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
        extensions: const <ThemeExtension<dynamic>>[UphillColors.light],
      ),
      home: const MainScaffold(),
    );
  }
}
