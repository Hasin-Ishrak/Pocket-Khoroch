import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/currency_formatter.dart';

enum RateFrequency { daily, weekly, monthly }

class RateProjectorPage extends StatefulWidget {
  const RateProjectorPage({super.key});

  @override
  State<RateProjectorPage> createState() => _RateProjectorPageState();
}

class _RateProjectorPageState extends State<RateProjectorPage> {
  final _amountController = TextEditingController();
  RateFrequency _frequency = RateFrequency.weekly;

  double? _weekly;
  double? _monthly;
  double? _yearly;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      setState(() {
        _weekly = null;
        _monthly = null;
        _yearly = null;
      });
      return;
    }

    double daily;
    switch (_frequency) {
      case RateFrequency.daily:
        daily = amount;
        break;
      case RateFrequency.weekly:
        daily = amount / 7;
        break;
      case RateFrequency.monthly:
        daily = amount / 30;
        break;
    }

    setState(() {
      _weekly = daily * 7;
      _monthly = daily * 30;
      _yearly = daily * 365;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionProvider = context.watch<TransactionProvider>();

    // Suggest a rate based on real average daily savings, if data exists
    final suggestedDaily = transactionProvider.transactions.isNotEmpty
        ? (transactionProvider.balance / 30)
              .clamp(0, double.infinity)
              .toDouble()
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Projector')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter how much you currently save, and see your monthly and yearly projection.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.65),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount you save',
                  prefixText: '৳ ',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                onChanged: (_) => _calculate(),
              ),
              const SizedBox(height: 12),
              SegmentedButton<RateFrequency>(
                segments: const [
                  ButtonSegment(
                    value: RateFrequency.daily,
                    label: Text('Daily'),
                  ),
                  ButtonSegment(
                    value: RateFrequency.weekly,
                    label: Text('Weekly'),
                  ),
                  ButtonSegment(
                    value: RateFrequency.monthly,
                    label: Text('Monthly'),
                  ),
                ],
                selected: {_frequency},
                onSelectionChanged: (selection) {
                  setState(() => _frequency = selection.first);
                  _calculate();
                },
              ),
              const SizedBox(height: 24),
              if (_weekly != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Your projected savings',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        _ProjectionRow(label: 'Per week', amount: _weekly!),
                        const Divider(height: 24),
                        _ProjectionRow(label: 'Per month', amount: _monthly!),
                        const Divider(height: 24),
                        _ProjectionRow(label: 'Per year', amount: _yearly!),
                      ],
                    ),
                  ),
                ),
              ] else if (suggestedDaily > 0) ...[
                Card(
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Based on your recent activity, you save about '
                            '${CurrencyFormatter.format(suggestedDaily)} per day. '
                            'Try entering that above!',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectionRow extends StatelessWidget {
  final String label;
  final double amount;

  const _ProjectionRow({required this.label, required this.amount});

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
