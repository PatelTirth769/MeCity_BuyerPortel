import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/cart_provider.dart';
import 'package:mecity_marketplace/providers/wishlist_provider.dart';
import 'package:mecity_marketplace/buyer_app/screens/wishlist_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${cartProvider.itemCount} Items)'),
        actions: [
          if (cartProvider.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => cartProvider.clearCart(),
            ),
        ],
      ),
      body: cartProvider.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Your shopping cart is empty!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Explore catalog and add awesome products!'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.product.images.isNotEmpty ? item.product.images.first : '',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Variant: ${item.selectedColor} / ${item.selectedSize}',
                                    style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    currencyFormatter.format(item.product.discountPrice),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                                  onPressed: () => cartProvider.removeFromCart(item),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => cartProvider.updateQuantity(item, item.quantity - 1),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(Icons.remove, size: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => cartProvider.updateQuantity(item, item.quantity + 1),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(Icons.add, size: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Coupon & Total Summary Panel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Promo coupon box
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Enter Promo Code (e.g. MECITY10)',
                                suffixIcon: cartProvider.appliedCoupon != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () => cartProvider.removeCoupon(),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_couponController.text.isNotEmpty) {
                                final success = cartProvider.applyCoupon(_couponController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Coupon applied! Discount updated.'
                                          : 'Invalid promo code! Try MECITY10 or FLASH20',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      if (cartProvider.appliedCoupon != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Active Coupon: ${cartProvider.appliedCoupon}',
                            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),

                      const SizedBox(height: 14),

                      // Price Breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:'),
                          Text(currencyFormatter.format(cartProvider.subtotal)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Shipping Fee:'),
                          Text(
                            cartProvider.shippingFee == 0 ? 'FREE' : currencyFormatter.format(cartProvider.shippingFee),
                            style: TextStyle(
                              color: cartProvider.shippingFee == 0 ? const Color(0xFF10B981) : null,
                              fontWeight: cartProvider.shippingFee == 0 ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                      if (cartProvider.discountAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Discount:'),
                            Text(
                              '- ${currencyFormatter.format(cartProvider.discountAmount)}',
                              style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormatter.format(cartProvider.totalAmount),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.storefront_rounded),
                          label: const Text('Meet to Shopkeeper'),
                          onPressed: () {
                            // Move all cart items to Wishlist
                            for (final item in cartProvider.items) {
                              if (!wishlistProvider.isFavorite(item.product.id)) {
                                wishlistProvider.toggleFavorite(item.product);
                              }
                            }
                            // Clear Cart
                            cartProvider.clearCart();

                            // Show notification SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Items saved to Wishlist! Explore verified local stores.'),
                                duration: Duration(seconds: 3),
                              ),
                            );

                            // Navigate to Wishlist Screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const WishlistScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
