import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:udb_association/theme/custom_themes/text_form_field_theme.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    inputDecorationTheme: AInputDecorationTheme.inputDecorationThemeLight,
    textTheme: GoogleFonts.poppinsTextTheme(),
  );
}
