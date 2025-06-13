import 'package:intl/intl.dart';

class Expense {
  final int? id;
  final double amount;
  final String description;
  final DateTime date;
  final int categoryId;
  final String type;
  final String? notes;

  Expense({
    this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.type,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'type': type,
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      categoryId: map['category_id'] as int,
      type: map['type'] as String,
      notes: map['notes'] as String?,
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? description,
    DateTime? date,
    int? categoryId,
    String? type,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      notes: notes ?? this.notes,
    );
  }
} 