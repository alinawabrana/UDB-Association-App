import 'package:flutter/material.dart';

class ProfileOverviewItem extends StatelessWidget {
  const ProfileOverviewItem({
    super.key,
    required this.title,
    required this.value,
    this.isPercentage = false,
    this.valueColor,
  });

  final String title;
  final int value;
  final bool isPercentage;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$value${isPercentage ? '%' : ''}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Color(0xFF6B7B47),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
