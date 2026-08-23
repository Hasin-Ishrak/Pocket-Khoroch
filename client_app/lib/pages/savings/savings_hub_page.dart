import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';

class SavingsHubPage extends StatefulWidget {
  const SavingsHubPage({super.key});

  @override
  State<SavingsHubPage> createState() => _SavingsHubPageState();
}

class _SavingsHubPageState extends State<SavingsHubPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId != null) {
      await context.read<SavingsProvider>().loadGoals(userId, syncFirst: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savingsProvider = context.watch<SavingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Savings')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: _ToolCard(
                    icon: Icons.flag_rounded,
                    title: 'Goal Calculator',
                    subtitle: 'Save toward a target',
                    onTap: () => context.push('/goal-calculator'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ToolCard(
                    icon: Icons.show_chart_rounded,
                    title: 'Rate Projector',
                    subtitle: 'Project your savings',
                    onTap: () => context.push('/rate-projector'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text('Your Goals', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (savingsProvider.isLoading && savingsProvider.goals.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (savingsProvider.goals.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: EmptyState(
                  icon: Icons.savings_outlined,
                  title: 'No savings goals yet',
                  subtitle: 'Use the Goal Calculator above to create one',
                ),
              )
            else
              ...savingsProvider.goals.map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    goal.title,
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  '${goal.daysRemaining} days left',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: goal.progressPercent,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${CurrencyFormatter.format(goal.savedAmount)} of ${CurrencyFormatter.format(goal.targetAmount)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  '${CurrencyFormatter.format(goal.dailyTargetNeeded)}/day needed',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 28),
              const SizedBox(height: 10),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}