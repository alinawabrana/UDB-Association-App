import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    required this.onPressed,
    this.gradient,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: boxShadow,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon:
            leading ??
            Icon(icon, color: foregroundColor ?? Colors.white, size: 20),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            label,
            style: TextStyle(
              color: foregroundColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: gradient == null
              ? backgroundColor ?? Color(0xFF6B7C32)
              : Colors.transparent,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
        ),
      ),
    );
  }
}
