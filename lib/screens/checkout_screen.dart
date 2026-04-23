import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl = TextEditingController(text: '123 MG Road, Bengaluru, Karnataka 560001');
  bool _placing = false;

  @override
  void dispose() { _addressCtrl.dispose(); super.dispose(); }

  Future<void> _placeOrder() async {
    setState(() => _placing = true);
    try {
      final order = await context.read<OrdersProvider>().placeOrder(address: _addressCtrl.text);
      final newBalance = context.read<AuthProvider>().user!.walletBalance - order.totalPrice;
      context.read<AuthProvider>().updateWallet(newBalance < 0 ? 0 : newBalance);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Address
          const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: TextField(
              controller: _addressCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter delivery address',
                prefixIcon: Padding(padding: EdgeInsets.only(bottom: 40), child: Icon(Icons.location_on_outlined)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Order summary
          const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.imageUrl, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 44, height: 44, color: AppTheme.background))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text('×${item.quantity}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(width: 8),
                  Text('₹${item.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
              )),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Subtotal'),
                Text('₹${cart.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 6),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Delivery'),
                Text('FREE', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600)),
              ]),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('₹${cart.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.text)),
              ]),
            ]),
          ),
          const SizedBox(height: 24),

          // Payment
          const Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.account_balance_wallet, color: AppTheme.primary)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Wallet Payment', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Balance: ₹${auth.user?.walletBalance.toStringAsFixed(0) ?? 0}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ])),
              const Icon(Icons.check_circle, color: AppTheme.primary),
            ]),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _placing ? null : _placeOrder,
              child: _placing
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Pay ₹${cart.total.toStringAsFixed(0)} & Place Order', style: const TextStyle(fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }
}
