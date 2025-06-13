import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../providers/settings_provider.dart';
import '../utils/icon_utils.dart';

class ExpenseCardWidget extends StatelessWidget {
  final Expense expense;
  final ExpenseCategory? category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseCardWidget({
    Key? key,
    required this.expense,
    this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final currencyFormat = NumberFormat.currency(
      symbol: settingsProvider.currencySymbol,
      locale: settingsProvider.currency == 'INR' ? 'en_IN' : 'en_US',
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (category != null)
                CircleAvatar(
                  backgroundColor: parseColor(category!.color).withOpacity(0.2),
                  child: Icon(
                    getIconData(category!.icon),
                    color: parseColor(category!.color),
                  ),
                )
              else
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.category, color: Colors.white),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (category != null)
                      Text(
                        category!.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(expense.amount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: expense.type == 'expense'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, y').format(expense.date),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 