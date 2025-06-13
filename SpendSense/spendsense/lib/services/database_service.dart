import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/monthly_summary.dart';
import 'package:spendsense/services/error_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'spendsense.db');
    print('Initializing database at: $path');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables...');
    
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
    
    print('Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    // Handle database upgrades here if needed
  }

  Future<void> _insertDefaultCategories(Database db) async {
    print('Inserting default categories...');
    
    final List<Map<String, dynamic>> defaultCategories = [
      {
        'name': 'Food & Dining',
        'icon': 'restaurant',
        'color': '#FF5722',
        'type': 'expense'
      },
      {
        'name': 'Transportation',
        'icon': 'directions_car',
        'color': '#2196F3',
        'type': 'expense'
      },
      {
        'name': 'Shopping',
        'icon': 'shopping_cart',
        'color': '#9C27B0',
        'type': 'expense'
      },
      {
        'name': 'Entertainment',
        'icon': 'movie',
        'color': '#E91E63',
        'type': 'expense'
      },
      {
        'name': 'Bills & Utilities',
        'icon': 'receipt',
        'color': '#FFC107',
        'type': 'expense'
      },
      {
        'name': 'Health & Medical',
        'icon': 'local_hospital',
        'color': '#4CAF50',
        'type': 'expense'
      },
      {
        'name': 'Travel',
        'icon': 'flight',
        'color': '#3F51B5',
        'type': 'expense'
      },
      {
        'name': 'Education',
        'icon': 'school',
        'color': '#009688',
        'type': 'expense'
      },
      {
        'name': 'Salary',
        'icon': 'work',
        'color': '#4CAF50',
        'type': 'income'
      },
      {
        'name': 'Investments',
        'icon': 'trending_up',
        'color': '#8BC34A',
        'type': 'income'
      },
      {
        'name': 'Gifts',
        'icon': 'card_giftcard',
        'color': '#FF9800',
        'type': 'income'
      },
      {
        'name': 'Other Income',
        'icon': 'attach_money',
        'color': '#00BCD4',
        'type': 'income'
      }
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
    
    print('Default categories inserted successfully');
  }

  Future<List<ExpenseCategory>> getCategories() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('categories');
      return List.generate(maps.length, (i) => ExpenseCategory.fromMap(maps[i]));
    } catch (e) {
      print('Error getting categories: $e');
      throw ErrorService.handleError(e);
    }
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
    } catch (e) {
      print('Error getting expenses: $e');
      throw ErrorService.handleError(e);
    }
  }

  Future<MonthlySummary> getMonthlySummary(int year, int month) async {
    try {
      final db = await database;
      
      // Calculate start and end dates for the month
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
      
      print('=== Monthly Summary Debug ===');
      print('Getting monthly summary for $year-$month');
      print('Date range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

      // Get expenses for the specific month using date comparison
      final List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'date DESC',
      );

      print('Found ${maps.length} expenses for the month');
      for (var map in maps) {
        print('Expense for month: $map');
      }

      final expenses = List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
      
      // Calculate totals
      double totalIncome = 0;
      double totalExpenses = 0;
      
      for (var expense in expenses) {
        print('Processing expense: ${expense.toMap()}');
        print('Expense type: ${expense.type}, Amount: ${expense.amount}');
        if (expense.type.toLowerCase() == 'income') {
          totalIncome += expense.amount;
          print('Added to income. New total: $totalIncome');
        } else {
          totalExpenses += expense.amount;
          print('Added to expenses. New total: $totalExpenses');
        }
      }

      print('Final totals - Income: $totalIncome, Expenses: $totalExpenses');

      // Calculate category breakdown
      final categoryBreakdown = <String, double>{};
      for (var expense in expenses) {
        if (expense.type.toLowerCase() == 'expense') {
          final categoryId = expense.categoryId.toString();
          categoryBreakdown[categoryId] = (categoryBreakdown[categoryId] ?? 0) + expense.amount;
          print('Category $categoryId total: ${categoryBreakdown[categoryId]}');
        }
      }

      // Always return a valid summary, even if there are no expenses
      final summary = MonthlySummary(
        year: year,
        month: month,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        balance: totalIncome - totalExpenses,
        categoryBreakdown: categoryBreakdown,
      );

      print('Created monthly summary: ${summary.toMap()}');
      print('=== End Monthly Summary Debug ===');
      return summary;
    } catch (e) {
      print('Error getting monthly summary: $e');
      print('Error stack trace: ${StackTrace.current}');
      throw ErrorService.handleError(e);
    }
  }

  Future<void> insertExpense(Expense expense) async {
    try {
      final db = await database;
      await db.insert('expenses', expense.toMap());
    } catch (e) {
      print('Error inserting expense: $e');
      throw ErrorService.handleError(e);
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      final db = await database;
      await db.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    } catch (e) {
      print('Error updating expense: $e');
      throw ErrorService.handleError(e);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      final db = await database;
      await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting expense: $e');
      throw ErrorService.handleError(e);
    }
  }

  Future<void> insertCategory(ExpenseCategory category) async {
    try {
      final db = await database;
      await db.insert('categories', category.toMap());
    } catch (e) {
      print('Error inserting category: $e');
      throw ErrorService.handleError(e);
    }
  }

  Future<void> updateCategory(ExpenseCategory category) async {
    try {
      final db = await database;
      await db.update(
        'categories',
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      print('Error updating category: $e');
      throw ErrorService.handleError(e);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final db = await database;
      await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting category: $e');
      throw ErrorService.handleError(e);
    }
  }

  Future<List<Expense>> getExpensesByMonth(int year, int month) async {
    try {
      final db = await database;
      final startDate = DateTime(year, month, 1).toIso8601String();
      final endDate = DateTime(year, month + 1, 0).toIso8601String();

      final List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startDate, endDate],
        orderBy: 'date DESC',
      );

      return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
    } catch (e) {
      print('Error getting expenses by month: $e');
      throw ErrorService.handleError(e);
    }
  }

  Future<List<MonthlySummary>> getMonthlySummaries(
    int year,
    int month,
    int count,
  ) async {
    try {
      final db = await database;
      final summaries = <MonthlySummary>[];

      for (int i = 0; i < count; i++) {
        final currentMonth = month - i;
        final currentYear = year + (currentMonth <= 0 ? -1 : 0);
        final adjustedMonth = currentMonth <= 0 ? currentMonth + 12 : currentMonth;

        final summary = await getMonthlySummary(currentYear, adjustedMonth);
        summaries.add(summary);
      }

      return summaries;
    } catch (e) {
      print('Error getting monthly summaries: $e');
      throw ErrorService.handleError(e);
    }
  }
} 