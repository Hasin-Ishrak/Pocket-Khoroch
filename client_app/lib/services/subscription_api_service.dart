import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subscription_model.dart';

/// Thrown when the API returns an error response.
class SubscriptionApiException implements Exception {
  final String message;
  SubscriptionApiException(this.message);
  @override
  String toString() => message;
}

abstract class SubscriptionApiService {
  Future<void> sendOtp(String phoneNumber);
  Future<bool> verifyOtp(String phoneNumber, String otp);
  Future<SubscriptionModel> getSubscriptionStatus(String phoneNumber);
  Future<SubscriptionModel> subscribe(String phoneNumber, String planId);
  Future<void> unsubscribe(String phoneNumber);
}

/// MOCK implementation — simulates network delay + fake OTP "1234".
/// Swap this out for BdAppsSubscriptionApiService once the real backend is ready.
class MockSubscriptionApiService implements SubscriptionApiService {
  final Map<String, String> _otpStore = {};
  final Map<String, SubscriptionModel> _subscriptionStore = {};

  @override
  Future<void> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    _otpStore[phoneNumber] = '1234'; // fixed mock OTP for testing
  }

  @override
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    final expected = _otpStore[phoneNumber];
    if (expected == null) {
      throw SubscriptionApiException('OTP expired or not requested. Please resend.');
    }
    if (expected != otp) {
      throw SubscriptionApiException('Incorrect OTP. Please try again.');
    }
    return true;
  }

  @override
  Future<SubscriptionModel> getSubscriptionStatus(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _subscriptionStore[phoneNumber] ??
        SubscriptionModel(phoneNumber: phoneNumber, status: SubscriptionStatus.free);
  }

  @override
  Future<SubscriptionModel> subscribe(String phoneNumber, String planId) async {
    await Future.delayed(const Duration(seconds: 1));
    final subscription = SubscriptionModel(
      phoneNumber: phoneNumber,
      status: SubscriptionStatus.active,
      subscribedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      planId: planId,
    );
    _subscriptionStore[phoneNumber] = subscription;
    return subscription;
  }

  @override
  Future<void> unsubscribe(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    _subscriptionStore[phoneNumber] = SubscriptionModel(
      phoneNumber: phoneNumber,
      status: SubscriptionStatus.cancelled,
    );
  }
}

/// REAL implementation placeholder — fill in once BDApps backend + docs are provided.
class BdAppsSubscriptionApiService implements SubscriptionApiService {
  final String baseUrl;
  BdAppsSubscriptionApiService({required this.baseUrl});

  @override
  Future<void> sendOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/otp/send'),
      body: jsonEncode({'phoneNumber': phoneNumber}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw SubscriptionApiException('Failed to send OTP');
    }
  }

  @override
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/otp/verify'),
      body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw SubscriptionApiException('OTP verification failed');
    }
    return true;
  }

  @override
  Future<SubscriptionModel> getSubscriptionStatus(String phoneNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/subscription/status?phone=$phoneNumber'));
    if (response.statusCode != 200) {
      throw SubscriptionApiException('Failed to fetch subscription status');
    }
    return SubscriptionModel.fromJson(jsonDecode(response.body));
  }

  @override
  Future<SubscriptionModel> subscribe(String phoneNumber, String planId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subscription/subscribe'),
      body: jsonEncode({'phoneNumber': phoneNumber, 'planId': planId}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw SubscriptionApiException('Subscription failed');
    }
    return SubscriptionModel.fromJson(jsonDecode(response.body));
  }

  @override
  Future<void> unsubscribe(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subscription/unsubscribe'),
      body: jsonEncode({'phoneNumber': phoneNumber}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw SubscriptionApiException('Unsubscribe failed');
    }
  }
}