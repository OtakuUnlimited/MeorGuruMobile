import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // TOKEN STORAGE
  static String? _token;

  static void setToken(String token) {
    _token = token;
    print("TOKEN SET => $_token");
  }

  static void clearToken() {
    _token = null;
  }

  Map<String, String> _getHeaders({
    bool requireAuth = false,
  }) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (requireAuth && _token != null)
        'Authorization': 'Bearer $_token',
    };
  }

  Future<dynamic> get(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.get(
        url,
        headers: _getHeaders(
          requireAuth: requireAuth,
        ),
      );


      return _processResponse(response);
    } catch (e) {
      throw Exception(
        "Network connectivity failed: $e",
      );
    }
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');


    try {
      final response = await http.post(
        url,
        headers: _getHeaders(
          requireAuth: requireAuth,
        ),
        body: jsonEncode(body),
      );


      return _processResponse(response);
    } catch (e) {
      throw Exception(
        "Network request failed: $e",
      );
    }
  }

  dynamic _processResponse(
    http.Response response,
  ) {
    final decoded = jsonDecode(
      response.body,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return decoded;
    }

    throw HttpException(
      decoded is Map
      ? decoded['message'].toString()
      : response.body,
);
  }
}