import 'package:image/image.dart' as img;

void main() {
  // Create a test image
  final image = img.Image(width: 100, height: 100);
  
  // Test pixel operations
  print('Image methods containing Pixel:');
  final methods = image.runtimeType.toString();
  print('Type: $methods');
  
  // Try to access pixel
  final pixel = image.getPixel(0, 0);
  print('Pixel type: ${pixel.runtimeType}');
  print('Pixel methods: ${pixel.runtimeType}');
  
  // Test setting pixel
  try {
    image.setPixelRgba(0, 0, 255, 0, 0, 255);
    print('setPixelRgba works');
  } catch (e) {
    print('setPixelRgba error: $e');
    try {
      image.setPixelRgb(0, 0, 255, 0, 0);
      print('setPixelRgb works');
    } catch (e2) {
      print('setPixelRgb error: $e2');
    }
  }
}
