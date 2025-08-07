import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;

  bool get isLoggedIn => _token != null;
  Map<String, dynamic>? get user => _user;

Future<bool> login(String email, String password) async {
  final result = await AuthService.login(email, password);
  if (result != null && result['token'] != null) {
    _token = result['token'];  // accessToken now stored as token
    _user = result['user'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    notifyListeners();
    return true;
  }
  return false;
}


  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
  Future<void> fetchProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final savedToken = prefs.getString('token');
  if (savedToken != null) {
    _token = savedToken;
    final profileData = await AuthService.getProfile(savedToken);
    if (profileData != null) {
      _user = profileData;
      notifyListeners();
    }
  }
}

}
