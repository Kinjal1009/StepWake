import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../models/alarm_model.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final SharedPreferences sharedPreferences;

  AlarmRepositoryImpl({required this.sharedPreferences});

  static const String _alarmsKey = 'stepwake_alarms';
  static const String _ringtoneKey = 'stepwake_global_ringtone';

  @override
  Future<List<Alarm>> getAlarms() async {
    final jsonString = sharedPreferences.getString(_alarmsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => AlarmModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<void> saveAlarms(List<Alarm> alarms) async {
    final jsonList = alarms
        .map((e) => AlarmModel.fromEntity(e).toJson())
        .toList();
    await sharedPreferences.setString(_alarmsKey, json.encode(jsonList));
  }

  @override
  Future<String> getGlobalRingtone() async {
    return sharedPreferences.getString(_ringtoneKey) ??
        'https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg';
  }

  @override
  Future<void> saveGlobalRingtone(String url) async {
    await sharedPreferences.setString(_ringtoneKey, url);
  }
}
