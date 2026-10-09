import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/models/product.dart';
import 'package:mecity_marketplace/providers/wishlist_provider.dart';
import 'package:mecity_marketplace/providers/cart_provider.dart';
import 'package:mecity_marketplace/providers/auth_provider.dart';
import 'package:mecity_marketplace/providers/shop_provider.dart';
import 'package:mecity_marketplace/services/whatsapp_service.dart';
import 'package:mecity_marketplace/screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isHorizontal;

  const ProductCard({
    super.key,
    required this.product,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isFav = wishlistProvider.isFavorite(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        width: isHorizontal ? 200 : double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack with Small Logo Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.65,
                    child: product.images.isNotEmpty && product.images.first.startsWith('http')
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => _buildImagePlaceholder(context),
                          )
                        : _buildImagePlaceholder(context),
                  ),
                ),

                // Small Vendor/Mecity Shop Logo Badge on Image
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: product.shopLogo.isNotEmpty && product.shopLogo.startsWith('http')
                          ? Image.network(
                              product.shopLogo,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => Icon(
                                Icons.storefront_rounded,
                                size: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : Icon(
                              Icons.storefront_rounded,
                              size: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                    ),
                  ),
                ),

                // Discount Badge
                if (product.discountPercent > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.discountPercent.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Wishlist Toggle Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => wishlistProvider.toggleFavorite(product),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? const Color(0xFFEF4444) : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details Area with Small Shop Logo & Title
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: Image.network(
                                product.shopLogo.isNotEmpty
                                    ? product.shopLogo
                                    : 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150',
                                width: 14,
                                height: 14,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, st) => Icon(
                                  Icons.store_rounded,
                                  size: 14,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                product.shopName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toString(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${product.reviewsCount})',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (product.originalPrice > product.discountPrice)
                                Text(
                                  currencyFormatter.format(product.originalPrice),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                currencyFormatter.format(product.discountPrice),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                final shopProvider = Provider.of<ShopProvider>(context, listen: false);
                                final shop = shopProvider.getShopById(product.shopId);
                                final sellerPhone = (shop != null && shop.phoneNumber.isNotEmpty)
                                    ? shop.phoneNumber
                                    : '9876543210';

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Opening WhatsApp...'),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Color(0xFF25D366),
                                  ),
                                );

                                await WhatsAppService().inquireAndOpenWhatsApp(
                                  sellerPhoneNumber: sellerPhone,
                                  buyerPhoneNumber: authProvider.apiUser?.phoneNumber ?? authProvider.user.phoneNumber,
                                  buyerName: authProvider.apiUser?.name ?? authProvider.user.name,
                                  productId: product.id,
                                  productName: product.name,
                                  productPrice: product.discountPrice.toInt(),
                                  originalPrice: product.originalPrice.toInt(),
                                  productUrl: 'https://marketplace.mecity.in/product/${product.id}',
                                  shopId: product.shopId,
                                  shopName: product.shopName.isNotEmpty ? product.shopName : (shop?.name ?? 'Seller'),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                cartProvider.addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} added to cart!'),
                                    duration: const Duration(seconds: 2),
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.add_shopping_cart_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.18),
            Theme.of(context).cardTheme.color ?? const Color(0xFF1E293B),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_rounded,
              size: 34,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 4),
            Text(
              product.category.isNotEmpty ? product.category : 'mecity item',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
