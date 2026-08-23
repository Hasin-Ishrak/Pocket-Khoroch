import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/subscription_model.dart';
import '../../widgets/primary_button.dart';

class ManageSubscriptionPage extends StatelessWidget {
  const ManageSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();
    final subscription = provider.subscription;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Subscription')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            subscription.isPro ? Icons.verified_rounded : Icons.info_outline_rounded,
                            color: subscription.isPro ? theme.colorScheme.primary : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            subscription.isPro ? 'Pro Member' : 'Free Plan',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (subscription.phoneNumber != null) ...[
                        const SizedBox(height: 12),
                        Text('Phone: ${subscription.phoneNumber}'),
                      ],
                      if (subscription.expiresAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Renews: ${subscription.expiresAt!.day}/${subscription.expiresAt!.month}/${subscription.expiresAt!.year}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (subscription.isPro)
                PrimaryButton(
                  label: 'Unsubscribe',
                  isLoading: provider.isLoading,
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Unsubscribe?'),
                        content: const Text("You'll lose access to Pro features immediately."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unsubscribe')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await provider.unsubscribe();
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}