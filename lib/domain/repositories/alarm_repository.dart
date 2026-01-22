import '../entities/alarm.dart';

abstract class AlarmRepository {
  Future<List<Alarm>> getAlarms();
  Future<void> saveAlarms(List<Alarm> alarms);
  Future<String> getGlobalRingtone();
  Future<void> saveGlobalRingtone(String url);
}
