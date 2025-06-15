import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/category_provider.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';
import '../screens/add_expense_screen.dart';

class ExpenseStatistics extends StatefulWidget {
  const ExpenseStatistics({super.key});

  @override
  State<ExpenseStatistics> createState() => _ExpenseStatisticsState();
}

class _ExpenseStatisticsState extends State<ExpenseStatistics> {
  DateTime _selectedMonth = DateTime.now();

  String _formatAmount(double amount, String currencySymbol) {
    if (amount == amount.toInt()) {
      return '$currencySymbol${amount.toInt()}';
    }
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final expenses = expenseProvider.expenses;
    final currencySymbol = settingsProvider.currencySymbol;

    // Filter expenses for selected month
    final monthExpenses = expenses.where((expense) {
      return expense.date.year == _selectedMonth.year && 
             expense.date.month == _selectedMonth.month;
    }).toList();

    if (monthExpenses.isEmpty) {
      return Column(
        children: [
          // Month Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectMonth(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Expenses for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first expense to see statistics',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddExpenseScreen(),
                      ),
                    );
                    if (result == true) {
                      // Refresh the data
                      if (mounted) {
                        context.read<ExpenseProvider>().loadExpenses();
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Calculate monthly totals for the last 6 months
    final now = DateTime.now();
    final monthlyTotals = List.generate(6, (index) {
      final month = DateTime(now.year, now.month - index);
      return expenses
          .where((e) => e.type == 'expense' && e.date.year == month.year && e.date.month == month.month)
          .fold<double>(0, (sum, e) => sum + e.amount);
    }).reversed.toList();

    // Calculate statistics for selected month
    final totalExpenses = monthExpenses.where((e) => e.type == 'expense').fold<double>(0, (sum, e) => sum + e.amount);
    final totalIncome = monthExpenses.where((e) => e.type == 'income').fold<double>(0, (sum, e) => sum + e.amount);
    final expenseCount = monthExpenses.where((e) => e.type == 'expense').length.toDouble();
    final incomeCount = monthExpenses.where((e) => e.type == 'income').length.toDouble();
    final averageExpense = expenseCount == 0 ? 0.0 : totalExpenses / expenseCount;
    final averageIncome = incomeCount == 0 ? 0.0 : totalIncome / incomeCount;
    final maxExpense = monthExpenses.where((e) => e.type == 'expense').fold<double>(0, (max, e) => e.amount > max ? e.amount : max);
    final maxIncome = monthExpenses.where((e) => e.type == 'income').fold<double>(0, (max, e) => e.amount > max ? e.amount : max);

    // Calculate category totals for selected month
    final categoryTotals = <String, double>{};
    for (var expense in monthExpenses) {
      if (expense.type == 'expense') {  // Only include expenses
        final category = categoryProvider.getCategory(expense.categoryId);
        if (category != null) {
          categoryTotals[category.name] = (categoryTotals[category.name] ?? 0) + expense.amount;
        }
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectMonth(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Key Statistics
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Income',
                  value: _formatAmount(totalIncome, currencySymbol),
                  icon: Icons.arrow_upward,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Total Expenses',
                  value: _formatAmount(totalExpenses, currencySymbol),
                  icon: Icons.arrow_downward,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Average Income',
                  value: _formatAmount(averageIncome, currencySymbol),
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Average Expense',
                  value: _formatAmount(averageExpense, currencySymbol),
                  icon: Icons.trending_down,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Highest Income',
                  value: _formatAmount(maxIncome, currencySymbol),
                  icon: Icons.arrow_upward,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Highest Expense',
                  value: _formatAmount(maxExpense, currencySymbol),
                  icon: Icons.arrow_downward,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Category Distribution Pie Chart
          if (categoryTotals.isNotEmpty) ...[
            const Text(
              'Expense by Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sections: _createPieChartSections(categoryTotals),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      startDegreeOffset: -90,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _formatAmount(totalExpenses, currencySymbol),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Category Legend
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: categoryTotals.entries.map((entry) {
                      final index = categoryTotals.keys.toList().indexOf(entry.key);
                      final colors = [
                        Colors.blue,
                        Colors.red,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                        Colors.teal,
                        Colors.pink,
                        Colors.indigo,
                      ];
                      final color = colors[index % colors.length];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${entry.key} (${_formatAmount(entry.value, currencySymbol)})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: color.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Monthly Trend Bar Chart
          const Text(
            'Monthly Trend',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: monthlyTotals.reduce((a, b) => a > b ? a : b) * 1.2,
                barGroups: _createBarGroups(monthlyTotals),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final month = DateTime(now.year, now.month - (5 - value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM').format(month),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: monthlyTotals.reduce((a, b) => a > b ? a : b) / 2,
                      getTitlesWidget: (value, meta) {
                        return Transform.rotate(
                          angle: -0.5,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              _formatAmount(value, currencySymbol),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: monthlyTotals.reduce((a, b) => a > b ? a : b) / 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        _formatAmount(rod.toY, currencySymbol),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(Map<String, double> categoryTotals) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return categoryTotals.entries.map((entry) {
      final index = categoryTotals.keys.toList().indexOf(entry.key);
      final color = colors[index % colors.length];
      final percentage = (entry.value / categoryTotals.values.reduce((a, b) => a + b)) * 100;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _createBarGroups(List<double> monthlyTotals) {
    return List.generate(monthlyTotals.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: monthlyTotals[index],
            color: Colors.blue,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 