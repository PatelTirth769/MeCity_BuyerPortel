import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/product_provider.dart';
import 'package:mecity_marketplace/providers/category_provider.dart';
import 'package:mecity_marketplace/widgets/custom_search_bar.dart';
import 'package:mecity_marketplace/widgets/product_card.dart';
import 'package:mecity_marketplace/widgets/filter_bottom_sheet.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Sync Products from Web API',
            onPressed: () {
              productProvider.fetchProductsFromApi();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fetching live products from Web API...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
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
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomSearchBar(
              onFilterTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const FilterBottomSheet(),
                );
              },
            ),
          ),

          // Categories horizontal scroll chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('All Categories'),
                    selected: productProvider.selectedCategory == 'All',
                    onSelected: (sel) => productProvider.selectCategory('All'),
                  ),
                ),
                ...categoryProvider.categories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      avatar: c.imageUrl.isNotEmpty && c.imageUrl.startsWith('http')
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(c.imageUrl),
                              radius: 12,
                            )
                          : Icon(c.icon, size: 16),
                      label: Text(c.title),
                      selected: productProvider.selectedCategory == c.title,
                      onSelected: (sel) => productProvider.selectCategory(c.title),

                    ),
                  ),
                ),
              ],
            ),
          ),
          // Subcategories horizontal scroll chips (if a category is selected and has subcategories)
          if (productProvider.selectedCategory != 'All')
            Builder(
              builder: (context) {
                final matchingCats = categoryProvider.categories.where((c) => c.title.toLowerCase() == productProvider.selectedCategory.toLowerCase());
                if (matchingCats.isNotEmpty) {
                  final cat = matchingCats.first;
                  final realSubCats = categoryProvider.getSubCategoriesByCategoryId(cat.id);
                  final List<String> subcatNames = realSubCats.isNotEmpty 
                      ? realSubCats.map((s) => s.name).toList() 
                      : cat.subcategories;

                  if (subcatNames.isNotEmpty) {
                    return Container(
                      height: 38,
                      margin: const EdgeInsets.only(top: 8),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: const Text('All'),
                              selected: productProvider.selectedSubCategory == null || productProvider.selectedSubCategory == 'All',
                              onSelected: (sel) => productProvider.selectSubCategory('All'),
                              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                            ),
                          ),
                          ...subcatNames.map(
                          (sub) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(sub),
                              selected: productProvider.selectedSubCategory == sub,
                              onSelected: (sel) => productProvider.selectSubCategory(sub),
                              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } // End of subcatNames.isNotEmpty
                } // End of matchingCats.isNotEmpty
                return const SizedBox.shrink();
              },
            ),
          const SizedBox(height: 10),

          // Active filter info bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${productProvider.filteredProducts.length} Items Found',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Text('Sort: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    DropdownButton<String>(
                      value: productProvider.sortBy,
                      underline: const SizedBox(),
                      isDense: true,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                      items: ['Popularity', 'Price: Low to High', 'Price: High to Low', 'Top Rated'].map((sort) {
                        return DropdownMenuItem(value: sort, child: Text(sort));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) productProvider.setSortBy(val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Product Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => productProvider.fetchProductsFromApi(),
              child: productProvider.filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'No products match your search/filters',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => productProvider.resetFilters(),
                            child: const Text('Reset All Filters'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
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
            ),
          ),
        ],
      ),
    );
  }
}
