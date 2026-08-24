import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../models/reminder_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pro_gate.dart';
import '../../theme/app_colors.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId != null) {
      await context.read<ReminderProvider>().loadReminders(userId, syncFirst: true);
    }
  }

  IconData _iconForType(ReminderType type) {
    switch (type) {
      case ReminderType.billDue:
        return Icons.receipt_long_rounded;
      case ReminderType.semesterFee:
        return Icons.school_rounded;
      case ReminderType.dailySavings:
        return Icons.savings_rounded;
      case ReminderType.custom:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminderProvider = context.watch<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-reminder'),
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Add'),
      ),
      body: ProGate(
        featureName: 'Reminders',
        child: RefreshIndicator(
          onRefresh: _load,
          child: reminderProvider.isLoading && reminderProvider.reminders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : reminderProvider.reminders.isEmpty
                  ? const EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'No reminders yet',
                      subtitle: 'Set reminders for bills, semester fees, or daily savings',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: reminderProvider.reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminderProvider.reminders[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.acidMint.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_iconForType(reminder.typeEnum), color: AppColors.accentOnLight, size: 20),
                            ),
                            title: Text(reminder.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              '${DateFormat('MMM d, yyyy · h:mm a').format(reminder.dateTime)}'
                              '${reminder.repeatEnum != ReminderRepeat.none ? ' · Repeats ${reminder.repeat}' : ''}',
                            ),
                            trailing: Switch(
                              value: reminder.isEnabled,
                              onChanged: (value) {
                                final userId = context.read<AuthProvider>().currentUser?.uid;
                                if (userId != null) {
                                  context.read<ReminderProvider>().toggleReminder(reminder.id, value);
                                }
                              },
                            ),
                            onLongPress: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete reminder?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                final userId = context.read<AuthProvider>().currentUser?.uid;
                                if (userId != null) {
                                  context.read<ReminderProvider>().deleteReminder(userId, reminder.id);
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}