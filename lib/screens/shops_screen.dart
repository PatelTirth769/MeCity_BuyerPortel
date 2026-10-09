import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/shop_provider.dart';
import 'package:mecity_marketplace/widgets/shop_card.dart';

class ShopsScreen extends StatelessWidget {
  const ShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Vendor Shops Directory'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => shopProvider.setSearchQuery(val),
              decoration: const InputDecoration(
                hintText: 'Search sellers, store names or locations...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: shopProvider.filteredShops.length,
              itemBuilder: (context, index) {
                final shop = shopProvider.filteredShops[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ShopCard(shop: shop),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
