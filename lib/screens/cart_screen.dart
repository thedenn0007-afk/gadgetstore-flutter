import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
                  title: const Text('Clear Cart'),
                  content: const Text('Remove all items?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
                  ],
                ));
                if (confirm == true) cart.clearCart();
              },
              child: const Text('Clear', style: TextStyle(color: AppTheme.error)),
            ),
        ],
      ),
      body: cart.loading
          ? const Center(child: CircularProgressIndicator())
          : cart.items.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: AppTheme.border),
                  SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  SizedBox(height: 8),
                  Text('Add products to get started', style: TextStyle(color: AppTheme.textSecondary)),
                ]))
              : Column(children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final item = cart.items[i];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(item.imageUrl, width: 72, height: 72, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 72, height: 72, color: AppTheme.background)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              const SizedBox(height: 8),
                              Row(children: [
                                Container(
                                  decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(8)),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    SizedBox(width: 28, height: 28, child: IconButton(
                                      padding: EdgeInsets.zero, icon: const Icon(Icons.remove, size: 14),
                                      onPressed: item.quantity > 1
                                          ? () async { /* update qty via API */ }
                                          : null,
                                    )),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                    SizedBox(width: 28, height: 28, child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.add, size: 14), onPressed: null)),
                                  ]),
                                ),
                                const Spacer(),
                                Text('₹${item.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.text)),
                              ]),
                            ])),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                              onPressed: () => cart.removeFromCart(item.cartItemId),
                            ),
                          ]),
                        );
                      },
                    ),
                  ),
                  // Bottom checkout bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4))],
                    ),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Total', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                        Text('₹${cart.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -1)),
                      ]),
                      if (auth.user != null) ...[
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Wallet balance', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          Text('₹${auth.user!.walletBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                            style: TextStyle(fontSize: 13, color: cart.total > auth.user!.walletBalance ? AppTheme.error : AppTheme.success, fontWeight: FontWeight.w600)),
                        ]),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (auth.user != null && cart.total <= auth.user!.walletBalance)
                              ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()))
                              : null,
                          child: auth.user != null && cart.total > auth.user!.walletBalance
                              ? const Text('Insufficient Balance')
                              : const Text('Proceed to Checkout', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ]),
                  ),
                ]),
    );
  }
}
