import 'package:flutter/material.dart';
import 'package:spendsense/models/expense.dart';

class RouteGuards {
  static bool canNavigateToEditExpense(BuildContext context, Expense expense) {
    // Check if the expense exists and has an ID
    if (expense.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot edit expense: Invalid expense ID'),
        ),
      );
      return false;
    }
    return true;
  }

  static bool canNavigateToMonthlyDetail(BuildContext context, int year, int month) {
    // Check if the year and month are valid
    if (year < 2000 || year > DateTime.now().year) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid year'),
        ),
      );
      return false;
    }

    if (month < 1 || month > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid month'),
        ),
      );
      return false;
    }

    // Check if the date is in the future
    final now = DateTime.now();
    if (year > now.year || (year == now.year && month > now.month)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot view future months'),
        ),
      );
      return false;
    }

    return true;
  }

  static bool canPop(BuildContext context) {
    if (!Navigator.canPop(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot go back'),
        ),
      );
      return false;
    }
    return true;
  }
} 