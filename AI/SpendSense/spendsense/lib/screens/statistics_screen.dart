import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../models/expense.dart';
import '../models/monthly_summary.dart';
import '../services/database_service.dart';
import '../providers/category_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _databaseService = DatabaseService();
  DateTime _selectedMonth = DateTime.now();
  List<MonthlySummary> _monthlySummaries = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load last 6 months of summaries
      final summaries = await _databaseService.getMonthlySummaries(
        _selectedMonth.year,
        _selectedMonth.month,
        6,
      );
      
      setState(() {
        _monthlySummaries = summaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
      await _loadData();
    }
  }

  Widget _buildMonthSelector() {
    return Card(
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
    );
  }

  Widget _buildMonthlySummary() {
    if (_monthlySummaries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No data available for this period'),
          ),
        ),
      );
    }

    final currentMonth = _monthlySummaries.first;
    final currency = context.watch<SettingsProvider>().currency;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Total Income',
              currentMonth.totalIncome,
              currency,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Total Expenses',
              currentMonth.totalExpenses,
              currency,
              Colors.red,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Net Balance',
              currentMonth.totalIncome - currentMonth.totalExpenses,
              currency,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, String currency, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          NumberFormat.currency(symbol: currency).format(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdown() {
    final expenses = context.watch<ExpenseProvider>().expenses;
    final currentMonthExpenses = expenses.where((expense) {
      final expenseDate = expense.date;
      return expenseDate.year == _selectedMonth.year &&
          expenseDate.month == _selectedMonth.month;
    }).toList();

    if (currentMonthExpenses.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No expenses for this month'),
          ),
        ),
      );
    }

    // Group expenses by category
    final categoryTotals = <int, double>{};
    for (final expense in currentMonthExpenses) {
      categoryTotals[expense.categoryId] = (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    // Sort categories by total amount
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...sortedCategories.map((entry) {
              final percentage = (entry.value / categoryTotals.values.reduce((a, b) => a + b)) * 100;
              final category = context.watch<CategoryProvider>().getCategory(entry.key);
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(category.name),
                      ),
                      Text(
                        NumberFormat.currency(
                          symbol: context.watch<SettingsProvider>().currency,
                        ).format(entry.value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      category.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsChart() {
    if (_monthlySummaries.length < 2) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Not enough data to show trends'),
          ),
        ),
      );
    }

    final currency = context.watch<SettingsProvider>().currency;
    final summaries = _monthlySummaries.reversed.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            NumberFormat.compactCurrency(symbol: currency)
                                .format(value),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= summaries.length) {
                            return const Text('');
                          }
                          final date = DateTime(
                            summaries[value.toInt()].year,
                            summaries[value.toInt()].month,
                          );
                          return Text(
                            DateFormat('MMM').format(date),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Income line
                    LineChartBarData(
                      spots: List.generate(
                        summaries.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          summaries[index].totalIncome,
                        ),
                      ),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Expenses line
                    LineChartBarData(
                      spots: List.generate(
                        summaries.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          summaries[index].totalExpenses,
                        ),
                      ),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Income', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem('Expenses', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error: $_error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildMonthSelector(),
            const SizedBox(height: 16),
            _buildMonthlySummary(),
            const SizedBox(height: 16),
            _buildExpenseBreakdown(),
            const SizedBox(height: 16),
            _buildTrendsChart(),
          ],
        ),
      ),
    );
  }
} 