import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';

enum UserRole { INVESTOR, BEEKEEPER, ADMIN, NONE }

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  UserRole _role = UserRole.NONE;
  String _phoneNumber = '';
  final Dio _dio = Dio();

  bool get isAuthenticated => _isAuthenticated;
  UserRole get role => _role;
  String get phoneNumber => _phoneNumber;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
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
      // Mock role passing or backend handling
      // final response = await _dio.post(ApiConstants.verifyOtp, data: {'phone': _phoneNumber, 'otp': otp});
      // if (response.statusCode == 200) {
      
      _isAuthenticated = true;
      _role = selectedRole;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('role', selectedRole.name);
      notifyListeners();
      
    } catch (e) {
      debugPrint("OTP Verify Error: $e");
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _role = UserRole.NONE;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
