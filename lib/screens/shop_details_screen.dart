import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/models/shop.dart';
import 'package:mecity_marketplace/models/event.dart';
import 'package:mecity_marketplace/providers/product_provider.dart';
import 'package:mecity_marketplace/models/product.dart';
import 'package:mecity_marketplace/widgets/product_card.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';
import 'package:mecity_marketplace/services/whatsapp_service.dart';

class ShopDetailsScreen extends StatefulWidget {
  final ShopModel shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> with SingleTickerProviderStateMixin {
  late ShopModel _currentShop;
  List<EventModel> _shopEvents = [];
  bool _isLoading = true;
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _currentShop = widget.shop;
    _tabController = TabController(length: 5, vsync: this);
    _fetchShopDetailsAndEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchShopDetailsAndEvents() async {
    try {
      // Fetch full shop details to get reviews, specific addresses etc.
      final shopResp = await _apiClient.get('${ApiEndpoints.getShopInfo}/${_currentShop.id}');
      if (shopResp is Map<String, dynamic> && shopResp['shop'] != null) {
        setState(() {
          _currentShop = ShopModel.fromApiJson(shopResp['shop']);
        });
      }

      // Fetch shop events
      final eventsResp = await _apiClient.get('${ApiEndpoints.getAllEventsForShop}/${_currentShop.id}');
      if (eventsResp is Map<String, dynamic> && eventsResp['events'] != null) {
        setState(() {
          _shopEvents = (eventsResp['events'] as List).map((e) => EventModel.fromApiJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching shop details/events: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopProducts = Provider.of<ProductProvider>(context)
        .products
        .where((p) => p.shopId == _currentShop.id || p.shopName == _currentShop.name)
        .toList();

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              title: innerBoxIsScrolled
                  ? Text(_currentShop.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Banner Image
                    Image.network(
                      _currentShop.banner,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(color: Colors.indigo.shade600),
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // Logo and Details overlapping
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _currentShop.logo.isNotEmpty
                                  ? Image.network(_currentShop.logo, fit: BoxFit.cover)
                                  : const Icon(Icons.store, size: 40, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _currentShop.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (_currentShop.isVerified) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.verified, color: Colors.blueAccent, size: 18),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentShop.description.isNotEmpty ? _currentShop.description : 'Premium quality products and exceptional service.',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(icon: Icon(Icons.inventory_2_outlined, size: 18), text: 'Products'),
                    Tab(icon: Icon(Icons.bolt, size: 18), text: 'Events'),
                    Tab(icon: Icon(Icons.chat_bubble_outline, size: 18), text: 'Reviews'),
                    Tab(icon: Icon(Icons.star_outline, size: 18), text: 'Shop Rating'),
                    Tab(icon: Icon(Icons.info_outline, size: 18), text: 'About Shop'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildProductsTab(shopProducts),
                  _buildEventsTab(),
                  _buildReviewsTab(),
                  _buildShopRatingTab(),
                  _buildAboutShopTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildProductsTab(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No products listed yet.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }

  Widget _buildEventsTab() {
    if (_shopEvents.isEmpty) {
      return const Center(child: Text('No Events have for this shop!'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _shopEvents.length,
      itemBuilder: (context, index) {
        final event = _shopEvents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: event.bannerUrl.isNotEmpty
                    ? Image.network(event.bannerUrl, height: 140, width: double.infinity, fit: BoxFit.cover)
                    : Container(height: 140, color: Colors.grey[300]),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('No reviews yet for this shop.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildShopRatingTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Shop Experience Ratings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.star_border, size: 16, color: Colors.white),
                label: const Text('Rate This Shop', style: TextStyle(color: Colors.white, fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _currentShop.shopRatings.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No shop ratings yet. Be the first to rate!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _currentShop.shopRatings.length,
                    itemBuilder: (context, index) {
                      final review = _currentShop.shopRatings[index];
                      final user = review['user'] ?? {};
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundImage: user['avatar'] != null ? NetworkImage(user['avatar'].toString()) : null,
                          child: user['avatar'] == null ? const Icon(Icons.person) : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(user['name'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold))),
                            Row(
                              children: List.generate(5, (starIdx) {
                                return Icon(
                                  starIdx < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                  size: 14,
                                  color: Colors.amber,
                                );
                              }),
                            ),
                          ],
                        ),
                        subtitle: Text(review['comment'] ?? ''),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutShopTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            title: 'Business Identity',
            icon: Icons.storefront_outlined,
            children: [
              _buildInfoRow('SHOP OFFICIAL NAME', _currentShop.name),
              _buildInfoRow('SHOP OWNER', _currentShop.ownerName),
              _buildInfoRow('REGISTRATION STATUS', _currentShop.isVerified ? 'Verified Business' : 'Pending', isStatus: true),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Registered Address',
            icon: Icons.info_outline,
            children: [
              _buildInfoRow('CITY & STATE', '${_currentShop.city}, ${_currentShop.state}'),
              _buildInfoRow('FULL STREET ADDRESS', _currentShop.address),
              _buildInfoRow('ZIP CODE', _currentShop.zipCode),
              _buildInfoRow('CONTACT INFORMATION', _currentShop.phoneNumber, isPhone: true),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Physical Verification',
            icon: Icons.camera_alt_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SHOP FRONT', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            image: _currentShop.shopFrontPhoto.isNotEmpty
                                ? DecorationImage(image: NetworkImage(_currentShop.shopFrontPhoto), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _currentShop.shopFrontPhoto.isEmpty ? const Center(child: Icon(Icons.image, color: Colors.grey)) : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('OWNER @ COUNTER', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            image: _currentShop.ownerAtCounterPhoto.isNotEmpty
                                ? DecorationImage(image: NetworkImage(_currentShop.ownerAtCounterPhoto), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _currentShop.ownerAtCounterPhoto.isEmpty ? const Center(child: Icon(Icons.image, color: Colors.grey)) : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 12),
                  const SizedBox(width: 4),
                  Text(value, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          else if (isPhone)
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: Colors.purple),
                const SizedBox(width: 4),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                if (value.trim().isNotEmpty)
                  InkWell(
                    onTap: () {
                      final phone = value.replaceAll(RegExp(r'\D'), '');
                      final formatted = phone.length == 10 ? '91$phone' : phone;
                      final encoded = Uri.encodeComponent('Hello ${_currentShop.name}, I am contacting you via Mecity.');
                      WhatsAppService().launchWhatsAppUrl(
                        'https://wa.me/$formatted?text=$encoded',
                        appUrlString: 'whatsapp://send?phone=$formatted&text=$encoded',
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_rounded, size: 12, color: Color(0xFF25D366)),
                          SizedBox(width: 4),
                          Text(
                            'WhatsApp',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF25D366),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          else
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
