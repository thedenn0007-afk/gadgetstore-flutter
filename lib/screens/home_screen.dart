import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts();
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _tab,
        children: const [
          _ShopTab(),
          CartScreen(),
          OrdersScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) {
          setState(() => _tab = i);
          if (i == 1) context.read<CartProvider>().loadCart();
          if (i == 2) context.read<OrdersProvider>().loadOrders();
        },
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Consumer<CartProvider>(builder: (_, cart, __) => Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_bag_outlined),
            )),
            selectedIcon: const Icon(Icons.shopping_bag),
            label: 'Cart',
          ),
          const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          const NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _ShopTab extends StatefulWidget {
  const _ShopTab();
  @override
  State<_ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<_ShopTab> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _search() {
    context.read<ProductsProvider>().loadProducts(search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductsProvider>();
    final auth = context.watch<AuthProvider>();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.white,
          title: Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.headphones, color: Colors.white, size: 14)),
            const SizedBox(width: 8),
            const Text('GadgetStore'),
          ]),
          actions: [
            if (auth.user != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text('₹${(auth.user!.walletBalance / 1000).toStringAsFixed(0)}k', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                  ]),
                )),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                controller: _searchCtrl,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Search earbuds, watches...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); _search(); })
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
        ),

        // Categories
        SliverToBoxAdapter(
          child: SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              children: [
                CategoryChip(label: 'All', isSelected: products.selectedCategory.isEmpty, onTap: () => products.setCategory('')),
                ...AppConstants.categories.map((c) => CategoryChip(
                  label: c['label']!,
                  icon: c['icon']!,
                  isSelected: products.selectedCategory == c['id'],
                  onTap: () => products.setCategory(c['id']!),
                )),
              ],
            ),
          ),
        ),

        // Products grid or loading/empty
        if (products.loading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        else if (products.products.isEmpty)
          const SliverFillRemaining(child: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Color(0xFFE5E5EA)),
              SizedBox(height: 16),
              Text('No products found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF86868B))),
            ],
          )))
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => ProductCard(
                  product: products.products[i],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: products.products[i].id))),
                ),
                childCount: products.products.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.72,
              ),
            ),
          ),
      ],
    );
  }
}
