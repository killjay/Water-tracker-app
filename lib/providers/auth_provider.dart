import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _authService.currentUser;
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => currentUser != null;
  bool get hasCompletedOnboarding =>
      _userData?.preferences.hasCompletedOnboarding ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await loadUserData();
      } else {
        _userData = null;
        notifyListeners();
      }
    });
  }

  // Load user data from Firestore
  Future<void> loadUserData() async {
    if (currentUser == null) {
      print('[AuthProvider] Cannot load user data: no current user');
      return;
    }

    try {
      print('[AuthProvider] Loading user data for ${currentUser!.uid}');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _userData = await _authService.getUserData(currentUser!.uid);
      print('[AuthProvider] User data loaded: ${_userData != null ? "success" : "null"}');
      if (_userData != null) {
        print('[AuthProvider] hasCompletedOnboarding: ${_userData!.preferences.hasCompletedOnboarding}');
      }
    } catch (e) {
      print('[AuthProvider] Error loading user data: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      await loadUserData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('[AuthProvider] Starting sign in for $email');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signIn(
        email: email,
        password: password,
      );
      print('[AuthProvider] Sign in successful, loading user data...');

      await loadUserData();
      print('[AuthProvider] Sign in complete');
      return true;
    } catch (e) {
      print('[AuthProvider] Sign in failed: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      print('[AuthProvider] Starting Google sign in');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final cred = await _authService.signInWithGoogle();
      if (cred == null) {
        // user cancelled
        print('[AuthProvider] Google sign in cancelled by user');
        return false;
      }

      print('[AuthProvider] Google sign in successful, loading user data...');
      await loadUserData();
      print('[AuthProvider] Google sign in complete');
      return true;
    } catch (e) {
      print('[AuthProvider] Google sign in failed: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signOut();
      _userData = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user preferences
  Future<bool> updateUserPreferences(UserPreferences preferences) async {
    if (currentUser == null) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.updateUserPreferences(
        currentUser!.uid,
        preferences,
      );

      await loadUserData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
