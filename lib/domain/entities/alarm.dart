import 'package:equatable/equatable.dart';

class Alarm extends Equatable {
  final String id;
  final String time; // HH:mm format
  final String label;
  final bool isEnabled;
  final int walkMinutes;
  final List<int> days; // 0=Sun, 1=Mon, ..., 6=Sat
  final String ringtoneUrl;

  const Alarm({
    required this.id,
    required this.time,
    required this.label,
    required this.isEnabled,
    required this.walkMinutes,
    required this.days,
    required this.ringtoneUrl,
  });

  Alarm copyWith({
    String? id,
    String? time,
    String? label,
    bool? isEnabled,
    int? walkMinutes,
    List<int>? days,
    String? ringtoneUrl,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      walkMinutes: walkMinutes ?? this.walkMinutes,
      days: days ?? this.days,
      ringtoneUrl: ringtoneUrl ?? this.ringtoneUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    time,
    label,
    isEnabled,
    walkMinutes,
    days,
    ringtoneUrl,
  ];
}

enum AppMode { idle, ringing, challenge, settings }
