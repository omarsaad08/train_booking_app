import 'package:dio/dio.dart';
import 'package:train_booking/data/token_storage.dart';
import 'dart:convert';
import 'dart:io';

class ImageService {
  final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();
  final String _baseUrl = 'https://4c1f348971bc.ngrok-free.app';

  ImageService() : _dio = Dio(
    BaseOptions(
      baseUrl: 'https://4c1f348971bc.ngrok-free.app',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = token;
        }
        
        // Debug logging for request
        debugLog('📤 REQUEST: ${options.method} ${options.path}');
        debugLog('Headers: ${options.headers}');
        if (options.queryParameters.isNotEmpty) {
          debugLog('Query Params: ${options.queryParameters}');
        }
        if (options.data != null) {
          if (options.data is String) {
            debugLog('Data size: ${(options.data as String).length} characters');
          } else {
            debugLog('Data: ${options.data}');
          }
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Debug logging for response
        debugLog('✅ RESPONSE: ${response.statusCode}');
        debugLog('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (e, handler) {
        // Debug logging for errors
        debugLog('❌ ERROR: ${e.type}');
        debugLog('Message: ${e.message}');
        debugLog('Error: ${e.error}');
        if (e.response != null) {
          debugLog('Response Status: ${e.response?.statusCode}');
          debugLog('Response Data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response> uploadImage({
    required int bookingId,
    required File imageFile,
    required String imageName,
  }) async {
    try {
      debugLog('\n🖼️  UPLOAD IMAGE START');
      debugLog('Booking ID: $bookingId');
      debugLog('Image: $imageName');
      debugLog('File Size: ${await imageFile.length()} bytes');
      
      // Convert image file to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      debugLog('Base64 Size: ${base64Image.length} characters');

      // Prepare JSON data
      final jsonData = {
        'booking_id': bookingId,
        'image_data': base64Image,
        'image_name': imageName,
      };

      debugLog('Sending to: POST /images');

      // Upload image
      final response = await _dio.post(
        '/images',
        data: jsonEncode(jsonData),
      );

      debugLog('Upload completed successfully');
      return response;
    } on DioException catch (e) {
      debugLog('❌ Upload failed: ${e.message}');
      debugLog('Error: ${e.error}');
      debugLog('Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugLog('❌ Unexpected error: $e');
      rethrow;
    }
  }

  Future<Response> getBookingImages(int bookingId) async {
    try {
      debugLog('\n📸 GET BOOKING IMAGES START');
      debugLog('Booking ID: $bookingId');
      debugLog('Sending to: GET /images?booking_id=$bookingId');
      
      final response = await _dio.get(
        '/images',
        queryParameters: {
          'booking_id': bookingId,
        },
      );
      
      debugLog('Retrieved ${(response.data['data'] as List?)?.length ?? 0} images');
      return response;
    } on DioException catch (e) {
      debugLog('❌ Get images failed: ${e.message}');
      debugLog('Error: ${e.error}');
      debugLog('Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugLog('❌ Unexpected error: $e');
      rethrow;
    }
  }

  Future<Response> deleteImage(int imageId) async {
    try {
      debugLog('\n🗑️  DELETE IMAGE START');
      debugLog('Image ID: $imageId');
      debugLog('Sending to: DELETE /images');
      
      final response = await _dio.delete(
        '/images',
        data: jsonEncode({'image_id': imageId}),
      );
      
      debugLog('Image deleted successfully');
      return response;
    } on DioException catch (e) {
      debugLog('❌ Delete failed: ${e.message}');
      debugLog('Error: ${e.error}');
      debugLog('Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugLog('❌ Unexpected error: $e');
      rethrow;
    }
  }

  Future<Response> downloadImage(int imageId) async {
    try {
      debugLog('\n⬇️  DOWNLOAD IMAGE START');
      debugLog('Image ID: $imageId');
      debugLog('Sending to: GET /images?image_id=$imageId');
      
      final response = await _dio.get(
        '/images',
        queryParameters: {
          'image_id': imageId,
        },
        options: Options(responseType: ResponseType.bytes),
      );
      
      debugLog('Image downloaded successfully, size: ${response.data.length} bytes');
      return response;
    } on DioException catch (e) {
      debugLog('❌ Download failed: ${e.message}');
      debugLog('Error: ${e.error}');
      rethrow;
    } catch (e) {
      debugLog('❌ Unexpected error: $e');
      rethrow;
    }
  }

  void debugLog(String message) {
    print('[ImageService] $message');
  }
}
