import 'package:dio/dio.dart';
import 'package:train_booking/data/token_storage.dart';

class AuthService {
  final TokenStorage _tokenStorage = TokenStorage();
  late final Dio _dio;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.1.218:8080',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    // Add interceptor to attach Authorization header
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
          handler.next(options);
        },
      ),
    );
  }

  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      // Extract and store token and user_id from response
      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'];
        if (token != null) {
          await _tokenStorage.saveToken(token);
        }
        final userId = response.data['user_id'];
        if (userId != null) {
          await _tokenStorage.saveUserId(
            userId is int ? userId : int.parse(userId.toString()),
          );
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> signup(String name, String email, String password) async {
    try {
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
        }
        final userId = response.data['user_id'];
        if (userId != null) {
          await _tokenStorage.saveUserId(
            userId is int ? userId : int.parse(userId.toString()),
          );
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearAll();
  }
}
