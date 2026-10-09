import 'package:flutter/material.dart';
import 'package:mecity_marketplace/models/shop.dart';
import 'package:mecity_marketplace/screens/shop_details_screen.dart';

class ShopCard extends StatelessWidget {
  final ShopModel shop;

  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopDetailsScreen(shop: shop),
          ),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner & Logo
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 2.5,
                    child: Image.network(
                      shop.banner,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(color: Colors.indigo.shade900),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: 14,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: shop.logo.isNotEmpty && shop.logo.startsWith('http')
                          ? Image.network(
                              shop.logo,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => Container(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Icon(Icons.storefront_rounded, color: Theme.of(context).primaryColor, size: 24),
                              ),
                            )
                          : Container(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Icon(Icons.storefront_rounded, color: Theme.of(context).primaryColor, size: 24),
                            ),
                    ),

                  ),
                ),
                if (shop.isVerified)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Verified Seller',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shop.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 4),
                          Text(
                            shop.rating.toString(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' (${shop.reviewsCount})',
                            style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        ],
                      ),
                      Text(
                        '${shop.totalProducts} Items',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
