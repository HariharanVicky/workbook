import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategoryId;
  final Function(String) onCategorySelected;
  final String? errorText;
  final bool showSearch;
  final String searchQuery;

  const CategorySelector({
    super.key,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.errorText,
    this.showSearch = false,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual categories from a provider
    final categories = [
      {'id': 'food', 'name': 'Food & Dining'},
      {'id': 'transport', 'name': 'Transportation'},
      {'id': 'shopping', 'name': 'Shopping'},
      {'id': 'entertainment', 'name': 'Entertainment'},
      {'id': 'bills', 'name': 'Bills & Utilities'},
      {'id': 'health', 'name': 'Health & Medical'},
      {'id': 'travel', 'name': 'Travel'},
      {'id': 'education', 'name': 'Education'},
      {'id': 'other', 'name': 'Other'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selectedCategoryId,
          decoration: InputDecoration(
            labelText: 'Category',
            border: const OutlineInputBorder(),
            errorText: errorText,
          ),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['id'],
              child: Text(category['name']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onCategorySelected(value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }
} 