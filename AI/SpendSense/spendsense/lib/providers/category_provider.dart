import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import 'package:spendsense/services/error_service.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<ExpenseCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider(this._databaseService);

  List<ExpenseCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ExpenseCategory> getCategoriesByType(String type) {
    return _categories.where((category) => category.type == type).toList();
  }

  Future<void> loadCategories() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading categories...');
      _categories = await _databaseService.getCategories();
      print('Loaded ${_categories.length} categories');
      
      if (_categories.isEmpty) {
        print('No categories found, this might indicate a database initialization issue');
      } else {
        print('Categories loaded:');
        for (var category in _categories) {
          print('- ${category.name} (${category.type})');
        }
      }
      
      _error = null;
    } catch (e) {
      print('Error loading categories: $e');
      _error = ErrorService.getErrorMessage(e);
      rethrow; // Rethrow to handle in UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ExpenseCategory? getCategory(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      print('Category not found with id: $id');
      return null;
    }
  }

  String getCategoryName(int id) {
    final category = getCategory(id);
    return category?.name ?? 'Unknown';
  }

  Future<void> addCategory(ExpenseCategory category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Adding category: ${category.toMap()}');
      await _databaseService.insertCategory(category);
      print('Category added successfully');
      await loadCategories();
      _error = null;
    } catch (e) {
      print('Error adding category: $e');
      _error = ErrorService.getErrorMessage(e);
      rethrow; // Rethrow to handle in UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(ExpenseCategory category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Updating category: ${category.toMap()}');
      await _databaseService.updateCategory(category);
      print('Category updated successfully');
      await loadCategories();
      _error = null;
    } catch (e) {
      print('Error updating category: $e');
      _error = ErrorService.getErrorMessage(e);
      rethrow; // Rethrow to handle in UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Deleting category with id: $id');
      await _databaseService.deleteCategory(id);
      print('Category deleted successfully');
      await loadCategories();
      _error = null;
    } catch (e) {
      print('Error deleting category: $e');
      _error = ErrorService.getErrorMessage(e);
      rethrow; // Rethrow to handle in UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 