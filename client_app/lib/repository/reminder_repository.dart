import '../models/reminder_model.dart';
import '../services/local_storage_service.dart';
import '../services/reminder_cloud_service.dart';
import '../services/notification_service.dart';

class ReminderRepository {
  final LocalStorageService _localService;
  final ReminderCloudService _cloudService;

  ReminderRepository({
    required LocalStorageService localService,
    required ReminderCloudService cloudService,
  })  : _localService = localService,
        _cloudService = cloudService;

  Future<void> addReminder(ReminderModel reminder) async {
    await _localService.saveReminder(reminder);
    await NotificationService.scheduleReminder(reminder);
    _syncInBackground(reminder);
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    final updated = reminder.copyWith(isSynced: false);
    await _localService.saveReminder(updated);
    await NotificationService.scheduleReminder(updated);
    _syncInBackground(updated);
  }

  Future<void> deleteReminder(String userId, String reminderId, int notificationId) async {
    await _localService.deleteReminder(reminderId);
    await NotificationService.cancelReminder(notificationId);
    try {
      await _cloudService.deleteReminder(userId, reminderId);
    } catch (_) {}
  }

  List<ReminderModel> getLocalReminders(String userId) {
    return _localService.getAllReminders(userId);
  }

  Future<void> _syncInBackground(ReminderModel reminder) async {
    try {
      await _cloudService.pushReminder(reminder);
      final synced = reminder.copyWith(isSynced: true);
      await _localService.saveReminder(synced);
    } catch (_) {}
  }

  Future<void> syncPendingReminders(String userId) async {
    final pending = _localService.getUnsyncedReminders(userId);
    for (final r in pending) {
      await _syncInBackground(r);
    }
  }

  Future<void> pullAndMergeFromCloud(String userId) async {
    try {
      final cloudReminders = await _cloudService.fetchAllReminders(userId);
      for (final r in cloudReminders) {
        await _localService.saveReminder(r);
        await NotificationService.scheduleReminder(r); // re-schedule on new device
      }
    } catch (_) {}
  }
}