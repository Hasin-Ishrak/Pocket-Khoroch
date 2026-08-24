import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder_model.dart';
import '../repository/reminder_repository.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderRepository _repository;
  final _uuid = const Uuid();

  ReminderProvider({required ReminderRepository repository}) : _repository = repository;

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ReminderModel> get upcomingReminders =>
      _reminders.where((r) => r.isEnabled && r.dateTime.isAfter(DateTime.now())).toList();

  Future<void> loadReminders(String userId, {bool syncFirst = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (syncFirst) {
        await _repository.pullAndMergeFromCloud(userId);
      }
      _reminders = _repository.getLocalReminders(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load reminders';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReminder({
    required String userId,
    required String title,
    String? note,
    required DateTime dateTime,
    required String type,
    String repeat = 'none',
  }) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final reminder = ReminderModel(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        note: note,
        dateTime: dateTime,
        type: type,
        repeat: repeat,
        notificationId: notificationId,
      );
      await _repository.addReminder(reminder);
      _reminders.add(reminder);
      _reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add reminder';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleReminder(String reminderId, bool isEnabled) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index == -1) return false;
      final updated = _reminders[index].copyWith(isEnabled: isEnabled);
      await _repository.updateReminder(updated);
      _reminders[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update reminder';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReminder(String userId, String reminderId) async {
    try {
      final reminder = _reminders.firstWhere((r) => r.id == reminderId);
      await _repository.deleteReminder(userId, reminderId, reminder.notificationId);
      _reminders.removeWhere((r) => r.id == reminderId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete reminder';
      notifyListeners();
      return false;
    }
  }
}