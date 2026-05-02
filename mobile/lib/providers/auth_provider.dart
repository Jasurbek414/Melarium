import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';

enum UserRole { INVESTOR, BEEKEEPER, ADMIN, NONE }

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  UserRole _role = UserRole.NONE;
  String _phoneNumber = '';
  String _fullName = '';
  bool _isVerified = false;
  final Dio _dio = Dio();

  bool get isAuthenticated => _isAuthenticated;
  UserRole get role => _role;
  String get phoneNumber => _phoneNumber;
  String get fullName => _fullName;
  bool get isVerified => _isVerified;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _isVerified = prefs.getBool('isVerified') ?? false;
    _phoneNumber = prefs.getString('phoneNumber') ?? '';
    _fullName = prefs.getString('fullName') ?? '';
    final roleStr = prefs.getString('role');
    if (roleStr == 'INVESTOR') _role = UserRole.INVESTOR;
    else if (roleStr == 'BEEKEEPER') _role = UserRole.BEEKEEPER;
    else if (roleStr == 'ADMIN') _role = UserRole.ADMIN;
    notifyListeners();
  }

  Future<void> sendOtp(String phone) async {
    _phoneNumber = phone;
    try {
      await _dio.post(ApiConstants.sendOtp, data: {'phone': phone});
    } catch (e) {
      debugPrint("OTP Send Error: $e");
    }
  }

  Future<void> verifyOtp(String otp, UserRole selectedRole) async {
    try {
      _isAuthenticated = true;
      _role = selectedRole;
      _isVerified = false; // Yangi foydalanuvchi — hali tasdiqlanmagan

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setBool('isVerified', false);
      await prefs.setString('role', selectedRole.name);
      await prefs.setString('phoneNumber', _phoneNumber);
      notifyListeners();
    } catch (e) {
      debugPrint("OTP Verify Error: $e");
    }
  }

  Future<void> updateProfile(String name) async {
    _fullName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', name);
    notifyListeners();
  }

  /// Verifikatsiya so'rovi (backend bilan integratsiya uchun)
  Future<void> requestVerification() async {
    // Backend integratsiyasida bu yerda hujjatlar yuboriladi
    // Hozircha mock — 2 soniyadan keyin tasdiqlaydi
    await Future.delayed(const Duration(seconds: 2));
    _isVerified = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVerified', true);
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _role = UserRole.NONE;
    _isVerified = false;
    _fullName = '';
    _phoneNumber = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
