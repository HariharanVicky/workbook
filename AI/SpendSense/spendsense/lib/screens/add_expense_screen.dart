import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/category_selector.dart';
import '../components/amount_input.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'expense';
  int? _selectedCategoryId;
  bool _isLoading = false;
  double _amount = 0;
  String? _amountError;
  FocusNode _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load categories when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    try {
      await context.read<CategoryProvider>().loadCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final expense = Expense(
        description: _descriptionController.text.trim(),
        amount: _amount,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        type: _selectedType,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await context.read<ExpenseProvider>().addExpense(expense);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding expense: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expense',
                  label: Text('Expense'),
                  icon: Icon(Icons.remove_circle_outline),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Income'),
                  icon: Icon(Icons.add_circle_outline),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                  _selectedCategoryId = null; // Reset category when type changes
                });
              },
            ),
            const SizedBox(height: 16),
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                if (categoryProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (categoryProvider.error != null) {
                  return Center(
                    child: Text(
                      'Error loading categories: ${categoryProvider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                return CategorySelector(
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  type: _selectedType,
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AmountInput(
              initialValue: _amount,
              onAmountChanged: (value) {
                setState(() {
                  _amount = value;
                });
              },
              errorText: _amountError,
              focusNode: _amountFocusNode,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(
                DateFormat('MMM dd, yyyy').format(_selectedDate),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveExpense,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
              label: Text(_isLoading ? 'Saving...' : 'Save Transaction'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 