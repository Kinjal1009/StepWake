import 'package:flutter/services.dart';

class NativeAlarmService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.step_wake/alarm',
  );

  /// Schedule an alarm natively
  /// [delayMillis] is milliseconds from NOW when the alarm should fire.
  static Future<void> scheduleAlarm(int id, int delayMillis) async {
    try {
      await _channel.invokeMethod('scheduleAlarm', {
        'id': id,
        'delayMillis': delayMillis,
      });
    } on PlatformException catch (e) {
      print("Failed to schedule alarm: '${e.message}'.");
    }
  }

  /// Stop the native alarm service (stop ringing)
  static Future<void> stopAlarm() async {
    try {
      await _channel.invokeMethod('stopAlarm');
    } on PlatformException catch (e) {
      print("Failed to stop alarm: '${e.message}'.");
    }
  }

  /// Check if app was launched via alarm
  /// Returns a map with 'triggered' and 'startChallenge' keys
  static Future<Map<String, dynamic>> checkLaunchIntent() async {
    try {
      final result = await _channel.invokeMethod('checkLaunchIntent');
      if (result is Map) {
        // Cast dynamic map from platform channel to Map<String, dynamic>
        return Map<String, dynamic>.from(result);
      }
      return {'triggered': false, 'startChallenge': false};
    } on PlatformException catch (e) {
      print("Failed to check launch intent: '${e.message}'.");
      return {'triggered': false, 'startChallenge': false};
    }
  }

  static void setMethodCallHandler(
    Future<dynamic> Function(MethodCall call)? handler,
  ) {
    _channel.setMethodCallHandler(handler);
  }
}
