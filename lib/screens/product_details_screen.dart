import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/models/product.dart';
import 'package:mecity_marketplace/providers/cart_provider.dart';
import 'package:mecity_marketplace/providers/wishlist_provider.dart';
import 'package:mecity_marketplace/providers/product_provider.dart';
import 'package:mecity_marketplace/providers/shop_provider.dart';
import 'package:mecity_marketplace/providers/auth_provider.dart';
import 'package:mecity_marketplace/services/whatsapp_service.dart';
import 'package:mecity_marketplace/screens/shop_details_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  late String _selectedColor;
  late String _selectedSize;
  bool _isWhatsAppLoading = false;
  final WhatsAppService _whatsAppService = WhatsAppService();

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.product.colors.isNotEmpty ? widget.product.colors.first : 'Default';
    _selectedSize = widget.product.sizes.isNotEmpty ? widget.product.sizes.first : 'Standard';
  }

  Future<void> _handleWhatsAppInquiry() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final shop = shopProvider.getShopById(widget.product.shopId);

    String sellerPhone = shop?.phoneNumber ?? '';
    if (sellerPhone.isEmpty) {
      sellerPhone = '9876543210';
    }

    setState(() => _isWhatsAppLoading = true);

    try {
      final buyerPhone = authProvider.apiUser?.phoneNumber ?? authProvider.user.phoneNumber;
      final buyerName = authProvider.apiUser?.name ?? authProvider.user.name;

      final response = await _whatsAppService.inquireAndOpenWhatsApp(
        sellerPhoneNumber: sellerPhone,
        buyerPhoneNumber: buyerPhone,
        buyerName: buyerName,
        productId: widget.product.id,
        productName: widget.product.name,
        productPrice: widget.product.discountPrice.toInt(),
        originalPrice: widget.product.originalPrice.toInt(),
        productUrl: 'https://marketplace.mecity.in/product/${widget.product.id}',
        shopId: widget.product.shopId,
        shopName: widget.product.shopName.isNotEmpty ? widget.product.shopName : (shop?.name ?? 'Seller'),
      );

      if (mounted) {
        if (response.success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening WhatsApp inquiry chat...'),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFF25D366),
            ),
          );
        } else if (response.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message!)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isWhatsAppLoading = false);
      }
    }
  }

  void _showAddReviewDialog(BuildContext context) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Write a Customer Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rate this product:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [1, 2, 3, 4, 5].map((star) {
                return IconButton(
                  icon: Icon(
                    star <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                  onPressed: () {
                    rating = star.toDouble();
                    (ctx as Element).markNeedsBuild();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Share your experience with this product...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.isNotEmpty) {
                final newReview = Review(
                  id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
                  userName: 'Rudra Pratap',
                  userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                  rating: rating,
                  comment: commentController.text,
                  createdAt: DateTime.now(),
                );
                Provider.of<ProductProvider>(context, listen: false).addReview(widget.product.id, newReview);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review submitted successfully! Thank you!')),
                );
              }
            },
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final isFav = wishlistProvider.isFavorite(widget.product.id);

    final shop = shopProvider.getShopById(widget.product.shopId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? const Color(0xFFEF4444) : null,
            ),
            onPressed: () => wishlistProvider.toggleFavorite(widget.product),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Image View
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: Stack(
                      children: [
                        widget.product.images.isNotEmpty &&
                                _selectedImageIndex < widget.product.images.length &&
                                widget.product.images[_selectedImageIndex].startsWith('http')
                            ? Image.network(
                                widget.product.images[_selectedImageIndex],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (ctx, err, st) => _buildImagePlaceholder(context),
                              )
                            : _buildImagePlaceholder(context),
                        if (widget.product.discountPercent > 0)
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${widget.product.discountPercent.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Image Thumbnails Row
                  if (widget.product.images.length > 1)
                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(10),
                        itemCount: widget.product.images.length,
                        itemBuilder: (context, idx) {
                          final isSel = _selectedImageIndex == idx;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedImageIndex = idx),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel ? Theme.of(context).primaryColor : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(widget.product.images[idx], fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shop badge & Tag
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.product.category,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.inventory_2_rounded, size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Text(
                              'In Stock (${widget.product.stock})',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          widget.product.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // Rating & Reviews Summary
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.product.rating.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${widget.product.reviewsCount} Ratings & Reviews',
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Price & Savings Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        currencyFormatter.format(widget.product.discountPrice),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (widget.product.originalPrice > widget.product.discountPrice)
                                        Text(
                                          currencyFormatter.format(widget.product.originalPrice),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (widget.product.savings > 0)
                                    Text(
                                      'You Save: ${currencyFormatter.format(widget.product.savings)}',
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Color / Variant Selector
                        if (widget.product.colors.isNotEmpty) ...[
                          const Text('Select Variant / Color:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: widget.product.colors.map((c) {
                              final isSel = _selectedColor == c;
                              return ChoiceChip(
                                label: Text(c),
                                selected: isSel,
                                onSelected: (sel) => setState(() => _selectedColor = c),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Quantity Selector
                        Row(
                          children: [
                            const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                  ),
                                  Text(
                                    '$_quantity',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: () => setState(() => _quantity++),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Shop Info Card
                        if (shop != null)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(shop.logo),
                                  radius: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shop.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        'Verified Shop • ⭐ ${shop.rating}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: _isWhatsAppLoading ? null : _handleWhatsAppInquiry,
                                        icon: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 22),
                                        tooltip: 'WhatsApp Shop',
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (ctx) => ShopDetailsScreen(shop: shop),
                                            ),
                                          );
                                        },
                                        child: const Text('Visit Shop'),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Product Description
                        const Text('Product Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description,
                          style: TextStyle(
                            height: 1.5,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Reviews Section Header & Add Review Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Customer Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              icon: const Icon(Icons.rate_review_rounded, size: 16),
                              label: const Text('Add Review'),
                              onPressed: () => _showAddReviewDialog(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (widget.product.reviews.isEmpty)
                          const Text('No reviews yet. Be the first to review!')
                        else
                          ...widget.product.reviews.map((rev) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundImage: rev.userAvatar.isNotEmpty && rev.userAvatar.startsWith('http')
                                              ? NetworkImage(rev.userAvatar)
                                              : null,
                                          child: (rev.userAvatar.isEmpty || !rev.userAvatar.startsWith('http'))
                                              ? Text(
                                                  rev.userName.isNotEmpty ? rev.userName[0].toUpperCase() : 'U',
                                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                )
                                              : null,
                                        ),

                                        const SizedBox(width: 8),
                                        Text(rev.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                            Text(' ${rev.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      rev.comment,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // WhatsApp Direct Inquiry Button
                InkWell(
                  onTap: _isWhatsAppLoading ? null : _handleWhatsAppInquiry,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isWhatsAppLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'WhatsApp',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      cartProvider.addToCart(
                        widget.product,
                        quantity: _quantity,
                        color: _selectedColor,
                        size: _selectedSize,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${widget.product.name} added to cart!')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Add to Cart', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isWhatsAppLoading ? null : _handleWhatsAppInquiry,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Interested ?', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            Theme.of(context).primaryColor.withOpacity(0.15),
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
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.8),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.category.isNotEmpty ? widget.product.category : 'mecity item',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor.withOpacity(0.7),
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
