import 'package:flutter/services.dart';

class ImagePickerHelper {
  static const platform = MethodChannel('image_picker_channel');

  static Future<String?> pickImage() async {
    try {
      final String? imagePath = await platform.invokeMethod('pickImage');
      return imagePath;
    } catch (e) {
      return null;
    }
  }
}
