import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/models/category.dart';
import 'package:mecity_marketplace/providers/category_provider.dart';
import 'package:mecity_marketplace/providers/product_provider.dart';
import 'package:mecity_marketplace/widgets/product_card.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryDetailsScreen({super.key, required this.category});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.selectCategory(widget.category.title);
      productProvider.selectSubCategory(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final subCategories = categoryProvider.getSubCategoriesByCategoryId(widget.category.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Banner with Search Bar overlapping
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner Image / Gradient
                Container(
                  height: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: widget.category.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(widget.category.imageUrl),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.5),
                              BlendMode.darken,
                            ),
                          )
                        : null,
                    gradient: widget.category.imageUrl.isEmpty
                        ? LinearGradient(
                            colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.category.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                // Overlapping Search Bar
                Positioned(
                  bottom: -20,
                  left: 40,
                  right: 40,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search in ${widget.category.title}...',
                        hintStyle: const TextStyle(fontSize: 13),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onChanged: (val) {
                        productProvider.setSearchQuery(val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40), // Space for overlapping search bar

            // 2. SubCategories Horizontal List (Circles)
            if (subCategories.isNotEmpty) ...[
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: subCategories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildSubCategoryCircle(
                        context: context,
                        title: 'All',
                        imageUrl: '',
                        icon: Icons.apps_rounded,
                        isSelected: productProvider.selectedSubCategory == null,
                        onTap: () => productProvider.selectSubCategory(null),
                      );
                    }
                    final subCat = subCategories[index - 1];
                    return _buildSubCategoryCircle(
                      context: context,
                      title: subCat.name,
                      imageUrl: subCat.imageUrl,
                      icon: Icons.category_rounded,
                      isSelected: productProvider.selectedSubCategory == subCat.name,
                      onTap: () => productProvider.selectSubCategory(subCat.name),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
            ],

            // 3. Products Grid Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                productProvider.selectedSubCategory == null
                    ? 'Top ${widget.category.title}'
                    : 'Top ${productProvider.selectedSubCategory}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // 4. Products Grid
            productProvider.filteredProducts.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No products found in this category.'),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58,
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
        ),
      ),
    );
  }

  Widget _buildSubCategoryCircle({
    required BuildContext context,
    required String title,
    required String imageUrl,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(3), // Space for selection border
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardTheme.color,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Icon(icon, color: Colors.grey),

                        )
                      : Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
