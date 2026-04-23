import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'orders_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final Order order;
  const OrderSuccessScreen({super.key, required this.order});
  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: AppTheme.success, size: 72),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Order Placed!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1, color: AppTheme.text)),
              const SizedBox(height: 12),
              Text('Order #${widget.order.id} has been placed successfully.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5)),
              const SizedBox(height: 32),
              // Order details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  _row('Order ID', '#${widget.order.id}'),
                  const Divider(height: 20),
                  _row('Items', '${widget.order.items.length}'),
                  const Divider(height: 20),
                  _row('Total Paid', '₹${widget.order.totalPrice.toStringAsFixed(0)}'),
                  const Divider(height: 20),
                  _row('Status', widget.order.status),
                ]),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OrdersScreen()), (_) => false),
                  child: const Text('Track Order', style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
                child: const Text('Continue Shopping', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
    ],
  );
}
