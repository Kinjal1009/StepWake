import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../providers/alarm_provider.dart';
import '../../core/preview.dart';
import '../../core/services/ringtone_service.dart';

@Preview(name: 'RingingOverlay')
Widget previewRingingOverlay() {
  return PreviewWrapper(
    child: RingingOverlay(
      time: '06:57',
      label: 'Morning Workout',
      onStartChallenge: () {},
    ),
  );
}

class RingingOverlay extends ConsumerStatefulWidget {
  final String time;
  final String label;
  final VoidCallback onStartChallenge;

  const RingingOverlay({
    super.key,
    required this.time,
    required this.label,
    required this.onStartChallenge,
  });

  @override
  ConsumerState<RingingOverlay> createState() => _RingingOverlayState();
}

class _RingingOverlayState extends ConsumerState<RingingOverlay> {
  @override
  void initState() {
    super.initState();
    _playRingtone();
  }

  Future<void> _playRingtone() async {
    final ringtoneUrl = ref.read(appStateProvider).globalRingtone;
    ref.read(ringtoneServiceProvider).play(ringtoneUrl);
  }

  @override
  void dispose() {
    // We don't stop the player here because the ringtone should continue
    // through the WalkingChallenge until it is completed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020617).withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPulsingIcon(),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _getTimeOnly(widget.time),
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getPeriod(widget.time),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.label.isEmpty ? 'ALARM' : widget.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigoAccent,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 80),
          ElevatedButton(
            onPressed: widget.onStartChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigoAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              elevation: 20,
              shadowColor: Colors.indigoAccent.withValues(alpha: 0.5),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_walk),
                SizedBox(width: 12),
                Text(
                  'START WALKING',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.indigoAccent.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.alarm_on, size: 64, color: Colors.indigoAccent),
    );
  }

  String _getTimeOnly(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      return '${hour12.toString().padLeft(2, '0')}:$minute';
    } catch (e) {
      return time24;
    }
  }

  String _getPeriod(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      return hour >= 12 ? 'PM' : 'AM';
    } catch (e) {
      return '';
    }
  }
}

@UseCase(name: 'Default', type: RingingOverlay)
Widget buildRingingOverlayUseCase(BuildContext context) {
  return RingingOverlay(
    time: '06:57',
    label: 'Morning Workout',
    onStartChallenge: () {},
  );
}
