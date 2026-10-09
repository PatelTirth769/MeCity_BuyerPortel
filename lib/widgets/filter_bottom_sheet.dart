import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/product_provider.dart';
import 'package:mecity_marketplace/providers/category_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  static const double _minPrice = 0.0;
  static const double _maxPrice = 200000.0;

  late RangeValues _tempRange;
  late String _tempSort;
  late String _tempCategory;
  late double _tempRating;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final start = provider.priceRange.start.clamp(_minPrice, _maxPrice);
    final end = provider.priceRange.end.clamp(start, _maxPrice);
    _tempRange = RangeValues(start, end);
    _tempSort = provider.sortBy;
    _tempCategory = provider.selectedCategory;
    _tempRating = provider.minRating;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final safeStart = _tempRange.start.clamp(_minPrice, _maxPrice);
    final safeEnd = _tempRange.end.clamp(safeStart, _maxPrice);
    final safeValues = RangeValues(safeStart, safeEnd);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Sort Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.resetFilters();
                      setState(() {
                        _tempRange = const RangeValues(_minPrice, _maxPrice);
                        _tempCategory = 'All';
                        _tempSort = 'Popularity';
                        _tempRating = 0.0;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Reset All'),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              // Category selector
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _tempCategory == 'All',
                      onSelected: (sel) => setState(() => _tempCategory = 'All'),
                    ),
                    ...categoryProvider.categories.map((c) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: FilterChip(
                            label: Text(c.title),
                            selected: _tempCategory == c.title,
                            onSelected: (sel) =>
                                setState(() => _tempCategory = c.title),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Sort Options
              const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Popularity', 'Price: Low to High', 'Price: High to Low', 'Top Rated'].map((sort) {
                  final isSel = _tempSort == sort;
                  return ChoiceChip(
                    label: Text(sort),
                    selected: isSel,
                    onSelected: (sel) => setState(() => _tempSort = sort),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Price Range Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '₹${safeValues.start.round()} - ₹${safeValues.end.round()}',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              RangeSlider(
                values: safeValues,
                min: _minPrice,
                max: _maxPrice,
                divisions: 40,
                onChanged: (vals) => setState(() => _tempRange = vals),
              ),
              const SizedBox(height: 20),
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    provider.selectCategory(_tempCategory);
                    provider.setSortBy(_tempSort);
                    provider.setPriceRange(_tempRange);
                    provider.setMinRating(_tempRating);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
