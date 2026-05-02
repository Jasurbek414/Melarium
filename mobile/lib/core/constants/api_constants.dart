class ApiConstants {
  // ══════════════════════════════════════════════════════════
  // PUBLIC SERVER - bu yerga VPS/server public IP yozing
  // Masalan: http://95.130.227.100:8080/api
  // HTTPS bo'lsa: https://api.melarium.uz/api
  // ══════════════════════════════════════════════════════════
  static const String baseUrl = 'http://YOUR_SERVER_IP:8080/api';

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
