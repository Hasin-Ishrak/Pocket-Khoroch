import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_colors.dart';

/// Wrap any widget with this to gate it behind Pro subscription.
/// Shows the real content if user is Pro, otherwise shows a blurred/locked preview.
class ProGate extends StatelessWidget {
  final Widget child;
  final String featureName;

  const ProGate({super.key, required this.child, required this.featureName});

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<SubscriptionProvider>().isPro;

    if (isPro) return child;

    return Stack(
      children: [
        IgnorePointer(
          child: Opacity(opacity: 0.35, child: child),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.05),
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_rounded, color: AppColors.acidMint, size: 32),
                      const SizedBox(height: 10),
                      Text(
                        '$featureName is a Pro feature',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () => context.push('/upgrade'),
                        child: const Text('Upgrade to Pro'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}