import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/category_selector.dart';
import '../models/category.dart' as models;
import '../providers/category_provider.dart';

class CategorySelectorWidget extends StatefulWidget {
  final String? selectedCategoryId;
  final Function(String) onCategorySelected;
  final String? errorText;
  final bool showSearch;

  const CategorySelectorWidget({
    super.key,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.errorText,
    this.showSearch = false,
  });

  @override
  State<CategorySelectorWidget> createState() => _CategorySelectorWidgetState();
}

class _CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  String? _searchQuery;
  List<models.Category> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    final categoryProvider = context.read<CategoryProvider>();
    categoryProvider.loadCategories();
  }

  void _filterCategories(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCategories = context.read<CategoryProvider>().categories;
      } else {
        _filteredCategories = context
            .read<CategoryProvider>()
            .categories
            .where((category) =>
                category.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        if (categoryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoryProvider.error != null) {
          return Center(
            child: Text(
              'Error: ${categoryProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final categories = _searchQuery != null
            ? _filteredCategories
            : categoryProvider.categories;

        return CategorySelector(
          selectedCategoryId: widget.selectedCategoryId,
          onCategorySelected: widget.onCategorySelected,
          errorText: widget.errorText,
          showSearch: widget.showSearch,
          searchQuery: _searchQuery ?? '',
        );
      },
    );
  }
} 