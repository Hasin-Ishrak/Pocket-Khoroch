import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../repository/subscription_repository.dart';
import '../services/subscription_api_service.dart';

enum OtpFlowState { idle, sending, sent, verifying, verified, error }

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository _repository;

  SubscriptionProvider({required SubscriptionRepository repository}) : _repository = repository {
    _loadCached();
  }

  SubscriptionModel _subscription = const SubscriptionModel();
  OtpFlowState _otpState = OtpFlowState.idle;
  String? _errorMessage;
  bool _isLoading = false;
  String? _pendingPhoneNumber;

  SubscriptionModel get subscription => _subscription;
  OtpFlowState get otpState => _otpState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isPro => _subscription.isPro;

  Future<void> _loadCached() async {
    _subscription = await _repository.getCachedSubscription();
    notifyListeners();
  }

  Future<bool> sendOtp(String phoneNumber) async {
    _otpState = OtpFlowState.sending;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.sendOtp(phoneNumber);
      _pendingPhoneNumber = phoneNumber;
      _otpState = OtpFlowState.sent;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is SubscriptionApiException ? e.message : 'Failed to send OTP';
      _otpState = OtpFlowState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_pendingPhoneNumber == null) return false;
    _otpState = OtpFlowState.verifying;
    _errorMessage = null;
    notifyListeners();
    try {
      final verified = await _repository.verifyOtp(_pendingPhoneNumber!, otp);
      _otpState = verified ? OtpFlowState.verified : OtpFlowState.error;
      notifyListeners();
      return verified;
    } catch (e) {
      _errorMessage = e is SubscriptionApiException ? e.message : 'Verification failed';
      _otpState = OtpFlowState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> subscribe({String planId = 'monthly_basic'}) async {
    if (_pendingPhoneNumber == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      _subscription = await _repository.subscribe(_pendingPhoneNumber!, planId);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e is SubscriptionApiException ? e.message : 'Subscription failed';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unsubscribe() async {
    final phone = _subscription.phoneNumber;
    if (phone == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.unsubscribe(phone);
      _subscription = _subscription.copyWith(status: SubscriptionStatus.cancelled);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to unsubscribe';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStatus() async {
    final phone = _subscription.phoneNumber;
    if (phone == null) return;
    try {
      _subscription = await _repository.refreshStatus(phone);
      notifyListeners();
    } catch (_) {}
  }

  void resetOtpFlow() {
    _otpState = OtpFlowState.idle;
    _errorMessage = null;
    _pendingPhoneNumber = null;
    notifyListeners();
  }
}