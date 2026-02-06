import 'package:flutter/material.dart';
import 'package:udb_association/src/features/profile/widgets/profile_overview_item.dart';

class ProfileOverviewCard extends StatelessWidget {
  const ProfileOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -60,
      left: 16,
      right: 16,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000), // #0000001A → black with 10% opacity
              offset: Offset(0, 10), // x=0, y=10
              blurRadius: 15, // blur
              spreadRadius: 0, // spread
            ),
            BoxShadow(
              color: Color(0x1A000000), // same semi-transparent black
              offset: Offset(0, 4), // x=0, y=4
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProfileOverviewItem(title: 'Years', value: 3),
            ProfileOverviewItem(
              title: 'Events',
              value: 12,
              valueColor: Color(0xFF3B82F6),
            ),
            ProfileOverviewItem(title: 'Active', value: 98, isPercentage: true),
          ],
        ),
      ),
    );
  }
}
