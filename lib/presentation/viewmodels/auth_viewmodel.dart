import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart'; // Import navigatorKey

class AuthViewModel with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isFirstTime = true;
  bool _isSplashDone = false;
  AuthChangeEvent? _lastEvent;

  AuthViewModel() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('isFirstTime') ?? true;
    _initAuthListener();
    notifyListeners();
  }

  void _initAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _lastEvent = data.event;
      
      if (data.event == AuthChangeEvent.signedOut) {
        _isLoading = false;
        _error = null;
        // Force clear the navigation stack if we are signed out
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
      
      notifyListeners();
    });
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => Supabase.instance.client.auth.currentSession != null;
  bool get isFirstTime => _isFirstTime;
  bool get isSplashDone => _isSplashDone;
  User? get currentUser => Supabase.instance.client.auth.currentUser;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _formatError(dynamic e) {
    if (e is AuthException) return e.message;
    return 'An unexpected error occurred. Please try again.';
  }

  Future<void> completeOnboarding() async {
    _isFirstTime = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    notifyListeners();
  }

  void completeSplash() {
    _isSplashDone = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      // Sign out locally anyway
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
