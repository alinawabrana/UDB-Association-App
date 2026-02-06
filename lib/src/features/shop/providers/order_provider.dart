import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/shop/models/order_model.dart';
import 'package:udb_association/src/features/shop/services/order_service.dart';

final ordersProvider = FutureProvider<OrdersResponse>((ref) async {
  return await OrderService.getOrders();
});

final orderProvider = FutureProvider.family<OrderModel, int>((
  ref,
  orderId,
) async {
  return await OrderService.getOrderById(orderId);
});

final vendorOrdersProvider = FutureProvider<OrdersResponse>((ref) async {
  return await OrderService.getVendorOrders();
});
