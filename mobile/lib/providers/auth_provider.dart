import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_service.dart';

enum UserRole { INVESTOR, BEEKEEPER, ADMIN, NONE }

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  UserRole _role = UserRole.NONE;
  String _phoneNumber = '';
  String _fullName = '';
  bool _isVerified = false;
  int _balance = 0;
  final ApiService _api = ApiService();

  bool get isAuthenticated => _isAuthenticated;
  UserRole get role => _role;
  String get phoneNumber => _phoneNumber;
  String get fullName => _fullName;
  bool get isVerified => _isVerified;
  int get balance => _balance;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _isVerified = prefs.getBool('isVerified') ?? false;
    _phoneNumber = prefs.getString('phoneNumber') ?? '';
    _fullName = prefs.getString('fullName') ?? '';
    _balance = prefs.getInt('balance') ?? 0;
    final roleStr = prefs.getString('role');
    if (roleStr == 'INVESTOR') _role = UserRole.INVESTOR;
    else if (roleStr == 'BEEKEEPER') _role = UserRole.BEEKEEPER;
    else if (roleStr == 'ADMIN') _role = UserRole.ADMIN;

    // If authenticated, refresh from backend
    if (_isAuthenticated) {
      try { await refreshProfile(); } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> sendOtp(String phone) async {
    _phoneNumber = phone;
    try {
      await _api.sendOtp(phone);
    } catch (e) {
      debugPrint("OTP Send Error: $e");
      rethrow;
    }
  }

  Future<bool> verifyOtp(String otp, UserRole selectedRole) async {
    try {
      final response = await _api.verifyOtp(_phoneNumber, otp, selectedRole.name);
      final data = response.data;

      _isAuthenticated = true;
      _role = _parseRole(data['role']);
      _fullName = data['fullName'] ?? '';
      _isVerified = data['isVerified'] ?? false;
      _balance = (data['balance'] is num) ? (data['balance'] as num).toInt() : 0;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('accessToken', data['accessToken']);
      await prefs.setString('refreshToken', data['refreshToken']);
      await prefs.setString('role', data['role']);
      await prefs.setString('phoneNumber', _phoneNumber);
      await prefs.setString('fullName', _fullName);
      await prefs.setBool('isVerified', _isVerified);
      await prefs.setInt('balance', _balance);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("OTP Verify Error: $e");
      return false;
    }
  }

  /// Refresh profile from backend (balance, verify status, etc.)
  Future<void> refreshProfile() async {
    try {
      final response = await _api.getMe();
      final data = response.data;

      _fullName = data['fullName'] ?? _fullName;
      _isVerified = data['isVerified'] ?? _isVerified;
      _balance = (data['balance'] is num) ? (data['balance'] as num).toInt() : _balance;
      _role = _parseRole(data['role'] ?? '');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', _fullName);
      await prefs.setBool('isVerified', _isVerified);
      await prefs.setInt('balance', _balance);
      await prefs.setString('role', data['role'] ?? '');
      notifyListeners();
    } catch (e) {
      debugPrint("Refresh profile error: $e");
    }
  }

  Future<void> updateProfile(String name) async {
    try {
      await _api.updateProfile(name);
      _fullName = name;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', name);
      notifyListeners();
    } catch (e) {
      // Fallback to local
      _fullName = name;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', name);
      notifyListeners();
    }
  }

  /// Verifikatsiya so'rovi — admin tasdiqlaydi, biz faqat refresh qilamiz
  Future<void> requestVerification() async {
    await refreshProfile();
  }

  Future<void> addBalance(int amount) async {
    // Balans faqat admin panel orqali to'ldiriladi
    // Bu method refreshProfile chaqiradi
    await refreshProfile();
  }

  Future<bool> deductBalance(int amount) async {
    if (_balance < amount) return false;
    _balance -= amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('balance', _balance);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _role = UserRole.NONE;
    _isVerified = false;
    _fullName = '';
    _phoneNumber = '';
    _balance = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  UserRole _parseRole(String role) {
    switch (role) {
      case 'INVESTOR': return UserRole.INVESTOR;
      case 'BEEKEEPER': return UserRole.BEEKEEPER;
      case 'ADMIN': return UserRole.ADMIN;
      default: return UserRole.NONE;
    }
  }
}
