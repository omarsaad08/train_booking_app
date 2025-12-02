import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:train_booking/data/image_service.dart';
import 'package:train_booking/presentation/screens/base/image_editing.dart';
import 'package:train_booking/config/app_theme.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';

class BookingImagesScreen extends StatefulWidget {
  final int bookingId;
  final String fromCity;
  final String toCity;

  const BookingImagesScreen({
    super.key,
    required this.bookingId,
    required this.fromCity,
    required this.toCity,
  });

  @override
  State<BookingImagesScreen> createState() => _BookingImagesScreenState();
}

class _BookingImagesScreenState extends State<BookingImagesScreen> {
  final ImageService _imageService = ImageService();
  final ImagePicker _imagePicker = ImagePicker();
  late Future<List<Map<String, dynamic>>> _imagesFuture;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _imagesFuture = _loadImages();
  }

  Future<List<Map<String, dynamic>>> _loadImages() async {
    try {
      final response = await _imageService.getBookingImages(widget.bookingId);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final images = (response.data['data'] as List)
            .cast<Map<String, dynamic>>()
            .toList();
        return images;
      }
      return [];
    } catch (e) {
      print('Error loading images: $e');
      return [];
    }
  }

  Future<Uint8List?> _downloadImage(int imageId) async {
    try {
      final response = await _imageService.downloadImage(imageId);
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  Future<void> _pickAndEditImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null && mounted) {
        final imageFile = File(pickedFile.path);

        // Navigate to image editing screen
        final editedImage = await Navigator.push<File>(
          context,
          MaterialPageRoute(
            builder: (context) => ImageEditingScreen(
              imageFile: imageFile,
              bookingId: widget.bookingId,
            ),
          ),
        );

        if (editedImage != null && mounted) {
          // Upload the edited image
          await _uploadImage(editedImage);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() => _isUploadingImage = true);

    try {
      final imageName = 'booking_${widget.bookingId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await _imageService.uploadImage(
        bookingId: widget.bookingId,
        imageFile: imageFile,
        imageName: imageName,
      );

      if (mounted) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحميل الصورة بنجاح'),
              backgroundColor: AppTheme.successColor,
            ),
          );

          // Refresh images list
          setState(() {
            _imagesFuture = _loadImages();
          });
        } else {
          throw Exception('فشل تحميل الصورة');
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الاتصال: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _deleteImage(int imageId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الصورة'),
        content: const Text('هل أنت متأكد من حذف هذه الصورة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final response = await _imageService.deleteImage(imageId);
                if (mounted) {
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حذف الصورة بنجاح'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                    setState(() {
                      _imagesFuture = _loadImages();
                    });
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في الحذف: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('صور الرحلة', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trip Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'معلومات الرحلة',
                    style: AppTheme.subtitle1.copyWith(color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.toCity,
                        style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Icon(Icons.arrow_forward, color: AppTheme.accentColor),
                      Text(
                        widget.fromCity,
                        style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upload Button
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton.icon(
                onPressed: _isUploadingImage ? null : _pickAndEditImage,
                icon: _isUploadingImage
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add_photo_alternate),
                label: Text(
                  _isUploadingImage ? 'جاري التحميل...' : 'إضافة صورة',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Images List
            Text(
              'Saved Photos',
              style: AppTheme.headline3.copyWith(color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _imagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading images',
                      style: AppTheme.body2.copyWith(color: AppTheme.textSecondary),
                    ),
                  );
                }

                final images = snapshot.data ?? [];

                if (images.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: AppTheme.dividerColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No photos saved',
                          style: AppTheme.body1.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return _buildImageThumbnail(image);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(Map<String, dynamic> image) {
    return FutureBuilder<Response>(
      future: _imageService.downloadImage(image['id']),
      builder: (context, snapshot) {
        Widget imageWidget;
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          imageWidget = Container(
            color: AppTheme.surfaceColor,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          imageWidget = Container(
            color: AppTheme.surfaceColor,
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                color: AppTheme.dividerColor,
                size: 48,
              ),
            ),
          );
        } else {
          final imageBytes = snapshot.data!.data as Uint8List;
          imageWidget = Image.memory(
            imageBytes,
            fit: BoxFit.cover,
          );
        }

        return GestureDetector(
          onLongPress: () => _deleteImage(image['id']),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageWidget,
                ),
                // Delete button overlay on hover/long press
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.white, size: 18),
                      onPressed: () => _deleteImage(image['id']),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
