import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'cache_service.dart';
import 'cache_keys.dart';

class ApiClient {
  // Base API URL https://teal-moose-685827.hostingersite.com/public/api     http://10.0.2.2:8000/api  
  static const String baseUrl =
      "http://10.0.2.2:8000/api";

  // Token storage
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }
  

  // Headers
 Future<Map<String, String>> _getHeaders({
  bool requireAuth = false,
}) async {
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',

    if (requireAuth && _token != null)
      'Authorization': 'Bearer $_token',
  };
}
  // GET Request
Future<dynamic> get(
  String endpoint, {
  bool requireAuth = false,
}) async {
  final url = Uri.parse('$baseUrl/$endpoint');

  final headers = await _getHeaders(
    requireAuth: requireAuth,
    
  );

  try {
    // print("URL: $url");
    debugPrint("Request Headers: $headers");

    final response = await http.get(
      url,
      headers: headers,
      
    );

    // print("Status Code: ${response.statusCode}");
    // print("Response Headers: ${response.headers}");
    // print("Response Body: ${response.body}");

    return _processResponse(response);
  } catch (e) {
    throw Exception(
      "Network connectivity failed: $e",
    );
  }
}

  // POST Request
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(
          requireAuth: requireAuth,

        ),
        body: jsonEncode(body),
      );
    
      return _processResponse(response);
    } on HttpException {
        rethrow;
      } on SocketException catch (e) {
        throw Exception(
          'Network connection failed: $e',
        );
      } catch (e) {
        rethrow;
      }
  }

  // PUT Request
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(
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

  // DELETE Request
 Future<dynamic> delete(
  String endpoint,
  Map<String, dynamic> body, {
  bool requireAuth = false,
}) async {
  final url = Uri.parse('$baseUrl/$endpoint');

  try {
    final response = await http.delete(
      url,
      headers: await _getHeaders(
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

  Future<dynamic> multipartPost(
  String endpoint,
  Map<String, String> fields,
  File? image, {
  bool requireAuth = false,
}) async {

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/$endpoint'),
  );

  request.headers.addAll(
    await _getHeaders(
      requireAuth: requireAuth,
    ),
  );

  request.fields.addAll(fields);

  if (image != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar',
        image.path,
      ),
    );
  }

  final streamed = await request.send();

  final response =
      await http.Response.fromStream(streamed);

  return _processResponse(response);
}

  // Handle Response
  dynamic _processResponse(http.Response response) {
    // print("Status Code: ${response.statusCode}");
    // print("Response Body: ${response.body}");

  if (response.body.isEmpty) {
    throw Exception("Empty response");
  }

  dynamic decoded;

  try {
    decoded = jsonDecode(response.body);
  } catch (_) {
    throw Exception("Server returned HTML instead of JSON:\n${response.body}");
  }

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

