import 'package:flutter/material.dart';
import 'package:train_booking/data/booking_service.dart';
import 'package:train_booking/data/token_storage.dart';
import 'package:intl/intl.dart';
import 'package:train_booking/config/app_theme.dart';

class BookingsList extends StatefulWidget {
  const BookingsList({super.key});

  @override
  State<BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<BookingsList> {
  final _bookingService = BookingService();
  final _tokenStorage = TokenStorage();
  late Future<List<Map<String, dynamic>>> _bookingsFuture;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _userId = null;
    _bookingsFuture = _initializeBookings();
  }

  Future<List<Map<String, dynamic>>> _initializeBookings() async {
    _userId = await _tokenStorage.getUserId();
    if (_userId != null) {
      return await _fetchBookings();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    try {
      if (_userId == null) {
        throw Exception('User ID not found');
      }
      
      final response = await _bookingService.getUserBookings(_userId!);
      
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        
        if (data['data'] is List) {
          final bookings = (data['data'] as List)
              .cast<Map<String, dynamic>>()
              .toList();
          return bookings;
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'حجوزاتي',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.right,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ في تحميل الحجوزات',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد حجوزات',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final fromCity = booking['from_city'] ?? 'غير معروف';
    final toCity = booking['to_city'] ?? 'غير معروف';
    final scheduleTime = booking['schedule_time'] ?? '';
    final bookingTime = booking['booking_time'] ?? '';

    DateTime? parsedScheduleTime;
    DateTime? parsedBookingTime;

    try {
      if (scheduleTime.isNotEmpty) {
        parsedScheduleTime = DateTime.parse(scheduleTime);
      }
      if (bookingTime.isNotEmpty) {
        parsedBookingTime = DateTime.parse(bookingTime);
      }
    } catch (e) {
      // Handle date parsing errors
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.surfaceColor,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Header with cities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        toCity,
                        style: AppTheme.subtitle1.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الوجهة',
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: AppTheme.accentColor,
                    size: 24,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fromCity,
                        style: AppTheme.subtitle1.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'من',
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                color: AppTheme.dividerColor,
              ),
              const SizedBox(height: 16),
              // Schedule time in 12-hour format
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (parsedScheduleTime != null)
                    Text(
                      AppTheme.convertTo12HourFormat(
                        '${parsedScheduleTime.hour.toString().padLeft(2, '0')}:${parsedScheduleTime.minute.toString().padLeft(2, '0')}:00',
                      ),
                      style: AppTheme.body1.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      'غير معروف',
                      style: AppTheme.body2.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  Text(
                    'وقت المغادرة',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Date (keep in Arabic format YYYY-MM-DD)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (parsedScheduleTime != null)
                    Text(
                      DateFormat('yyyy-MM-dd').format(parsedScheduleTime),
                      style: AppTheme.body1.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      'غير معروف',
                      style: AppTheme.body2.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  Text(
                    'التاريخ',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Booking date and time in 12-hour format
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (parsedBookingTime != null)
                    Text(
                      '${DateFormat('yyyy-MM-dd').format(parsedBookingTime)} ${AppTheme.convertTo12HourFormat('${parsedBookingTime.hour.toString().padLeft(2, '0')}:${parsedBookingTime.minute.toString().padLeft(2, '0')}:00')}',
                      style: AppTheme.body2.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    )
                  else
                    Text(
                      'غير معروف',
                      style: AppTheme.body2.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  Text(
                    'تاريخ الحجز',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // View/Upload Images Button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        'booking_images',
                        arguments: {
                          'bookingId': booking['id'],
                          'fromCity': fromCity,
                          'toCity': toCity,
                        },
                      );
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('صور الرحلة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
