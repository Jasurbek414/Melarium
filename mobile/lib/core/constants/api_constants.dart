class ApiConstants {
  // If running on an Android emulator, use 10.0.2.2.
  // If running on a physical device, use the computer's local IP address (e.g., 192.168.1.100).
  // If running on Web or Desktop, use localhost.
  static const String baseUrl = 'http://localhost:8080/api';
  
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String getColonies = '$baseUrl/colonies';
}
