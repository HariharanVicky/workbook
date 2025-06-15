import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/monthly_summary.dart';
import '../services/database_service.dart';
import '../services/error_service.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  ExpenseProvider(this._databaseService);

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExpenses() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final expenses = await _databaseService.getExpenses();
      _expenses = expenses;
      _error = null;
    } catch (e) {
      _error = ErrorService.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _databaseService.insertExpense(expense);
      await loadExpenses(); // Reload expenses to get the updated list with IDs
      notifyListeners();
    } catch (e) {
      _error = ErrorService.getErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _databaseService.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }
    } catch (e) {
      _error = ErrorService.getErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _databaseService.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _error = ErrorService.getErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 