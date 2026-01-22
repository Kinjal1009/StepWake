import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../domain/entities/alarm.dart';
import '../../core/preview.dart';

@Preview(name: 'AlarmItemWidget')
Widget previewAlarmItemWidget() {
  return PreviewWrapper(
    child: AlarmItemWidget(
      alarm: Alarm(
        id: '1',
        time: '06:57',
        label: 'Morning Workout',
        isEnabled: true,
        walkMinutes: 2,
        days: const [1, 2, 3, 4, 5],
        ringtoneUrl: '',
      ),
      onToggle: () {},
      onDelete: () {},
      onEdit: () {},
    ),
  );
}

class AlarmItemWidget extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AlarmItemWidget({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = alarm.isEnabled ? 1.0 : 0.4;
    final time12 = _getTime12hr(alarm.time);
    final ampm = _getAmPm(alarm.time);

    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        time12,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: opacity),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ampm,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: opacity * 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: alarm.isEnabled,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: Colors.indigoAccent,
                  activeTrackColor: Colors.indigoAccent.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.white.withValues(alpha: 0.2),
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.05),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${alarm.label.isEmpty ? "Alarm" : alarm.label} • ${alarm.walkMinutes} min walk',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: opacity * 0.6),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                _buildIconButton(Icons.edit, onEdit, opacity),
                const SizedBox(width: 8),
                _buildIconButton(Icons.delete, onDelete, opacity),
              ],
            ),
            const SizedBox(height: 16),
            _buildDaysRow(opacity),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, double opacity) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05 * opacity),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white.withValues(alpha: 0.4 * opacity),
        ),
      ),
    );
  }

  String _getTime12hr(String time) {
    final parts = time.split(':');
    var hour = int.parse(parts[0]);
    final minute = parts[1];
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute';
  }

  String _getAmPm(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    return hour < 12 ? 'AM' : 'PM';
  }

  Widget _buildDaysRow(double opacity) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayIndex = (index + 1) % 7;
        final isActive = alarm.days.contains(dayIndex);

        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.indigoAccent.withValues(alpha: opacity)
                : Colors.white.withValues(alpha: 0.05 * opacity),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            days[index],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3 * opacity),
            ),
          ),
        );
      }),
    );
  }
}

@UseCase(name: 'Default', type: AlarmItemWidget)
Widget buildAlarmItemWidgetUseCase(BuildContext context) {
  return AlarmItemWidget(
    alarm: Alarm(
      id: '1',
      time: '06:57',
      label: 'Morning Workout',
      isEnabled: true,
      walkMinutes: 2,
      days: const [1, 2, 3, 4, 5],
      ringtoneUrl: '',
    ),
    onToggle: () {},
    onDelete: () {},
    onEdit: () {},
  );
}
