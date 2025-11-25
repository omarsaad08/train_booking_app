import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:train_booking/data/booking_service.dart';
import 'package:train_booking/data/token_storage.dart';
import 'package:train_booking/presentation/components/custom_button.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('حجز القطار', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اختر وجهتك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 15),
              ..._timeSlots.asMap().entries.map((entry) {
                final index = entry.key;
                final timeSlot = entry.value;
                final isSelected = _selectedTimeSlotIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeSlotIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.blue.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeSlot['label']!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'المغادرة: ${timeSlot['departure']} - الوصول: ${timeSlot['arrival']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Colors.blue.shade700,
                            size: 30,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'اختر $label',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
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
