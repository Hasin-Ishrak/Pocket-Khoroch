import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';
import '../services/subscription_api_service.dart';

class SubscriptionRepository {
  final SubscriptionApiService _apiService;
  static const _phoneKey = 'subscription_phone';
  static const _statusKey = 'subscription_status';
  static const _expiresKey = 'subscription_expires';

  SubscriptionRepository({required SubscriptionApiService apiService}) : _apiService = apiService;

  Future<void> sendOtp(String phoneNumber) => _apiService.sendOtp(phoneNumber);

  Future<bool> verifyOtp(String phoneNumber, String otp) => _apiService.verifyOtp(phoneNumber, otp);

  Future<SubscriptionModel> subscribe(String phoneNumber, String planId) async {
    final result = await _apiService.subscribe(phoneNumber, planId);
    await _cacheLocally(result);
    return result;
  }

  Future<void> unsubscribe(String phoneNumber) async {
    await _apiService.unsubscribe(phoneNumber);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusKey, SubscriptionStatus.cancelled.name);
  }

  Future<SubscriptionModel> refreshStatus(String phoneNumber) async {
    final result = await _apiService.getSubscriptionStatus(phoneNumber);
    await _cacheLocally(result);
    return result;
  }

  Future<SubscriptionModel> getCachedSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_phoneKey);
    final statusStr = prefs.getString(_statusKey);
    final expiresStr = prefs.getString(_expiresKey);

    if (phone == null || statusStr == null) {
      return const SubscriptionModel();
    }

    return SubscriptionModel(
      phoneNumber: phone,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => SubscriptionStatus.free,
      ),
      expiresAt: expiresStr != null ? DateTime.tryParse(expiresStr) : null,
    );
  }

  Future<void> _cacheLocally(SubscriptionModel subscription) async {
    final prefs = await SharedPreferences.getInstance();
    if (subscription.phoneNumber != null) {
      await prefs.setString(_phoneKey, subscription.phoneNumber!);
    }
    await prefs.setString(_statusKey, subscription.status.name);
    if (subscription.expiresAt != null) {
      await prefs.setString(_expiresKey, subscription.expiresAt!.toIso8601String());
    }
  }
}