import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:train_booking/config/app_theme.dart';
import 'package:image/image.dart' as img;

class ImageEditingScreen extends StatefulWidget {
  final File imageFile;
  final int bookingId;

  const ImageEditingScreen({
    super.key,
    required this.imageFile,
    required this.bookingId,
  });

  @override
  State<ImageEditingScreen> createState() => _ImageEditingScreenState();
}

class _ImageEditingScreenState extends State<ImageEditingScreen> {
  late File _originalImage;
  Uint8List? _filteredImageBytes;
  String _selectedFilter = 'none';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _originalImage = widget.imageFile;
  }

  Future<void> _applyFilter(String filterName) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final bytes = await _originalImage.readAsBytes();
      var image = img.decodeImage(bytes);

      if (image == null) return;

      // Apply filter based on selection
      switch (filterName) {
        case 'grayscale':
          image = img.grayscale(image);
          break;
        case 'sepia':
          image = _applySepiaEffect(image);
          break;
        case 'blue':
          image = _applyBlueEffect(image);
          break;
        case 'warm':
          image = _applyWarmEffect(image);
          break;
        case 'none':
        default:
          // No filter
          break;
      }

      // Encode to JPEG
      _filteredImageBytes = Uint8List.fromList(img.encodeJpg(image, quality: 90));

      setState(() {
        _selectedFilter = filterName;
      });
    } catch (e) {
      print('Error applying filter: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  img.Image _applySepiaEffect(img.Image image) {
    // Apply sepia filter using image package
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Sepia formula
        final newR = (0.393 * r + 0.769 * g + 0.189 * b).clamp(0, 255).toInt();
        final newG = (0.349 * r + 0.686 * g + 0.168 * b).clamp(0, 255).toInt();
        final newB = (0.272 * r + 0.534 * g + 0.131 * b).clamp(0, 255).toInt();

        image.setPixelRgba(x, y, newR, newG, newB, pixel.a);
      }
    }
    return image;
  }

  img.Image _applyBlueEffect(img.Image image) {
    // Apply blue filter
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Increase blue, decrease red
        final newR = (r * 0.7).clamp(0, 255).toInt();
        final newG = (g * 0.8).clamp(0, 255).toInt();
        final newB = (b * 1.2).clamp(0, 255).toInt();

        image.setPixelRgba(x, y, newR, newG, newB, pixel.a);
      }
    }
    return image;
  }

  img.Image _applyWarmEffect(img.Image image) {
    // Apply warm filter
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Increase red and green, decrease blue
        final newR = (r * 1.2).clamp(0, 255).toInt();
        final newG = (g * 1.1).clamp(0, 255).toInt();
        final newB = (b * 0.8).clamp(0, 255).toInt();

        image.setPixelRgba(x, y, newR, newG, newB, pixel.a);
      }
    }
    return image;
  }

  Future<void> _saveAndReturn() async {
    File fileToReturn = _originalImage;

    // If a filter was applied, save the filtered image to a temporary file
    if (_filteredImageBytes != null) {
      try {
        final tempDir = Directory.systemTemp;
        final tempFile = File(
            '${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(_filteredImageBytes!);
        fileToReturn = tempFile;
      } catch (e) {
        print('Error saving filtered image: $e');
      }
    }

    if (mounted) {
      Navigator.pop(context, fileToReturn);
    }
  }

  void _showFilterInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات المرشحات'),
        content: const Text(
          'المرشحات التالية متاحة:\n\n'
          '• Normal - بدون مرشحات\n'
          '• Grayscale - صورة بالأبيض والأسود\n'
          '• Sepia - تأثير قديم\n'
          '• Blue - درجات زرقاء\n'
          '• Warm - درجات دافئة',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
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
        title: const Text('تحرير الصورة', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.elevatedShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _filteredImageBytes != null
                    ? Image.memory(
                        _filteredImageBytes!,
                        fit: BoxFit.cover,
                        height: 300,
                      )
                    : Image.file(
                        _originalImage,
                        fit: BoxFit.cover,
                        height: 300,
                      ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Edit Options Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  onPressed: _showFilterInfo,
                ),
                Text(
                  'الفلاتر',
                  style: AppTheme.headline3.copyWith(color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter Selection
            Text(
              'الفلاتر والألوان',
              style: AppTheme.subtitle1.copyWith(color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 12),
            _isProcessing
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip('Normal', 'none'),
                      _buildFilterChip('Grayscale', 'grayscale'),
                      _buildFilterChip('Sepia', 'sepia'),
                      _buildFilterChip('Blue', 'blue'),
                      _buildFilterChip('Warm', 'warm'),
                    ],
                  ),
            const SizedBox(height: 24),

            // Info Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                'اختر المرشح المفضل لديك - يمكنك حفظ الصورة بالمرشح المختار',
                style: AppTheme.body2.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('إلغاء'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _saveAndReturn,
                      icon: const Icon(Icons.check),
                      label: const Text('حفظ'),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _applyFilter(filter);
        }
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
        width: isSelected ? 2 : 1,
      ),
    );
  }
}

