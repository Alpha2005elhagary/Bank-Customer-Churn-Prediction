import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isFirstTime = true; // For onboarding

  bool get isLoggedIn => Supabase.instance.client.auth.currentSession != null;
  bool get isFirstTime => _isFirstTime;

  Future<void> login(String email, String password) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    notifyListeners();
  }

  void completeOnboarding() {
    _isFirstTime = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    notifyListeners();
  }
}
