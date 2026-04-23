import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProductDetail(widget.productId);
    });
  }

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    try {
      await context.read<CartProvider>().addToCart(widget.productId, quantity: _qty);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to cart!'),
          backgroundColor: AppTheme.success,
          action: SnackBarAction(label: 'View Cart', textColor: Colors.white, onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CartScreen()));
          }),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProductsProvider>();
    final product = pp.selectedProduct;

    return Scaffold(
      backgroundColor: Colors.white,
      body: product == null && pp.loading
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? const Center(child: Text('Product not found'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 320,
                      pinned: true,
                      backgroundColor: Colors.white,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(product.imageUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: AppTheme.background, child: const Icon(Icons.image_outlined, size: 80, color: AppTheme.border))),
                            // Gradient overlay
                            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.white], stops: [0.6, 1.0]))),
                          ],
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to wishlist'))),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(product.category.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                          ),
                          const SizedBox(height: 12),
                          Text(product.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppTheme.text)),
                          const SizedBox(height: 8),
                          Row(children: [
                            ...List.generate(5, (i) => Icon(i < product.rating.floor() ? Icons.star : Icons.star_border, size: 16, color: Colors.amber)),
                            const SizedBox(width: 8),
                            Text('${product.rating} (${product.reviewCount} reviews)', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          ]),
                          const SizedBox(height: 16),
                          Text('₹${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.text, letterSpacing: -1)),
                          const SizedBox(height: 20),
                          const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text)),
                          const SizedBox(height: 8),
                          Text(product.description, style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.6)),
                          const SizedBox(height: 24),
                          // Stock
                          Row(children: [
                            const Icon(Icons.inventory_2_outlined, size: 18, color: AppTheme.textSecondary),
                            const SizedBox(width: 8),
                            Text('${product.stock} in stock', style: TextStyle(color: product.stock < 20 ? AppTheme.error : AppTheme.success, fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 24),
                          // Quantity selector
                          Row(children: [
                            const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(12)),
                              child: Row(children: [
                                IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: _qty > 1 ? () => setState(() => _qty--) : null),
                                Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                IconButton(icon: const Icon(Icons.add, size: 18), onPressed: _qty < product.stock ? () => setState(() => _qty++) : null),
                              ]),
                            ),
                          ]),
                          const SizedBox(height: 28),
                          // Add to cart button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: product.stock == 0 || _adding ? null : _addToCart,
                              child: _adding
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : product.stock == 0
                                      ? const Text('Out of Stock')
                                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                          Icon(Icons.shopping_bag_outlined, size: 20),
                                          SizedBox(width: 8),
                                          Text('Add to Cart', style: TextStyle(fontSize: 16)),
                                        ]),
                            ),
                          ),

                          // Related products
                          if (pp.related.isNotEmpty) ...[
                            const SizedBox(height: 36),
                            const Text('You may also like', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 240,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: pp.related.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (_, i) => SizedBox(
                                  width: 160,
                                  child: ProductCard(
                                    product: pp.related[i],
                                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: pp.related[i].id))),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ]),
                      ),
                    ),
                  ],
                ),
    );
  }
}
