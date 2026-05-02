import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  Future<String?> get _accessToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<Options> _authHeaders() async {
    final token = await _accessToken;
    return Options(headers: token != null ? {'Authorization': 'Bearer $token'} : {});
  }

  // ── AUTH ─────────────────────────────────
  Future<Response> sendOtp(String phone) =>
      _dio.post(ApiConstants.sendOtp, data: {'phone': phone});

  Future<Response> verifyOtp(String phone, String otpCode) =>
      _dio.post(ApiConstants.verifyOtp, data: {'phone': phone, 'otpCode': otpCode});

  Future<Response> refreshToken(String refreshToken) =>
      _dio.post(ApiConstants.refreshToken, data: {'refreshToken': refreshToken});

  // ── USER ─────────────────────────────────
  Future<Response> getMe() async =>
      _dio.get(ApiConstants.userMe, options: await _authHeaders());

  Future<Response> updateProfile(String fullName) async =>
      _dio.put(ApiConstants.userProfile, data: {'fullName': fullName}, options: await _authHeaders());

  // ── COLONIES ─────────────────────────────
  Future<Response> getColonies({int page = 0, int size = 20}) async =>
      _dio.get(ApiConstants.colonies, queryParameters: {'page': page, 'size': size}, options: await _authHeaders());

  Future<Response> getColonyById(int id) async =>
      _dio.get('${ApiConstants.colonies}/$id', options: await _authHeaders());

  Future<Response> createColony(Map<String, dynamic> data) async =>
      _dio.post(ApiConstants.colonies, data: data, options: await _authHeaders());

  // ── INVESTMENTS ──────────────────────────
  Future<Response> invest(Map<String, dynamic> data) async =>
      _dio.post(ApiConstants.investments, data: data, options: await _authHeaders());

  Future<Response> getMyInvestments({int page = 0, int size = 20}) async =>
      _dio.get(ApiConstants.myInvestments, queryParameters: {'page': page, 'size': size}, options: await _authHeaders());
}
