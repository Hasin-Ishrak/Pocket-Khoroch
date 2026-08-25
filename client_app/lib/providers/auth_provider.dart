import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../repository/user_repository.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;

  AuthProvider({
    required AuthService authService,
    required UserRepository userRepository,
  }) : _authService = authService,
       _userRepository = userRepository {
    _init();
  }

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _init() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
      } else {
        _status = AuthStatus.authenticated;
        _currentUser = await _userRepository.getUserProfile(firebaseUser.uid);
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user!;

      final newUser = AppUser(
        uid: firebaseUser.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );
      await _userRepository.createUserProfile(newUser);
      _currentUser = newUser;
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        _errorMessage = null; // user cancelled, not an error
        return false;
      }

      final firebaseUser = credential.user!;
      final existingProfile = await _userRepository.getUserProfile(
        firebaseUser.uid,
      );

      if (existingProfile == null) {
        final newUser = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
        await _userRepository.createUserProfile(newUser);
        _currentUser = newUser;
      } else {
        _currentUser = existingProfile;
      }

      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> updateProfile({
    String? displayName,
    String? university,
    String? profession,
  }) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    try {
      final updated = _currentUser!.copyWith(
        displayName: displayName,
        university: university,
        profession: profession,
      );
      await _userRepository.updateUserProfile(updated);
      _currentUser = updated;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
