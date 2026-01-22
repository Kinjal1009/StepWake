import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/alarm.dart';
import '../providers/alarm_provider.dart';
import '../../core/preview.dart';

@preview
class AddAlarmDialog extends ConsumerStatefulWidget {
  final Alarm? initialAlarm;

  const AddAlarmDialog({super.key, this.initialAlarm});

  @override
  ConsumerState<AddAlarmDialog> createState() => _AddAlarmDialogState();
}

class _AddAlarmDialogState extends ConsumerState<AddAlarmDialog> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late int _walkMinutes;
  late List<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    if (widget.initialAlarm != null) {
      final parts = widget.initialAlarm!.time.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      _labelController = TextEditingController(
        text: widget.initialAlarm!.label,
      );
      _walkMinutes = widget.initialAlarm!.walkMinutes;
      _selectedDays = List.from(widget.initialAlarm!.days);
    } else {
      _selectedTime = TimeOfDay.now();
      _labelController = TextEditingController();
      _walkMinutes = 2;
      _selectedDays = [0, 1, 2, 3, 4, 5, 6];
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _save() {
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    final alarm = Alarm(
      id: widget.initialAlarm?.id ?? const Uuid().v4(),
      time: timeStr,
      label: _labelController.text,
      isEnabled: widget.initialAlarm?.isEnabled ?? true,
      walkMinutes: _walkMinutes,
      days: _selectedDays,
      ringtoneUrl: widget.initialAlarm?.ringtoneUrl ?? '',
    );

    if (widget.initialAlarm != null) {
      ref.read(alarmsProvider.notifier).updateAlarm(alarm);
    } else {
      ref.read(alarmsProvider.notifier).addAlarm(alarm);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Color(0xFF0F172A)),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        top: MediaQuery.of(context).padding.top + 16,
        left: 32,
        right: 32,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.initialAlarm != null ? 'EDIT ALARM' : 'NEW ALARM',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _buildTimePicker(),
                  const SizedBox(height: 32),
                  _buildTextField(),
                  const SizedBox(height: 32),
                  _buildWalkChallengeSlider(),
                  const SizedBox(height: 32),
                  _buildDayPicker(),
                  const SizedBox(height: 48),
                  _buildSaveButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      child: Column(
        children: [
          Text(
            _selectedTime.format(context),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Text(
            'Tap to change time',
            style: TextStyle(
              color: Colors.indigoAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _labelController,
      decoration: InputDecoration(
        labelText: 'Alarm Label',
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.indigoAccent),
        ),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );
  }

  Widget _buildWalkChallengeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Walk Challenge',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '$_walkMinutes mins',
              style: const TextStyle(
                color: Colors.indigoAccent,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Slider(
          value: _walkMinutes.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: Colors.indigoAccent,
          onChanged: (val) => setState(() => _walkMinutes = val.toInt()),
        ),
      ],
    );
  }

  Widget _buildDayPicker() {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isActive = _selectedDays.contains(index);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isActive) {
                _selectedDays.remove(index);
              } else {
                _selectedDays.add(index);
              }
            });
          },
          child: Container(
            width:
                36, // Reduced from 40 to ensure it fits with 32px padding on each side
            height: 36,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.indigoAccent
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              dayNames[index][0],
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        shadowColor: Colors.indigoAccent.withValues(alpha: 0.5),
      ),
      child: const Text(
        'SAVE ALARM',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
      ),
    );
  }
}

@UseCase(name: 'Default', type: AddAlarmDialog)
Widget buildAddAlarmDialogUseCase(BuildContext context) {
  return const ProviderScope(child: AddAlarmDialog());
}
