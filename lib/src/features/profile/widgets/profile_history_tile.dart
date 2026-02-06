import 'package:flutter/material.dart';

import '../../../common/widgets/circular_container.dart';

class PaymentHistoryTile extends StatelessWidget {
  const PaymentHistoryTile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.price,
    required this.isPaid,
  });

  final String title;
  final String subTitle;
  final double price;
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircularContainer(
        width: 40,
        height: 40,
        icon: isPaid ? Icons.check : Icons.watch_later,
        iconColor: isPaid ? Color(0xFF16A34A) : Color(0xFFCA8A04),
        backgroundColor: isPaid ? Color(0xFFDCFCE7) : Color(0xFFFEF9C3),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subTitle,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF4B5563),
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),

          Text(
            isPaid ? 'Paid' : 'Pending',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isPaid ? Color(0xFF16A34A) : Color(0xFFCA8A04),
            ),
          ),
        ],
      ),
    );
  }
}
