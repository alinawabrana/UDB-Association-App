import 'package:flutter/material.dart';

class CircularContainer extends StatelessWidget {
  const CircularContainer({
    super.key,
    this.width = 32,
    this.height = 32,
    this.backgroundColor,
    this.iconColor,
    required this.icon,
    this.onTap,
  });

  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? iconColor;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? Color(0xFF3B82F6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 15, color: iconColor ?? Colors.white),
      ),
    );
  }
}
