import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final user = authProvider.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.acidMint.withOpacity(0.2),
                  backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                  child: user?.photoUrl == null
                      ? Text(
                          (user?.displayName.isNotEmpty ?? false) ? user!.displayName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.accentOnLight),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user?.displayName ?? 'Student', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(user?.email ?? '', style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                Chip(
                  label: Text(subscriptionProvider.isPro ? 'Pro Member' : 'Free Plan'),
                  avatar: Icon(
                    subscriptionProvider.isPro ? Icons.verified_rounded : Icons.info_outline_rounded,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          _SectionLabel('Account'),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            subtitle: 'Name, university, profession',
            onTap: () => context.push('/edit-profile'),
          ),
          _SettingsTile(
            icon: Icons.email_outlined,
            title: 'Change Email',
            subtitle: user?.email ?? '',
            onTap: () => context.push('/edit-profile'),
          ),
          _SettingsTile(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            subtitle: subscriptionProvider.subscription.phoneNumber ?? 'Not set',
            onTap: () => context.push('/edit-profile'),
          ),
          _SettingsTile(
            icon: Icons.lock_reset_rounded,
            title: 'Reset Password',
            subtitle: 'Send a password reset email',
            onTap: () async {
              if (user?.email != null) {
                final success = await authProvider.resetPassword(user!.email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Reset email sent!' : 'Failed to send reset email')),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 20),
          _SectionLabel('Preferences'),
          Card(
            child: SwitchListTile(
              secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark theme'),
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
          ),

          const SizedBox(height: 20),
          _SectionLabel('Subscription'),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: subscriptionProvider.isPro ? 'Manage Subscription' : 'Upgrade to Pro',
            subtitle: subscriptionProvider.isPro ? 'View plan, unsubscribe' : 'Unlock analytics, AI chat & more',
            onTap: () => context.push(subscriptionProvider.isPro ? '/manage-subscription' : '/upgrade'),
          ),

          const SizedBox(height: 20),
          _SectionLabel('Account Actions'),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Log Out',
            iconColor: AppColors.expense,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
                  ],
                ),
              );
              if (confirmed == true) {
                await authProvider.signOut();
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: iconColor)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}