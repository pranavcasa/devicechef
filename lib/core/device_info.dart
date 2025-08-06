import 'package:flutter/services.dart';

class DeviceInfoHelper {
  static const platform = MethodChannel('device_info_channel');

  static Future<Map<String, String>> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic> info =
          await platform.invokeMethod('getDeviceInfo');
      return info.map((key, value) => MapEntry(key.toString(), value.toString()));
    } catch (e) {
      return {'model': 'Unknown', 'brand': 'Unknown'};
    }
  }
}
