import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../models/reminder_model.dart';
import '../../widgets/primary_button.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  ReminderType _type = ReminderType.billDue;
  ReminderRepeat _repeat = ReminderRepeat.none;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId == null) {
      setState(() => _isSaving = false);
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final success = await context.read<ReminderProvider>().addReminder(
          userId: userId,
          title: _titleController.text.trim(),
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          dateTime: dateTime,
          type: _type.name,
          repeat: _repeat.name,
        );

    setState(() => _isSaving = false);
    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Reminder')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Semester Fee Due',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ReminderType>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ReminderType.values.map((t) {
                    return DropdownMenuItem(value: t, child: Text(_typeLabel(t)));
                  }).toList(),
                  onChanged: (value) => setState(() => _type = value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Date'),
                          child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Time'),
                          child: Text(_selectedTime.format(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ReminderRepeat>(
                  initialValue: _repeat,
                  decoration: const InputDecoration(labelText: 'Repeat'),
                  items: ReminderRepeat.values.map((r) {
                    return DropdownMenuItem(value: r, child: Text(_repeatLabel(r)));
                  }).toList(),
                  onChanged: (value) => setState(() => _repeat = value!),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Save Reminder',
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _typeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.billDue:
        return 'Bill Due';
      case ReminderType.semesterFee:
        return 'Semester Fee';
      case ReminderType.dailySavings:
        return 'Daily Savings Nudge';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  String _repeatLabel(ReminderRepeat repeat) {
    switch (repeat) {
      case ReminderRepeat.none:
        return 'Does not repeat';
      case ReminderRepeat.daily:
        return 'Daily';
      case ReminderRepeat.weekly:
        return 'Weekly';
      case ReminderRepeat.monthly:
        return 'Monthly';
      case ReminderRepeat.yearly:
        return 'Yearly';
    }
  }
}