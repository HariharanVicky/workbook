import 'package:flutter/material.dart';
import 'package:spendsense/models/expense.dart';
import 'package:spendsense/screens/add_expense_screen.dart';
import 'package:spendsense/screens/edit_expense_screen.dart';
import 'package:spendsense/screens/expense_list_screen.dart';
import 'package:spendsense/screens/home_screen.dart';
import 'package:spendsense/screens/monthly_detail_screen.dart';
import 'package:spendsense/screens/settings_screen.dart';
import 'package:spendsense/screens/statistics_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense';
  static const String expenseList = '/expense-list';
  static const String monthlyDetail = '/monthly-detail';
  static const String statistics = '/statistics';
  static const String settingsRoute = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case addExpense:
        return MaterialPageRoute(
          builder: (_) => const AddExpenseScreen(),
        );

      case editExpense:
        final expense = settings.arguments as Expense;
        return MaterialPageRoute(
          builder: (_) => EditExpenseScreen(expense: expense),
        );

      case expenseList:
        return MaterialPageRoute(
          builder: (_) => const ExpenseListScreen(),
        );

      case monthlyDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MonthlyDetailScreen(
            year: args['year'] as int,
            month: args['month'] as int,
          ),
        );

      case statistics:
        return MaterialPageRoute(
          builder: (_) => const StatisticsScreen(),
        );

      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static Future<T?> navigateToHome<T>(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      home,
      (route) => false,
    );
  }

  static Future<T?> navigateToAddExpense<T>(BuildContext context) {
    return navigateTo<T>(context, addExpense);
  }

  static Future<T?> navigateToEditExpense<T>(BuildContext context, Expense expense) {
    return navigateTo<T>(context, editExpense, arguments: expense);
  }

  static Future<T?> navigateToExpenseList<T>(BuildContext context) {
    return navigateTo<T>(context, expenseList);
  }

  static Future<T?> navigateToMonthlyDetail<T>(
    BuildContext context, {
    required int year,
    required int month,
  }) {
    return navigateTo<T>(
      context,
      monthlyDetail,
      arguments: {
        'year': year,
        'month': month,
      },
    );
  }

  static Future<T?> navigateToStatistics<T>(BuildContext context) {
    return navigateTo<T>(context, statistics);
  }

  static Future<T?> navigateToSettings<T>(BuildContext context) {
    return navigateTo<T>(context, settingsRoute);
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
} 