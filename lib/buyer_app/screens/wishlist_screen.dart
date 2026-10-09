import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/wishlist_provider.dart';
import 'package:mecity_marketplace/providers/product_provider.dart';
import 'package:mecity_marketplace/widgets/product_card.dart';
import 'package:mecity_marketplace/buyer_app/screens/main_navigation_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
              );
            }
          },
        ),
        title: Text('Wishlist (${wishlistProvider.count} Saved)'),
        actions: [
          if (wishlistProvider.count > 0)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => wishlistProvider.clearWishlist(),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final productProvider = Provider.of<ProductProvider>(context, listen: false);
          await productProvider.fetchProductsFromApi();
        },
        color: Theme.of(context).primaryColor,
        child: wishlistProvider.wishlist.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text(
                          'Your wishlist is empty!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('Save items you love by tapping the heart icon.'),
                      ],
                    ),
                  ),
                ],
              )
            : GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: wishlistProvider.wishlist.length,
                itemBuilder: (context, index) {
                  final product = wishlistProvider.wishlist[index];
                  return ProductCard(product: product);
                },
              ),
      ),
    );
  }
}
