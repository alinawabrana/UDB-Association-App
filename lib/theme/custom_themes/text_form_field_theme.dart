import 'package:flutter/material.dart';

class AInputDecorationTheme {
  static final inputDecorationThemeLight = InputDecorationThemeData(
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF526167)),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    hintStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xFFADAEBC),
    ),
    prefixIconColor: Color(0xFF9CA3AF),
    suffixIconColor: Color(0xFF9CA3AF),
  );
}
