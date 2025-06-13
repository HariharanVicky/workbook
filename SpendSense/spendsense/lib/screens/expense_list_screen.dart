import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../widgets/expense_list_widget.dart';
import 'add_edit_expense_screen.dart';
import 'package:spendsense/providers/settings_provider.dart';
import 'package:spendsense/screens/edit_expense_screen.dart';
import 'package:spendsense/widgets/error_view.dart';
import 'package:spendsense/widgets/skeleton_screen.dart';
import 'package:spendsense/navigation/route_guards.dart';
import '../providers/category_provider.dart';
import 'add_expense_screen.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  bool _isInitialized = false;
  late TabController _tabController;
  String _searchQuery = '';
  String _sortBy = 'date';
  bool _sortAscending = false;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    if (!mounted) return;
    await context.read<ExpenseProvider>().loadExpenses();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _onExpenseEdit(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(expense: expense),
      ),
    );
  }

  List<Expense> _getFilteredAndSortedExpenses(List<Expense> expenses, String type) {
    // First filter by type, search query, and category
    var filteredExpenses = expenses.where((expense) {
      if (expense.type != type) return false;
      if (_searchQuery.isNotEmpty && 
          !expense.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedCategory != null) {
        final category = context.read<CategoryProvider>().getCategory(int.parse(_selectedCategory!));
        if (category == null || expense.categoryId != category.id) {
          return false;
        }
      }
      return true;
    }).toList();

    // Then sort the filtered expenses
    filteredExpenses.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'amount':
          comparison = a.amount.compareTo(b.amount);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filteredExpenses;
  }

  Widget _buildExpenseList(List<Expense> expenses, String type) {
    final filteredExpenses = _getFilteredAndSortedExpenses(expenses, type);
    
    if (filteredExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'expense' ? Icons.money_off : Icons.money,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type == 'expense' ? 'expenses' : 'income'} found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (_searchQuery.isNotEmpty || _selectedCategory != null)
              Text(
                'Try adjusting your filters',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
      );
    }

    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        return ListView.builder(
          itemCount: filteredExpenses.length,
          itemBuilder: (context, index) {
            final expense = filteredExpenses[index];
            final categories = categoryProvider.getCategoriesByType(type);
            final category = categories.firstWhere(
              (cat) => cat.id == expense.categoryId,
              orElse: () => ExpenseCategory(
                id: 0,
                name: 'Uncategorized',
                icon: 'category',
                color: '',
                type: type,
              ),
            );
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: category.color.startsWith('#') ? Color(int.parse(category.color.replaceAll('#', '0xFF'))) : Color(int.parse(category.color)),
                  child: Icon(
                    _getIconData(category.icon),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  expense.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, y').format(expense.date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.name,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  _formatAmount(expense.amount, type),
                  style: TextStyle(
                    color: type == 'expense' ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ${_tabController.index == 0 ? 'expenses' : 'income'}...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.money_off, size: 20),
                    const SizedBox(width: 8),
                    const Text('Expenses'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.money, size: 20),
                    const SizedBox(width: 8),
                    const Text('Income'),
                  ],
                ),
              ),
            ],
          ),

          // Transaction List
          Expanded(
            child: Consumer<ExpenseProvider>(
              builder: (context, expenseProvider, child) {
                if (!_isInitialized || expenseProvider.isLoading) {
                  return const SkeletonScreen(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (expenseProvider.error != null) {
                  return Center(
                    child: Text(
                      'Error: ${expenseProvider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExpenseList(expenseProvider.expenses, 'expense'),
                    _buildExpenseList(expenseProvider.expenses, 'income'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
          if (result == true) {
            await _loadExpenses();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter & Sort'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'date',
                          child: Text('Date'),
                        ),
                        DropdownMenuItem(
                          value: 'amount',
                          child: Text('Amount'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  final categories = categoryProvider.getCategoriesByType(
                    _tabController.index == 0 ? 'expense' : 'income'
                  );
                  
                  return DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: const Text('All Categories'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...categories.map((category) => DropdownMenuItem<String>(
                        value: category.id.toString(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconData(category.icon),
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      )).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                this.setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    // If the category has a color property, use it
    if (categoryName.startsWith('#')) {
      return Color(int.parse(categoryName.replaceAll('#', '0xFF')));
    }
    // Fallback to default color mapping
    switch (categoryName.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transportation':
        return Colors.blue;
      case 'entertainment':
        return Colors.purple;
      case 'shopping':
        return Colors.pink;
      case 'bills':
        return Colors.red;
      case 'health':
        return Colors.green;
      case 'travel':
        return Colors.teal;
      case 'education':
        return Colors.indigo;
      case 'salary':
        return Colors.green;
      case 'investment':
        return Colors.amber;
      case 'gift':
        return Colors.pink;
      case 'other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatAmount(double amount, String type) {
    final settingsProvider = context.read<SettingsProvider>();
    final formattedAmount = NumberFormat.currency(
      symbol: settingsProvider.currency,
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    ).format(amount.abs());
    return type == 'expense' ? '-$formattedAmount' : formattedAmount;
  }

  IconData _getIconData(String iconName) {
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
} 