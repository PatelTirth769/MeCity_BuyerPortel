import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/product_provider.dart';
import 'package:mecity_marketplace/widgets/filter_bottom_sheet.dart';

class CustomSearchBar extends StatefulWidget {
  final VoidCallback? onFilterTap;
  final String hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final bool autofocus;

  const CustomSearchBar({
    super.key,
    this.onFilterTap,
    this.hintText = 'Search products, shops, categories...',
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.autofocus = false,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInternalController) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (_controller.text != productProvider.searchQuery) {
        _controller.text = productProvider.searchQuery;
      }
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _defaultOpenFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // Keep controller in sync if productProvider was cleared from elsewhere
    if (_isInternalController && _controller.text != productProvider.searchQuery) {
      _controller.text = productProvider.searchQuery;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    final hasText = _controller.text.isNotEmpty || productProvider.searchQuery.isNotEmpty;

    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasText
              ? Theme.of(context).primaryColor.withOpacity(0.5)
              : Theme.of(context).dividerColor.withOpacity(0.15),
          width: hasText ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            color: hasText
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyMedium?.color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              onTap: widget.onTap,
              onChanged: (val) {
                productProvider.setSearchQuery(val);
                if (widget.onChanged != null) {
                  widget.onChanged!(val);
                }
              },
              onSubmitted: (val) {
                productProvider.setSearchQuery(val);
                if (widget.onSubmitted != null) {
                  widget.onSubmitted!(val);
                }
              },
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (hasText)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              splashRadius: 18,
              onPressed: () {
                _controller.clear();
                productProvider.setSearchQuery('');
                if (widget.onChanged != null) {
                  widget.onChanged!('');
                }
              },
            ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (widget.onFilterTap != null) {
                    widget.onFilterTap!();
                  } else {
                    _defaultOpenFilter(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
