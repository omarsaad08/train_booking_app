import 'package:dio/dio.dart';
import 'package:train_booking/data/token_storage.dart';

class AuthService {
  final TokenStorage _tokenStorage = TokenStorage();
  late final Dio _dio;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://4c1f348971bc.ngrok-free.app',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    // Add interceptor with debug logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip adding auth header for login and signup
          if (options.path != '/login' && options.path != '/signup.php') {
            final token = await _tokenStorage.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          
          // Debug logging for request
          debugLog('📤 REQUEST: ${options.method} ${options.baseUrl}${options.path}');
          debugLog('Headers: ${options.headers}');
          if (options.data != null) {
            debugLog('Request Data: ${options.data}');
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Debug logging for response
          debugLog('✅ RESPONSE: ${response.statusCode}');
          debugLog('Response Data: ${response.data}');
          handler.next(response);
        },
        onError: (e, handler) {
          // Debug logging for errors
          debugLog('❌ ERROR: ${e.type}');
          debugLog('Message: ${e.message}');
          if (e.response != null) {
            debugLog('Response Status: ${e.response?.statusCode}');
            debugLog('Response Data: ${e.response?.data}');
          }
          handler.next(e);
        },
      ),
    );
  }

  Future<Response> login(String email, String password) async {
    try {
      debugLog('\n🔓 LOGIN START');
      debugLog('Email: $email');
      
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      // Extract and store token and user_id from response
      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'];
        if (token != null) {
          await _tokenStorage.saveToken(token);
          debugLog('✅ Token saved');
        }
        final userId = response.data['user_id'];
        if (userId != null) {
          await _tokenStorage.saveUserId(
            userId is int ? userId : int.parse(userId.toString()),
          );
          debugLog('✅ User ID saved: $userId');
        }
      }

      debugLog('Login completed successfully');
      return response;
    } catch (e) {
      debugLog('Login failed: $e');
      rethrow;
    }
  }

  Future<Response> signup(String name, String email, String password) async {
    try {
      debugLog('\n🔐 SIGNUP START');
      debugLog('Name: $name');
      debugLog('Email: $email');
      
      final response = await _dio.post(
        '/signup',
        data: {'name': name, 'email': email, 'password': password},
      );

      // Extract and store token and user_id from response
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final token = response.data['token'];
        if (token != null) {
          await _tokenStorage.saveToken(token);
          debugLog('✅ Token saved');
        }
        final userId = response.data['user_id'];
        if (userId != null) {
          await _tokenStorage.saveUserId(
            userId is int ? userId : int.parse(userId.toString()),
          );
          debugLog('✅ User ID saved: $userId');
        }
      }

      debugLog('Signup completed successfully');
      return response;
    } catch (e) {
      debugLog('Signup failed: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    debugLog('\n🔑 LOGOUT');
    await _tokenStorage.clearAll();
    debugLog('Cleared all stored credentials');
  }

  void debugLog(String message) {
    print('[AuthService] $message');
  }
}

