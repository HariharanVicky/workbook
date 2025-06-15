import 'package:flutter/material.dart';

class ExpenseCategory {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final String type;

  ExpenseCategory({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      type: map['type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
    };
  }

  ExpenseCategory copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    String? type,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }
} 