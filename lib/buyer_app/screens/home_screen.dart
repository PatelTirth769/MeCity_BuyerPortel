import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/product_provider.dart';
import 'package:mecity_marketplace/providers/shop_provider.dart';
import 'package:mecity_marketplace/providers/auth_provider.dart';
import 'package:mecity_marketplace/data/mock_data.dart';
import 'package:mecity_marketplace/models/category.dart';
import 'package:mecity_marketplace/providers/category_provider.dart';
import 'package:mecity_marketplace/widgets/location_header.dart';
import 'package:mecity_marketplace/widgets/custom_search_bar.dart';
import 'package:mecity_marketplace/widgets/category_card.dart';
import 'package:mecity_marketplace/widgets/product_card.dart';
import 'package:mecity_marketplace/widgets/shop_card.dart';
import 'package:mecity_marketplace/widgets/countdown_timer_widget.dart';
import 'package:mecity_marketplace/widgets/filter_bottom_sheet.dart';
import 'package:mecity_marketplace/widgets/mecity_logo.dart';
import 'package:mecity_marketplace/buyer_app/screens/category_details_screen.dart';
import 'package:mecity_marketplace/buyer_app/screens/store_list_screen.dart';
import 'package:mecity_marketplace/buyer_app/screens/products_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    Future<void> handleRefresh() async {
      await Future.wait([
        productProvider.fetchProductsFromApi(),
        categoryProvider.fetchCategoriesFromApi(),
        shopProvider.fetchShopsFromApi(),
        authProvider.fetchUserProfile(),
        authProvider.fetchAndSetLiveGpsLocation(),
      ]);
    }

    return RefreshIndicator(
      onRefresh: handleRefresh,
      color: Theme.of(context).primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar & Location
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mecity App Branding Title Bar
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const MecityLogo(size: 38),
                      const SizedBox(width: 10),
                      const Text(
                        'mecity',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const LocationHeader(),
                const SizedBox(height: 8),
                CustomSearchBar(
                  onFilterTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const FilterBottomSheet(),
                    );
                  },
                ),
              ],
            ),
          ),

          if (productProvider.searchQuery.trim().isNotEmpty) ...[
            _buildSearchResults(context, productProvider),
          ] else ...[
            // Hero Banner Slider
            Container(
              height: 195,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 180,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'FESTIVE OFFER ⚡',
                          style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Up to 60% OFF\non Smart Home & Tech',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          productProvider.selectCategory('Electronics');
                        },
                        child: const Text('Shop Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Category Quick Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    productProvider.selectCategory('All');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 110,
            child: categoryProvider.isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categoryProvider.categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSel = productProvider.selectedCategory == 'All';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: CategoryCard(
                            category: CategoryModel(
                              id: 'all',
                              title: 'All Items',
                              iconName: 'all',
                              icon: Icons.grid_view_rounded,
                              imageUrl: '',
                              subcategories: [],
                            ),
                            isSelected: isSel,
                            onTap: () => productProvider.selectCategory('All'),
                          ),
                        );
                      }
                      final cat = categoryProvider.categories[index - 1];
                      final isSel = productProvider.selectedCategory == cat.title;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: CategoryCard(
                          category: cat,
                          isSelected: isSel,
                          onTap: () {
                            productProvider.selectCategory(cat.title);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailsScreen(category: cat),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),

          // Live Flash Sale Banner with Timer
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: Colors.amber, size: 22),
                          SizedBox(width: 4),
                          Text(
                            'FLASH DEALS',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Limited time crazy prices',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: CountdownTimerWidget(targetDate: MockData.megaEvent.endDate),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Best Deals Section (Horizontal Scroll)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Best Deals for You',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductsScreen(),
                      ),
                    );
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 310,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: productProvider.bestDeals.length,
              itemBuilder: (context, index) {
                final product = productProvider.bestDeals[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: ProductCard(product: product, isHorizontal: true),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Multi-Vendor Shops Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Explore Local Shops & Sellers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoreListScreen(),
                      ),
                    );
                  },
                  child: const Text('All Shops'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: shopProvider.shops.length,
              itemBuilder: (context, index) {
                final shop = shopProvider.shops[index];
                return ShopCard(shop: shop);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Featured Products Grid Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      productProvider.selectedCategory == 'All'
                          ? 'Featured Products'
                          : productProvider.selectedCategory,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (productProvider.selectedCategory != 'All') ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => productProvider.selectCategory('All'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Clear',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.close_rounded, size: 14, color: Theme.of(context).primaryColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${productProvider.filteredProducts.length} items',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (productProvider.isLoadingApi && productProvider.products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (productProvider.filteredProducts.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 10),
                  Text(
                    'No products found in "${productProvider.selectedCategory}"',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => productProvider.resetFilters(),
                    child: const Text('View All Products'),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 1200
                    ? 5
                    : MediaQuery.of(context).size.width > 900
                        ? 4
                        : MediaQuery.of(context).size.width > 600
                            ? 3
                            : 2,
                childAspectRatio: MediaQuery.of(context).size.width > 900
                    ? 0.75
                    : MediaQuery.of(context).size.width > 600
                        ? 0.68
                        : 0.58,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: productProvider.filteredProducts.length,
              itemBuilder: (context, index) {
                final product = productProvider.filteredProducts[index];
                return ProductCard(product: product);
              },
            ),
          ],
        ],
      ),
    ),
    );
  }

  Widget _buildSearchResults(BuildContext context, ProductProvider productProvider) {
    final results = productProvider.filteredProducts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    children: [
                      const TextSpan(text: 'Results for "'),
                      TextSpan(
                        text: productProvider.searchQuery,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      TextSpan(
                        text: '" (${results.length})',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => productProvider.setSearchQuery(''),
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (results.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'No products found matching "${productProvider.searchQuery}"',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try checking for typos or use different search keywords.',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.setSearchQuery(''),
                    child: const Text('Clear Search & View All'),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 1200
                    ? 5
                    : MediaQuery.of(context).size.width > 900
                        ? 4
                        : MediaQuery.of(context).size.width > 600
                            ? 3
                            : 2,
                childAspectRatio: MediaQuery.of(context).size.width > 900
                    ? 0.75
                    : MediaQuery.of(context).size.width > 600
                        ? 0.68
                        : 0.58,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return ProductCard(product: results[index]);
              },
            ),
        ],
      ),
    );
  }
}
