import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/primary_button.dart';

class GoalCalculatorPage extends StatefulWidget {
  const GoalCalculatorPage({super.key});

  @override
  State<GoalCalculatorPage> createState() => _GoalCalculatorPageState();
}

class _GoalCalculatorPageState extends State<GoalCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _targetDate;
  bool _isSaving = false;

  double? _dailyNeeded;
  double? _weeklyNeeded;
  double? _monthlyNeeded;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
      _calculate();
    }
  }

  void _calculate() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || _targetDate == null) {
      setState(() {
        _dailyNeeded = null;
        _weeklyNeeded = null;
        _monthlyNeeded = null;
      });
      return;
    }
    final now = DateTime.now();
    final days = _targetDate!.difference(DateTime(now.year, now.month, now.day)).inDays;
    final safeDays = days <= 0 ? 1 : days;

    setState(() {
      _dailyNeeded = amount / safeDays;
      _weeklyNeeded = _dailyNeeded! * 7;
      _monthlyNeeded = _dailyNeeded! * 30;
    });
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate() || _targetDate == null) {
      if (_targetDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick a target date')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid;
    if (userId == null) {
      setState(() => _isSaving = false);
      return;
    }

    final success = await context.read<SavingsProvider>().addGoal(
          userId: userId,
          title: _titleController.text.trim(),
          targetAmount: double.parse(_amountController.text.trim()),
          targetDate: _targetDate!,
        );

    setState(() => _isSaving = false);
    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Goal Calculator')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Set a savings target and see how much to save daily, weekly, or monthly.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal name',
                    hintText: 'e.g. Semester Fee, New Laptop',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a goal name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Target amount',
                    prefixText: '৳ ',
                    prefixIcon: Icon(Icons.savings_outlined),
                  ),
                  onChanged: (_) => _calculate(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter target amount';
                    if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Target date',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    child: Text(
                      _targetDate == null
                          ? 'Select a date'
                          : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                if (_dailyNeeded != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('You need to save', style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 12),
                          _ResultRow(label: 'Daily', amount: _dailyNeeded!),
                          const Divider(height: 24),
                          _ResultRow(label: 'Weekly', amount: _weeklyNeeded!),
                          const Divider(height: 24),
                          _ResultRow(label: 'Monthly', amount: _monthlyNeeded!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                PrimaryButton(
                  label: 'Save Goal',
                  isLoading: _isSaving,
                  onPressed: _saveGoal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final double amount;

  const _ResultRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        Text(
          CurrencyFormatter.format(amount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}