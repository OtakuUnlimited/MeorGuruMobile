// lib/backend/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  static const String tokenKey = 'auth_token';

  /// LOGIN
  Future<dynamic> login(
    String email,
    String password,
  ) async {
    final data = await _client.post(
      'userlogin',
      {
        'email': email,
        'password': password,
      },
    );

    print("LOGIN RESPONSE => $data");

    if (data['success'] == true &&
        data['data'] != null &&
        data['data']['token'] != null) {
      final token = data['data']['token'];

      print("TOKEN RECEIVED:");
      print(token);

      ApiClient.setToken(token);

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        tokenKey,
        token,
      );

      print("TOKEN SAVED");
      print(
        prefs.getString(tokenKey),
      );
    }

    return data;
  }

  /// REGISTER
  Future<dynamic> register({
  required String username,
  required String email,
  required String password,
  required String userType,
}) async {
  final result = await _client.post(
    'userregister',
    {
      'username': username,
      'email': email,
      'password': password,
      'user_type': userType,
    },
  );

  print("REGISTER RESPONSE:");
  print(result);

  return result;
}

  /// VERIFY OTP
  Future<dynamic> verifyOtp({
  required int userId,
  required String otp,
}) async {
  return await _client.post(
    'verification-code-submit/$userId',
    {
      'otp': otp,
    },
  );
}

Future<dynamic> resendOtp(int userId) async {
  return await _client.post(
    'resend-otp',
    {
      'user_id': userId,
    },
  );
}

  /// STORE BASIC DETAILS
  Future<dynamic> storeBasicDetails(
    Map<String, dynamic> details,
  ) async {
    return await _client.post(
      'store_basic_details',
      details,
    );
  }

  Future<dynamic> updateProfile(
  Map<String, dynamic> data,
  File? image,
) async {

  return _client.multipartPost(
    "guru_update_profile",
    data.map(
      (key, value) =>
          MapEntry(key, value.toString()),
    ),
    image,
    requireAuth: true,
  );
}

  /// GET USER PROFILE
  Future<dynamic> getProfile() async {
  return await _client.get(
    'user/get-profile',
    requireAuth: true,
  );
}

  /// CHANGE PASSWORD
  Future<dynamic> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _client.post(
      'change_password',
      {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation':
            confirmPassword,
      },
    );
  }

  /// CHECK LOGIN STATE
  static Future<bool> isLoggedIn() async {
    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString(tokenKey);

    return token != null &&
        token.isNotEmpty;
  }

  /// GET SAVED TOKEN
  static Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
      tokenKey,
    );
  }

  /// LOGOUT
  static Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);

    ApiClient.setToken('');
  }

  /// RESTORE TOKEN ON APP START
  static Future<void> initializeAuth() async {
  final prefs = await SharedPreferences.getInstance();

  final token = prefs.getString(tokenKey);

  print("RESTORED TOKEN => $token");

  if (token != null && token.isNotEmpty) {
    ApiClient.setToken(token);
  }
}

/// DELETE CURRENT ROLE / ACCOUNT
Future<dynamic> deleteCurrentRole() async {
  return await _client.post(
    'delete-current-role',
    {},
    requireAuth: true,
  );
}

Future<dynamic> forgotPassword(String email) async {
  final response = await _client.post(
    'user/forgot-password',
    {
      'email': email,
    },
  );
  debugPrint(
  '========== FORGOT PASSWORD RESPONSE ==========',
);

debugPrint(
  'Response type: ${response.runtimeType}',
);

debugPrint(
  'Full response: $response',
);
  return response;
}

Future<dynamic> resetPassword({
  required String email,
  required String otp,
  required String newPassword,
}) async {
  final response = await _client.post(
    'user/reset-password',
    {
      'email': email,
      'otp': otp,
      'new_password': newPassword,
    },
  );

  debugPrint(
    '========== RESET PASSWORD RESPONSE ==========',
  );

  debugPrint(
    'Response type: ${response.runtimeType}',
  );

  debugPrint(
    'Full response: $response',
  );

  return response;

}
}