import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/alarm.dart';
import '../domain/repositories/alarm_repository.dart';
import '../presentation/providers/alarm_provider.dart';

export 'package:flutter/widget_previews.dart';

/// Standard preview annotation for the Flutter Widget Preview tool.
/// You can use @Preview(name: '...') or simply @preview.
const preview = Preview();

class MockAlarmRepository implements AlarmRepository {
  @override
  Future<List<Alarm>> getAlarms() async => [];
  @override
  Future<void> saveAlarms(List<Alarm> alarms) async {}
  @override
  Future<String> getGlobalRingtone() async =>
      'https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg';
  @override
  Future<void> saveGlobalRingtone(String url) async {}
}

class PreviewWrapper extends StatelessWidget {
  final Widget child;
const PreviewWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        alarmRepositoryProvider.overrideWithValue(MockAlarmRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: child,
      ),
    );
  }
}
