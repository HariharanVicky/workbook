import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../utils/icon_utils.dart';

// Helper to map icon name string to IconData
IconData getIconData(String iconName) {
  switch (iconName) {
    case 'restaurant':
      return Icons.restaurant;
    case 'directions_car':
      return Icons.directions_car;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'movie':
      return Icons.movie;
    case 'receipt':
      return Icons.receipt;
    case 'local_hospital':
      return Icons.local_hospital;
    case 'flight':
      return Icons.flight;
    case 'school':
      return Icons.school;
    case 'work':
      return Icons.work;
    case 'trending_up':
      return Icons.trending_up;
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'attach_money':
      return Icons.attach_money;
    default:
      return Icons.category;
  }
}

Color parseColor(String colorString) {
  // colorString is like '#FF5722'
  return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
}

class CategorySelector extends StatelessWidget {
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;
  final String type;

  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (categoryProvider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error loading categories: ${categoryProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => categoryProvider.loadCategories(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final categories = categoryProvider.getCategoriesByType(type);

        if (categories.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No ${type.toLowerCase()} categories available',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to category management screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Category management coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'Select a category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category.id == selectedCategoryId;
                
                return InkWell(
                  onTap: () => onCategorySelected(category.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          getIconData(category.icon),
                          color: parseColor(category.color),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
} 