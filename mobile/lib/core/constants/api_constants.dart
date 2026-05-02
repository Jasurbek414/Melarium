class ApiConstants {
  // Android emulator uchun: 10.0.2.2, real telefon uchun: kompyuter IP
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // Auth
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String refreshToken = '$baseUrl/auth/refresh';

  // User
  static const String userMe = '$baseUrl/users/me';
  static const String userProfile = '$baseUrl/users/me/profile';

  // Colonies
  static const String colonies = '$baseUrl/colonies';

  // Investments
  static const String investments = '$baseUrl/investments';
  static const String myInvestments = '$baseUrl/investments/my';
}
