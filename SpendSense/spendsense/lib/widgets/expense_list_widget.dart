import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import 'expense_card_widget.dart';

class ExpenseListWidget extends StatefulWidget {
  final bool isLoading;
  final Function(Expense) onExpenseEdit;

  const ExpenseListWidget({
    Key? key,
    required this.isLoading,
    required this.onExpenseEdit,
  }) : super(key: key);

  @override
  State<ExpenseListWidget> createState() => _ExpenseListWidgetState();
}

class _ExpenseListWidgetState extends State<ExpenseListWidget> {
  String _searchQuery = '';
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, CategoryProvider>(
      builder: (context, expenseProvider, categoryProvider, child) {
        if (widget.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenses = expenseProvider.expenses.where((expense) {
          if (_searchQuery.isEmpty) return true;
          return expense.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              categoryProvider.getCategoryName(expense.categoryId).toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        expenses.sort((a, b) {
          int comparison = 0;
          switch (_sortBy) {
            case 'date':
              comparison = a.date.compareTo(b.date);
              break;
            case 'amount':
              comparison = a.amount.compareTo(b.amount);
              break;
            case 'description':
              comparison = a.description.compareTo(b.description);
              break;
          }
          return _sortAscending ? comparison : -comparison;
        });

        if (expenses.isEmpty) {
          return const Center(
            child: Text('No expenses found'),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search expenses...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sort by'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('Date'),
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'date';
                                    _sortAscending = !_sortAscending;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('Amount'),
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'amount';
                                    _sortAscending = !_sortAscending;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('Description'),
                                onTap: () {
                                  setState(() {
                                    _sortBy = 'description';
                                    _sortAscending = !_sortAscending;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return ListTile(
                    title: Text(expense.description),
                    subtitle: Text(categoryProvider.getCategoryName(expense.categoryId)),
                    trailing: Text(
                      '\$${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: expense.type == 'expense' ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => widget.onExpenseEdit(expense),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
} 