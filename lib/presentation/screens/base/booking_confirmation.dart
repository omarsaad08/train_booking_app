import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:train_booking/config/app_theme.dart';

class BookingConfirmation extends StatefulWidget {
  final int userId;
  final String fromCity;
  final String toCity;
  final String scheduleTime;

  const BookingConfirmation({
    super.key,
    required this.userId,
    required this.fromCity,
    required this.toCity,
    required this.scheduleTime,
  });

  @override
  State<BookingConfirmation> createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isExporting = false;

  Future<void> _exportTicket() async {
    setState(() => _isExporting = true);

    try {
      final image = await _screenshotController.capture();

      if (image != null) {
        // Save the image to gallery using gal package
        // gal.putImage expects a file path as String
        final tempDir = await getTemporaryDirectory();
        final imagePath = '${tempDir.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png';
        
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        
        await Gal.putImage(imagePath);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ التذكرة في المعرض'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التصدير: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Success message
            Text(
              'تم إنشاء الحجز بنجاح!',
              style: AppTheme.headline2.copyWith(color: AppTheme.primaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Ticket preview
            Screenshot(
              controller: _screenshotController,
              child: _buildTicket(),
            ),
            const SizedBox(height: 40),
            // Export button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _exportTicket,
                  icon: _isExporting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    _isExporting ? 'جاري التصدير...' : 'تصدير التذكرة',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    shadowColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Back to home button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    'home',
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'العودة للصفحة الرئيسية',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicket() {
    try {
      final dateTime = DateTime.parse(widget.scheduleTime);
      final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
      final timeInHours = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:00';
      final formattedTime = AppTheme.convertTo12HourFormat(timeInHours);

    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'تذكرة القطار',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  'حجز رقم: #${widget.userId}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTicketRow('المسافر', 'رقم المستخدم: ${widget.userId}'),
                const SizedBox(height: 15),
                _buildTicketRow('من', widget.fromCity),
                const SizedBox(height: 15),
                _buildTicketRow('إلى', widget.toCity),
                const SizedBox(height: 15),
                _buildTicketRow('التاريخ', formattedDate),
                const SizedBox(height: 15),
                _buildTicketRow('الوقت', formattedTime),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: AppTheme.dividerColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'شكراً لاختيارك خدماتنا',
                  style: AppTheme.body2.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    } catch (e) {
      return Center(
        child: Text('Error formatting date: $e'),
      );
    }
  }

  Widget _buildTicketRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: AppTheme.body1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: AppTheme.body2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
