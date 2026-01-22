import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm/alarm.dart' as sys_alarm;
import '../../data/repositories/alarm_repository_impl.dart';
import '../../domain/entities/alarm.dart' as entity;
import '../../domain/repositories/alarm_repository.dart';

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Will be overridden in main.dart
});

// Provider for Repository
final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return AlarmRepositoryImpl(sharedPreferences: sharedPrefs);
});

// StateNotifier for Alarms
class AlarmNotifier extends StateNotifier<List<entity.Alarm>> {
  final AlarmRepository repository;

  AlarmNotifier({required this.repository}) : super([]) {
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    state = await repository.getAlarms();
    _syncSystemAlarms();
  }

  Future<void> _syncSystemAlarms() async {
    final currentSystemAlarms = await sys_alarm.Alarm.getAlarms();
    for (final systemAlarm in currentSystemAlarms) {
      await sys_alarm.Alarm.stop(systemAlarm.id);
    }

    for (final alarm in state) {
      if (alarm.isEnabled) {
        await _scheduleSystemAlarm(alarm);
      }
    }
  }

  Future<void> _scheduleSystemAlarm(entity.Alarm alarm) async {
    final now = DateTime.now();
    final parts = alarm.time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (alarm.days.isEmpty) {
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    } else {
      int daysUntilNext = 8;
      final currentDay = now.weekday % 7;

      for (final day in alarm.days) {
        int diff = day - currentDay;
        if (diff < 0) diff += 7;
        if (diff == 0 && scheduledTime.isBefore(now)) diff = 7;
        if (diff < daysUntilNext) daysUntilNext = diff;
      }
      scheduledTime = scheduledTime.add(Duration(days: daysUntilNext));
    }

    final alarmSettings = sys_alarm.AlarmSettings(
      id: alarm.id.hashCode,
      dateTime: scheduledTime,
      assetAudioPath: 'assets/audio/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      volume: 0.8, // Use actual volume so alarm triggers properly
      fadeDuration: 0.0,
      androidFullScreenIntent: true,
      warningNotificationOnKill: true,
      notificationSettings: sys_alarm.NotificationSettings(
        title:
            'StepWake Alarm - ${alarm.label.isEmpty ? "Wake Up!" : alarm.label}',
        body: 'Time to wake up and walk!',
        stopButton: null,
        icon: 'notification_icon',
      ),
    );

    await sys_alarm.Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> addAlarm(entity.Alarm alarm) async {
    final newState = [...state, alarm];
    state = newState;
    await repository.saveAlarms(newState);
    await _syncSystemAlarms();
  }

  Future<void> updateAlarm(entity.Alarm alarm) async {
    final newState = state.map((a) => a.id == alarm.id ? alarm : a).toList();
    state = newState;
    await repository.saveAlarms(newState);
    await _syncSystemAlarms();
  }

  Future<void> deleteAlarm(String id) async {
    final newState = state.where((a) => a.id != id).toList();
    state = newState;
    await repository.saveAlarms(newState);
    await _syncSystemAlarms();
  }

  Future<void> toggleAlarm(String id) async {
    final alarm = state.firstWhere((a) => a.id == id);
    await updateAlarm(alarm.copyWith(isEnabled: !alarm.isEnabled));
  }
}

final alarmsProvider = StateNotifierProvider<AlarmNotifier, List<entity.Alarm>>(
  (ref) {
    final repository = ref.watch(alarmRepositoryProvider);
    return AlarmNotifier(repository: repository);
  },
);

class AppState {
  final entity.AppMode mode;
  final entity.Alarm? activeAlarm;
  final String globalRingtone;

  AppState({
    this.mode = entity.AppMode.idle,
    this.activeAlarm,
    required this.globalRingtone,
  });

  AppState copyWith({
    entity.AppMode? mode,
    entity.Alarm? activeAlarm,
    String? globalRingtone,
  }) {
    return AppState(
      mode: mode ?? this.mode,
      activeAlarm: activeAlarm ?? this.activeAlarm,
      globalRingtone: globalRingtone ?? this.globalRingtone,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  final AlarmRepository repository;

  AppStateNotifier({required this.repository})
    : super(
        AppState(
          globalRingtone:
              'https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg',
        ),
      ) {
    _loadRingtone();
  }

  Future<void> _loadRingtone() async {
    final ringtone = await repository.getGlobalRingtone();
    state = state.copyWith(globalRingtone: ringtone);
  }

  void setMode(entity.AppMode mode) => state = state.copyWith(mode: mode);
  void setActiveAlarm(entity.Alarm? alarm) =>
      state = state.copyWith(activeAlarm: alarm);

  Future<void> setRingtone(String url) async {
    await repository.saveGlobalRingtone(url);
    state = state.copyWith(globalRingtone: url);
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  final repository = ref.watch(alarmRepositoryProvider);
  return AppStateNotifier(repository: repository);
});
