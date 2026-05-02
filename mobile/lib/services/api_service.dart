import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android emulator → localhost

  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = Hive.box('auth').get('accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          try {
            final refreshToken = Hive.box('auth').get('refreshToken');
            final resp = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
            final newToken = resp.data['accessToken'];
            await Hive.box('auth').put('accessToken', newToken);
            e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            handler.resolve(await _dio.fetch(e.requestOptions));
            return;
          } catch (_) {
            await Hive.box('auth').clear();
          }
        }
        handler.next(e);
      },
    ));
  }

  // ── AUTH ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final resp = await _dio.post('/auth/send-otp', data: {'phone': phone});
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otpCode) async {
    final resp = await _dio.post('/auth/verify-otp', data: {'phone': phone, 'otpCode': otpCode});
    return resp.data as Map<String, dynamic>;
  }

  // ── COLONIES ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getColonies({int page = 0, int size = 12, String? location, String? status}) async {
    final resp = await _dio.get('/colonies', queryParameters: {
      'page': page, 'size': size,
      if (location != null) 'location': location,
      if (status != null) 'status': status,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getColonyById(String id) async {
    final resp = await _dio.get('/colonies/$id');
    return resp.data as Map<String, dynamic>;
  }

  // ── INVESTMENTS ───────────────────────────────────────────
  Future<Map<String, dynamic>> buyShares(int colonyId, int sharesCount) async {
    final resp = await _dio.post('/investments', data: {
      'colonyId': colonyId,
      'sharesCount': sharesCount,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyPortfolio({int page = 0, int size = 20}) async {
    final resp = await _dio.get('/investments/my', queryParameters: {'page': page, 'size': size});
    return resp.data as Map<String, dynamic>;
  }
}

final apiService = ApiService();
