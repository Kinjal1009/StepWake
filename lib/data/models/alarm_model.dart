import '../../domain/entities/alarm.dart';

class AlarmModel extends Alarm {
  const AlarmModel({
    required super.id,
    required super.time,
    required super.label,
    required super.isEnabled,
    required super.walkMinutes,
    required super.days,
    required super.ringtoneUrl,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      time: json['time'],
      label: json['label'],
      isEnabled: json['isEnabled'],
      walkMinutes: json['walkMinutes'],
      days: List<int>.from(json['days']),
      ringtoneUrl: json['ringtoneUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'label': label,
      'isEnabled': isEnabled,
      'walkMinutes': walkMinutes,
      'days': days,
      'ringtoneUrl': ringtoneUrl,
    };
  }

  factory AlarmModel.fromEntity(Alarm alarm) {
    return AlarmModel(
      id: alarm.id,
      time: alarm.time,
      label: alarm.label,
      isEnabled: alarm.isEnabled,
      walkMinutes: alarm.walkMinutes,
      days: alarm.days,
      ringtoneUrl: alarm.ringtoneUrl,
    );
  }
}
