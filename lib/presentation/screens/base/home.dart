import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:train_booking/data/booking_service.dart';
import 'package:train_booking/data/token_storage.dart';
import 'package:train_booking/presentation/components/custom_button.dart';
import 'package:train_booking/config/app_theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _bookingService = BookingService();
  final _tokenStorage = TokenStorage();

  // Hardcoded list of Egyptian cities
  final List<String> _egyptianCities = [
    'القاهرة',
    'الإسكندرية',
    'البحيرة',
    'دمياط',
    'الدقهلية',
    'الغربية',
    'المنوفية',
    'القليوبية',
    'كفر الشيخ',
    'الشرقية',
    'بورسعيد',
    'الإسماعيلية',
    'السويس',
    'شمال سيناء',
    'جنوب سيناء',
    'الفيوم',
    'بني سويف',
    'المنيا',
    'أسيوط',
    'سوهاج',
    'قنا',
    'الأقصر',
    'أسوان',
    'البحر الأحمر',
    'الوادي الجديد',
  ];

  // Static time slots
  final List<Map<String, String>> _timeSlots = [
    {'label': '12 صباحاً', 'departure': '00:00:00', 'arrival': '02:00:00'},
    {'label': '6 صباحاً', 'departure': '06:00:00', 'arrival': '08:00:00'},
    {'label': '12 ظهراً', 'departure': '12:00:00', 'arrival': '14:00:00'},
    {'label': '6 مساءً', 'departure': '18:00:00', 'arrival': '20:00:00'},
  ];

  String? _selectedFromCity;
  String? _selectedToCity;
  int? _selectedTimeSlotIndex;
  int? _userId;

  bool _isCreatingBooking = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    _userId = await _tokenStorage.getUserId();
  }

  Future<void> _createBooking() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ: لم يتم العثور على معرف المستخدم')),
      );
      return;
    }

    if (_selectedFromCity == null || _selectedToCity == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار المدينة')));
      return;
    }

    if (_selectedTimeSlotIndex == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار موعد')));
      return;
    }

    setState(() => _isCreatingBooking = true);

    try {
      final timeSlot = _timeSlots[_selectedTimeSlotIndex!];
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final scheduleTime = '$dateStr ${timeSlot['departure']}';

      // Create booking directly with all required fields
      final bookingResponse = await _bookingService.createBooking(
        userId: _userId!,
        fromCity: _selectedFromCity!,
        toCity: _selectedToCity!,
        scheduleTime: scheduleTime,
      );

      if (mounted) {
        if (bookingResponse.statusCode == 200 ||
            bookingResponse.statusCode == 201) {
          // Navigate to booking confirmation screen
          Navigator.of(context).pushNamed(
            'booking_confirmation',
            arguments: {
              'userId': _userId!,
              'fromCity': _selectedFromCity!,
              'toCity': _selectedToCity!,
              'scheduleTime': scheduleTime,
            },
          );
          // Reset selections
          setState(() {
            _selectedFromCity = null;
            _selectedToCity = null;
            _selectedTimeSlotIndex = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'فشل إنشاء الحجز: ${bookingResponse.statusMessage}',
              ),
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في الاتصال: ${e.message}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('حجز القطار', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, 'profile'),
            tooltip: 'الملف الشخصي',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // View Bookings Button
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, 'bookings_list'),
                icon: const Icon(Icons.history),
                label: const Text('حجوزاتي'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'اختر وجهتك',
              textAlign: TextAlign.center,
              style: AppTheme.headline2.copyWith(color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 30),

            // From City Dropdown
            _buildDropdown(
              label: 'من',
              value: _selectedFromCity,
              items: _egyptianCities,
              onChanged: (value) {
                setState(() {
                  _selectedFromCity = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // To City Dropdown
            _buildDropdown(
              label: 'إلى',
              value: _selectedToCity,
              items: _egyptianCities,
              onChanged: (value) {
                setState(() {
                  _selectedToCity = value;
                });
              },
            ),
            const SizedBox(height: 30),

            // Time Slots Section
            if (_selectedFromCity != null && _selectedToCity != null) ...[
              Text(
                'اختر موعد الرحلة',
                style: AppTheme.headline3.copyWith(color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _timeSlots.length,
                itemBuilder: (context, index) {
                  final timeSlot = _timeSlots[index];
                  final isSelected = _selectedTimeSlotIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeSlotIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.cardShadow,
                        border: isSelected
                            ? Border.all(color: AppTheme.primaryColor, width: 2)
                            : Border.all(color: AppTheme.dividerColor, width: 1),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  timeSlot['label']!,
                                  textAlign: TextAlign.center,
                                  style: AppTheme.headline3.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.primaryColor,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppTheme.convertTo12HourFormat(timeSlot['departure']!),
                                  textAlign: TextAlign.center,
                                  style: AppTheme.subtitle2.copyWith(
                                    color: isSelected
                                        ? Colors.white70
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: 'تأكيد الحجز',
                onPressed: _createBooking,
                isLoading: _isCreatingBooking,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.subtitle1.copyWith(color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            border: Border.all(color: AppTheme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'اختر $label',
                style: AppTheme.body2.copyWith(color: AppTheme.textSecondary),
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
