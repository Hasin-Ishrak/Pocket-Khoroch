import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/primary_button.dart';
import '../../utils/expression_evaluator.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionModel? existingTransaction;

  const AddTransactionPage({super.key, this.existingTransaction});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  String? _expressionPreview;

  bool get isEditing => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final t = widget.existingTransaction!;
      _amountController.text = t.amount.toStringAsFixed(0);
      _noteController.text = t.note ?? '';
      _selectedType = t.isIncome
          ? TransactionType.income
          : TransactionType.expense;
      _selectedDate = t.date;
      _selectedCategory = AppCategories.findById(t.categoryId);
    } else {
      _selectedCategory = AppCategories.expenseCategories.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<CategoryModel> get _currentCategories =>
      _selectedType == TransactionType.income
      ? AppCategories.incomeCategories
      : AppCategories.expenseCategories;

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
      _selectedCategory = _currentCategories.first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _onAmountChanged(String value) {
    if (ExpressionEvaluator.looksLikeExpression(value)) {
      final result = ExpressionEvaluator.tryEvaluate(value);
      setState(() {
        _expressionPreview = result != null
            ? '= ${result.toStringAsFixed(2)}'
            : null;
      });
    } else {
      setState(() => _expressionPreview = null);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId == null) {
      setState(() => _isSaving = false);
      return;
    }

    final rawInput = _amountController.text.trim();
    final amount = ExpressionEvaluator.looksLikeExpression(rawInput)
        ? (ExpressionEvaluator.tryEvaluate(rawInput) ?? 0)
        : (double.tryParse(rawInput) ?? 0);

    final success = await transactionProvider.addTransaction(
      userId: userId,
      amount: amount,
      type: _selectedType == TransactionType.income ? 'income' : 'expense',
      categoryId: _selectedCategory!.id,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save transaction. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Income / Expense toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TypeToggleButton(
                          label: 'Expense',
                          isSelected: _selectedType == TransactionType.expense,
                          onTap: () => _onTypeChanged(TransactionType.expense),
                          color: const Color(0xFFEF5350),
                        ),
                      ),
                      Expanded(
                        child: _TypeToggleButton(
                          label: 'Income',
                          isSelected: _selectedType == TransactionType.income,
                          onTap: () => _onTypeChanged(TransactionType.income),
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: _onAmountChanged,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '৳ ',
                    helperText: 'Tip: you can type math like 150+200',
                    suffixText: _expressionPreview,
                    suffixStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Enter an amount';
                    final resolved =
                        ExpressionEvaluator.looksLikeExpression(value)
                        ? ExpressionEvaluator.tryEvaluate(value)
                        : double.tryParse(value.trim());
                    if (resolved == null || resolved <= 0)
                      return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category picker
                Text('Category', style: theme.textTheme.titleSmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _currentCategories.map((cat) {
                    final isSelected = _selectedCategory?.id == cat.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color.withOpacity(0.2)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? cat.color : theme.dividerColor,
                            width: isSelected ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 16, color: cat.color),
                            const SizedBox(width: 6),
                            Text(cat.name, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Date picker
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Note
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  label: isEditing ? 'Update Transaction' : 'Save Transaction',
                  isLoading: _isSaving,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _TypeToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? color
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
