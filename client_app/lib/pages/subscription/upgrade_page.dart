import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class UpgradePage extends StatefulWidget {
  const UpgradePage({super.key});

  @override
  State<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade to Pro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProFeaturesList(theme: theme),
              const SizedBox(height: 28),
              if (subscriptionProvider.otpState == OtpFlowState.verified)
                _buildSubscribeConfirm(context, subscriptionProvider)
              else if (subscriptionProvider.otpState == OtpFlowState.sent ||
                  subscriptionProvider.otpState == OtpFlowState.verifying)
                _buildOtpStep(context, subscriptionProvider)
              else
                _buildPhoneStep(context, subscriptionProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep(BuildContext context, SubscriptionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Enter your phone number', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone number',
            hintText: '01XXXXXXXXX',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        if (provider.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(provider.errorMessage!, style: const TextStyle(color: AppColors.expense)),
        ],
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Send OTP',
          isLoading: provider.otpState == OtpFlowState.sending,
          onPressed: () {
            final phone = _phoneController.text.trim();
            if (phone.isNotEmpty) provider.sendOtp(phone);
          },
        ),
      ],
    );
  }

  Widget _buildOtpStep(BuildContext context, SubscriptionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Enter the OTP sent to ${_phoneController.text}', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          '(Mock mode: use 1234)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.accentOnLight),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(counterText: ''),
        ),
        if (provider.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(provider.errorMessage!, style: const TextStyle(color: AppColors.expense)),
        ],
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Verify OTP',
          isLoading: provider.otpState == OtpFlowState.verifying,
          onPressed: () {
            final otp = _otpController.text.trim();
            if (otp.isNotEmpty) provider.verifyOtp(otp);
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            provider.resetOtpFlow();
            _otpController.clear();
          },
          child: const Text('Change phone number'),
        ),
      ],
    );
  }

  Widget _buildSubscribeConfirm(BuildContext context, SubscriptionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.income, size: 48),
        const SizedBox(height: 12),
        Text(
          'Phone verified!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Confirm Subscription — ৳99/month',
          isLoading: provider.isLoading,
          onPressed: () async {
            final success = await provider.subscribe();
            if (success && context.mounted) {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Welcome to Pro! 🎉')),
              );
            }
          },
        ),
      ],
    );
  }
}

class _ProFeaturesList extends StatelessWidget {
  final ThemeData theme;
  const _ProFeaturesList({required this.theme});

  @override
  Widget build(BuildContext context) {
    final features = [
      ('Analytics & spending charts', Icons.bar_chart_rounded),
      ('AI chatbot for savings advice', Icons.chat_bubble_outline_rounded),
      ('Bill & semester fee reminders', Icons.notifications_active_outlined),
      ('Personalized budget plans', Icons.tips_and_updates_outlined),
    ];

    return Card(
      color: AppColors.forestGraphite,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pocket Khoroch Pro',
              style: TextStyle(color: AppColors.acidMint, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(f.$2, color: AppColors.acidMint, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(f.$1, style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}