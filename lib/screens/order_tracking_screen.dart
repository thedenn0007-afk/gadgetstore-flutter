import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statuses = AppConstants.orderStatuses;
    final currentIdx = statuses.indexOf(order.status);
    final isCancelled = order.status == 'CANCELLED';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text('Order #${order.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: isCancelled ? [AppTheme.error, const Color(0xFFFF6B6B)] : [AppTheme.primary, const Color(0xFF34C8FF)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isCancelled ? 'Order Cancelled' : 'Track your order', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(order.status, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('₹${order.totalPrice.toStringAsFixed(0)} · ${order.items.length} item${order.items.length != 1 ? 's' : ''}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 24),

          // Timeline
          const Text('Order Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: List.generate(statuses.length, (i) {
                final isDone = !isCancelled && i < currentIdx;
                final isActive = !isCancelled && i == currentIdx;
                final isLast = i == statuses.length - 1;
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: isDone ? AppTheme.success : isActive ? AppTheme.primary : AppTheme.background,
                        shape: BoxShape.circle,
                        border: isActive ? Border.all(color: AppTheme.primary, width: 2) : null,
                      ),
                      child: Center(child: isDone
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : isActive ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle))
                          : Text('${i + 1}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600))),
                    ),
                    if (!isLast) Container(width: 2, height: 36, color: isDone ? AppTheme.success.withOpacity(0.3) : AppTheme.border),
                  ]),
                  const SizedBox(width: 16),
                  Padding(
                    padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 36),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(statuses[i], style: TextStyle(
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isDone || isActive ? AppTheme.text : AppTheme.textSecondary,
                        fontSize: 14,
                      )),
                      if (isDone) const Text('Completed', style: TextStyle(color: AppTheme.success, fontSize: 12)),
                      if (isActive) const Text('In progress', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
                    ]),
                  ),
                ]);
              }),
            ),
          ),
          const SizedBox(height: 24),

          // Items
          const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.imageUrl, width: 52, height: 52, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 52, height: 52, color: AppTheme.background))),
                const SizedBox(width: 12),
                Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                Text('×${item.quantity}', style: const TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(width: 8),
                Text('₹${(item.price * item.quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            )).toList()),
          ),
        ]),
      ),
    );
  }
}
