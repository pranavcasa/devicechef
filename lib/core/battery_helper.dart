import 'package:flutter/services.dart';

class BatteryHelper {
  static const EventChannel _batteryStream = EventChannel('battery_stream');

  /// Returns a stream of maps: {"percentage": int, "status": String}
  static Stream<Map<String, dynamic>> get batteryStream {
    return _batteryStream.receiveBroadcastStream().map((event) {
      final map = Map<String, dynamic>.from(event as Map);
      return {
        "percentage": map["percentage"] ?? 0,
        "status": map["status"] ?? "Unknown"
      };
    });
  }
}
