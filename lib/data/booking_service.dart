import 'package:dio/dio.dart';
import 'package:train_booking/data/token_storage.dart';

class BookingService {
  final TokenStorage _tokenStorage = TokenStorage();
  late final Dio _dio;

  BookingService() {
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
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Response> getSchedules() async {
    try {
      final response = await _dio.get('/schedules');
      return response;
    } catch (e) {
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
      final response = await _dio.post(
        '/schedules',
        data: {
          'from_city': fromCity,
          'to_city': toCity,
          'departure_datetime': departureDateTime,
          'arrival_datetime': arrivalDateTime,
        },
      );
      return response;
    } catch (e) {
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
      final response = await _dio.post(
        '/bookings',
        data: {
          'user_id': userId,
          'from_city': fromCity,
          'to_city': toCity,
          'schedule_time': scheduleTime,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
