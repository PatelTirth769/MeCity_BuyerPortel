import 'dart:convert';
import 'dart:io';
import 'dart:async' as async;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_exceptions.dart';

class ApiClient {
  static const Duration timeoutDuration = Duration(seconds: 15);
  final http.Client _client;

  // Singleton setup
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal({http.Client? client}) : _client = client ?? http.Client();

  // Optionally set this dynamically after login if needed
  String? _authToken;

  void setToken(String token) {
    _authToken = token;
  }

  void clearToken() {
    _authToken = null;
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders, {bool hasBody = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (hasBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      // Browsers forbid JavaScript from setting the Cookie header manually.
      // Web authentication uses Authorization; native clients may also send
      // the cookie expected by older backend middleware.
      if (!kIsWeb) {
        headers['Cookie'] = 'token=$_authToken';
      }
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: _buildHeaders(headers, hasBody: false))
          .timeout(timeoutDuration);
      return _processResponse(response);
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ HTTP ClientException (Network / CORS): $e');
      }
      throw NetworkException('Unable to connect to the server. Please try again.');

    } on SocketException {
      throw NetworkException('No Internet connection');
    } on async.TimeoutException {
      throw TimeoutException('Connection timed out');
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e.toString().contains('TimeoutException')) throw TimeoutException('Connection timed out');
      if (e.toString().contains('Failed to fetch') || e.toString().contains('ClientException')) {
        throw NetworkException('Unable to connect to the server. Please try again.');
      }
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<dynamic> post(String url, {dynamic body, Map<String, String>? headers}) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _buildHeaders(headers, hasBody: body != null),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);
      return _processResponse(response);
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ HTTP ClientException (Network / CORS): $e');
      }
      throw NetworkException('Unable to connect to the server. Please try again.');
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e.toString().contains('TimeoutException')) throw TimeoutException('Connection timed out');
      if (e.toString().contains('Failed to fetch') || e.toString().contains('ClientException')) {
        throw NetworkException('Unable to connect to the server. Please try again.');
      }
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<dynamic> put(String url, {dynamic body, Map<String, String>? headers}) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: _buildHeaders(headers, hasBody: body != null),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);
      return _processResponse(response);
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ HTTP ClientException (Network / CORS): $e');
      }
      throw NetworkException('Unable to connect to the server. Please try again.');
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e.toString().contains('TimeoutException')) throw TimeoutException('Connection timed out');
      if (e.toString().contains('Failed to fetch') || e.toString().contains('ClientException')) {
        throw NetworkException('Unable to connect to the server. Please try again.');
      }
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<dynamic> delete(String url, {Map<String, String>? headers}) async {
    try {
      final response = await _client
          .delete(Uri.parse(url), headers: _buildHeaders(headers, hasBody: false))
          .timeout(timeoutDuration);
      return _processResponse(response);

    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ HTTP ClientException (Network / CORS): $e');
      }
      throw NetworkException('Unable to connect to the server. Please try again.');
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e.toString().contains('TimeoutException')) throw TimeoutException('Connection timed out');
      if (e.toString().contains('Failed to fetch') || e.toString().contains('ClientException')) {
        throw NetworkException('Unable to connect to the server. Please try again.');
      }
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<dynamic> multipartPost(
    String url, {
    required Map<String, String> fields,
    List<int>? fileBytes,
    String? fileName,
    String fileField = 'file',
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(_buildHeaders(null));
      // Overwrite Content-Type for multipart
      request.headers.remove('Content-Type');

      request.fields.addAll(fields);

      if (fileBytes != null && fileName != null) {
        final multipartFile = http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: fileName,
          contentType: MediaType('image', 'png'), // Or infer from extension
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ HTTP ClientException (Network / CORS): $e');
      }
      throw NetworkException('Unable to connect to the server. Please try again.');
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e.toString().contains('TimeoutException')) throw TimeoutException('Connection timed out');
      if (e.toString().contains('Failed to fetch') || e.toString().contains('ClientException')) {
        throw NetworkException('Unable to connect to the server. Please try again.');
      }
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<dynamic> multipartPut(
    String url, {
    Map<String, String>? fields,
    List<int>? fileBytes,
    String? fileName,
    String fileField = 'image',
  }) async {
    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers.addAll(_buildHeaders(null));
      request.headers.remove('Content-Type');

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (fileBytes != null && fileName != null) {
        final multipartFile = http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: fileName,
          contentType: MediaType('image', fileName.endsWith('.png') ? 'png' : 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ HTTP ClientException (Network / CORS): $e');
      }
      throw NetworkException('Unable to connect to the server. Please try again.');
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e.toString().contains('TimeoutException')) throw TimeoutException('Connection timed out');
      if (e.toString().contains('Failed to fetch') || e.toString().contains('ClientException')) {
        throw NetworkException('Unable to connect to the server. Please try again.');
      }
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (kDebugMode) {
      print('📡 API Response: ${response.statusCode} -> ${response.request?.url}');
      if (response.body.isNotEmpty) {
        print('   Body: ${response.body}');
      }
    }

    dynamic responseJson;
    try {
      if (response.body.isNotEmpty) {
        responseJson = jsonDecode(response.body);
      }
    } catch (e) {
      responseJson = response.body;
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return responseJson;
      case 400:
        throw BadRequestException(
          _extractMessage(responseJson) ?? 'Bad request (400)',
          statusCode: response.statusCode,
          data: responseJson,
        );
      case 401:
      case 403:
        throw UnauthorizedException(
          _extractMessage(responseJson) ?? 'Unauthorized (401)',
          statusCode: response.statusCode,
          data: responseJson,
        );
      case 404:
        throw ApiException(
          _extractMessage(responseJson) ?? 'Resource not found (404)',
          statusCode: response.statusCode,
        );
      case 409:
        throw ConflictException(
          _extractMessage(responseJson) ?? 'User already exists (409)',
          statusCode: response.statusCode,
          data: responseJson,
        );
      case 422:
        throw ValidationException(
          _extractMessage(responseJson) ?? 'Validation error (422)',
          statusCode: response.statusCode,
          data: responseJson,
        );
      case 500:
      default:
        throw ServerException(
          _extractMessage(responseJson) ?? 'Server error occurred (${response.statusCode})',
          statusCode: response.statusCode,
          data: responseJson,
        );
    }
  }

  String? _extractMessage(dynamic json) {
    if (json is Map<String, dynamic>) {
      final msg = json['message'] ?? json['error'] ?? json['msg'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString();
      }
    } else if (json is String && json.trim().isNotEmpty) {
      final str = json.trim();
      if (str.startsWith('<!DOCTYPE') || str.startsWith('<html') || str.contains('Cannot POST') || str.contains('Cannot GET')) {
        return 'Requested service is currently unavailable.';
      }
      return str;
    }
    return null;
  }
}
