import 'package:dio/dio.dart';
import 'package:train_booking/data/token_storage.dart';

class BookingService {
  final TokenStorage _tokenStorage = TokenStorage();
  late final Dio _dio;

  BookingService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://a38b964fe34e.ngrok-free.app',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    // Add interceptor to attach Authorization header and debug logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Debug logging for request
          debugLog('📤 REQUEST: ${options.method} ${options.baseUrl}${options.path}');
          debugLog('Headers: ${options.headers}');
          if (options.queryParameters.isNotEmpty) {
            debugLog('Query Params: ${options.queryParameters}');
          }
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

  Future<Response> getSchedules() async {
    try {
      debugLog('\n🚂 GET SCHEDULES START');
      final response = await _dio.get('/schedules');
      final dataCount = response.data is Map 
          ? ((response.data as Map)['data'] as List?)?.length ?? 0
          : (response.data as List?)?.length ?? 0;
      debugLog('Retrieved $dataCount schedules');
      return response;
    } catch (e) {
      debugLog('Get schedules failed: $e');
      rethrow;
    }
  }

  Future<Response> getUserBookings(int userId) async {
    try {
      debugLog('\n📋 GET USER BOOKINGS START');
      debugLog('User ID: $userId');
      final response = await _dio.get('/bookings?user_id=$userId');
      final dataCount = response.data is Map 
          ? ((response.data as Map)['data'] as List?)?.length ?? 0
          : (response.data as List?)?.length ?? 0;
      debugLog('Retrieved $dataCount bookings');
      return response;
    } catch (e) {
      debugLog('Get user bookings failed: $e');
      rethrow;
    }
  }

  Future<Response> createSchedule({
    required String fromCity,
    required String toCity,
    required String departureDateTime,
    required String arrivalDateTime,
  }) async {
    try {
      debugLog('\n➕ CREATE SCHEDULE START');
      debugLog('From: $fromCity → To: $toCity');
      debugLog('Departure: $departureDateTime');
      debugLog('Arrival: $arrivalDateTime');
      
      final response = await _dio.post(
        '/schedules',
        data: {
          'from_city': fromCity,
          'to_city': toCity,
          'departure_datetime': departureDateTime,
          'arrival_datetime': arrivalDateTime,
        },
      );
      
      debugLog('Schedule created successfully');
      return response;
    } catch (e) {
      debugLog('Create schedule failed: $e');
      rethrow;
    }
  }

  Future<Response> createBooking({
    required int userId,
    required String fromCity,
    required String toCity,
    required String scheduleTime,
  }) async {
    try {
      debugLog('\n🎫 CREATE BOOKING START');
      debugLog('User ID: $userId');
      debugLog('Route: $fromCity → $toCity');
      debugLog('Schedule Time: $scheduleTime');
      
      final response = await _dio.post(
        '/bookings',
        data: {
          'user_id': userId,
          'from_city': fromCity,
          'to_city': toCity,
          'schedule_time': scheduleTime,
        },
      );
      
      debugLog('Booking created successfully');
      return response;
    } catch (e) {
      debugLog('Create booking failed: $e');
      rethrow;
    }
  }

  void debugLog(String message) {
    print('[BookingService] $message');
  }
}
