class MonthlySummary {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final Map<String, double>? categoryBreakdown;

  MonthlySummary({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    this.categoryBreakdown,
  });

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': balance,
      'categoryBreakdown': categoryBreakdown,
    };
  }

  factory MonthlySummary.fromMap(Map<String, dynamic> map) {
    return MonthlySummary(
      year: map['year'] as int,
      month: map['month'] as int,
      totalIncome: map['totalIncome'] as double,
      totalExpenses: map['totalExpenses'] as double,
      balance: map['balance'] as double,
      categoryBreakdown: map['categoryBreakdown'] != null
          ? Map<String, double>.from(map['categoryBreakdown'] as Map)
          : null,
    );
  }
} 