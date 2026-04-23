import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<OrdersProvider>().loadOrders());
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'DELIVERED': return AppTheme.success;
      case 'CANCELLED': return AppTheme.error;
      case 'SHIPPED': return AppTheme.primary;
      default: return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('My Orders')),
      body: orders.loading
          ? const Center(child: CircularProgressIndicator())
          : orders.orders.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: AppTheme.border),
                  SizedBox(height: 16),
                  Text('No orders yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                ]))
              : RefreshIndicator(
                  onRefresh: () => orders.loadOrders(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final order = orders.orders[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order))),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: _statusColor(order.status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Text(order.status, style: TextStyle(color: _statusColor(order.status), fontWeight: FontWeight.w700, fontSize: 12)),
                              ),
                            ]),
                            const SizedBox(height: 8),
                            Text('${order.items.length} item${order.items.length != 1 ? 's' : ''} · ₹${order.totalPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            const SizedBox(height: 12),
                            if (order.items.isNotEmpty)
                              SizedBox(
                                height: 44,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: order.items.length > 3 ? 3 : order.items.length,
                                  itemBuilder: (_, j) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(order.items[j].imageUrl, width: 44, height: 44, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(width: 44, height: 44, color: AppTheme.background)),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                              Text('Track Order →', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                            ]),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
