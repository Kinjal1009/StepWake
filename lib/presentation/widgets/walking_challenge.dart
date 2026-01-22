import 'dart:async';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../core/preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;
import 'package:alarm/alarm.dart';
import '../../core/services/ringtone_service.dart';

@Preview(name: 'WalkingChallenge')
Widget previewWalkingChallenge() {
  return PreviewWrapper(
    child: WalkingChallenge(requiredSeconds: 30, onComplete: () {}),
  );
}

class WalkingChallenge extends ConsumerStatefulWidget {
  final int requiredSeconds;
  final VoidCallback onComplete;

  const WalkingChallenge({
    super.key,
    required this.requiredSeconds,
    required this.onComplete,
  });

  @override
  ConsumerState<WalkingChallenge> createState() => _WalkingChallengeState();
}

class _WalkingChallengeState extends ConsumerState<WalkingChallenge> {
  late int _elapsedSeconds = 0;
  bool _isMoving = false;
  late StreamSubscription<UserAccelerometerEvent> _sensorSub;
  Timer? _timer;
  DateTime? _lastMotionTime;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    _sensorSub = userAccelerometerEvents.listen((event) {
      final magnitude = math.sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Threshold for "walking" motion
      if (magnitude > 1.8) {
        _lastMotionTime = DateTime.now();
        if (!_isMoving) {
          setState(() {
            _isMoving = true;
          });
        }
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      // Check if motion has stopped for more than 2 seconds
      if (_lastMotionTime != null &&
          now.difference(_lastMotionTime!).inSeconds > 2) {
        if (_isMoving) {
          setState(() {
            _isMoving = false;
            // The user wants "continue 30 sec".
            // Resetting progress if they stop moving.
            _elapsedSeconds = 0;
          });
        }
      }

      if (_isMoving) {
        setState(() {
          _elapsedSeconds++;
        });

        if (_elapsedSeconds >= widget.requiredSeconds) {
          _complete();
        }
      }
    });
  }

  void _complete() {
    _timer?.cancel();
    _sensorSub.cancel();
    ref.read(ringtoneServiceProvider).stop();
    Alarm.stopAll();
    widget.onComplete();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _elapsedSeconds / widget.requiredSeconds;
    final remaining = widget.requiredSeconds - _elapsedSeconds;

    return Container(
      color: const Color(0xFF020617),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'WALKING CHALLENGE',
            style: TextStyle(
              color: Colors.indigoAccent,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isMoving ? 'Keep moving!' : 'Motion stopped! Progress reset.',
            style: TextStyle(
              color: _isMoving ? Colors.greenAccent : Colors.redAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 64),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  color: _isMoving
                      ? Colors.indigoAccent
                      : Colors.redAccent.withValues(alpha: 0.3),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${remaining}s',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'TO GO',
                    style: TextStyle(
                      color: Colors.white38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 64),
          _buildMotionIndicator(),
        ],
      ),
    );
  }

  Widget _buildMotionIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: (_isMoving ? Colors.greenAccent : Colors.redAccent).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isMoving ? Icons.directions_run : Icons.pause,
            color: _isMoving ? Colors.greenAccent[400] : Colors.redAccent[400],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _isMoving ? 'WALKING DETECTED' : 'STATIONARY',
            style: TextStyle(
              color: _isMoving
                  ? Colors.greenAccent[400]
                  : Colors.redAccent[400],
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

@UseCase(name: 'Default', type: WalkingChallenge)
Widget buildWalkingChallengeUseCase(BuildContext context) {
  return WalkingChallenge(requiredSeconds: 30, onComplete: () {});
}
