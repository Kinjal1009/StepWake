import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../core/preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;
import '../../services/native_alarm_service.dart';
import '../../core/services/ringtone_service.dart';
import '../providers/alarm_provider.dart';
import '../../domain/entities/alarm.dart';

@Preview(name: 'WalkingChallengeScreen')
Widget previewWalkingChallengeScreen() {
  return const PreviewWrapper(child: WalkingChallengeScreen());
}

/// Standalone full-screen walking challenge page
/// Works across iOS, Android, and Web
class WalkingChallengeScreen extends ConsumerStatefulWidget {
  const WalkingChallengeScreen({super.key});

  @override
  ConsumerState<WalkingChallengeScreen> createState() =>
      _WalkingChallengeScreenState();
}

class _WalkingChallengeScreenState
    extends ConsumerState<WalkingChallengeScreen> {
  int _elapsedSeconds = 0;
  bool _isMoving = false;
  StreamSubscription<UserAccelerometerEvent>? _sensorSub;
  Timer? _timer;
  DateTime? _lastMotionTime;
  int _requiredSeconds = 30;
  bool _hasLoadedDuration = false;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedDuration) {
      _loadRequiredSeconds();
      _hasLoadedDuration = true;
    }
  }

  void _loadRequiredSeconds() {
    final activeAlarm = ref.read(appStateProvider).activeAlarm;
    if (activeAlarm != null) {
      setState(() {
        _requiredSeconds = activeAlarm.walkMinutes * 60;
      });
      print(
        'Loaded walk duration: ${activeAlarm.walkMinutes} minutes ($_requiredSeconds seconds)',
      );
    } else {
      print(
        'No active alarm found, using default duration: $_requiredSeconds seconds',
      );
    }
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
            // Reset progress if they stop moving
            _elapsedSeconds = 0;
          });
        }
      }

      if (_isMoving) {
        setState(() {
          _elapsedSeconds++;
        });

        if (_elapsedSeconds >= _requiredSeconds) {
          _complete();
        }
      }
    });
  }

  Future<void> _complete() async {
    _timer?.cancel();
    _sensorSub?.cancel();
    ref.read(ringtoneServiceProvider).stop();

    final activeAlarm = ref.read(appStateProvider).activeAlarm;

    // Stop the native alarm sound
    await NativeAlarmService.stopAlarm();

    if (activeAlarm != null) {
      // Handle rescheduling or disabling based on recurrence
      await ref.read(alarmsProvider.notifier).handleAlarmFinished(activeAlarm);
    } else {
      // Fallback
      await NativeAlarmService.stopAlarm();
    }

    ref.read(appStateProvider.notifier).setMode(AppMode.idle);
    ref.read(appStateProvider.notifier).setActiveAlarm(null);

    if (mounted) {
      // Close the app instead of navigating to home
      SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorSub?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _elapsedSeconds / _requiredSeconds;
    final remaining = _requiredSeconds - _elapsedSeconds;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                const Text(
                  'ALARM RINGING',
                  style: TextStyle(
                    color: Color(0xFFEF4444), // Red 500
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'WALK TO STOP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CircularProgressIndicator(
                            value: 1.0 - progress, // Countdown style
                            strokeWidth: 20,
                            backgroundColor: const Color(
                              0xFF1E293B,
                            ), // Slate 800
                            color: _isMoving
                                ? const Color(0xFF34D399) // Emerald 400
                                : const Color(
                                    0xFF1E293B,
                                  ), // dim when not moving or red? Image shows green tick mark style
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(remaining),
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'REMAINING',
                              style: TextStyle(
                                color: Colors.white38,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  _isMoving ? 'KEEP MOVING' : 'START WALKING',
                  style: TextStyle(
                    color: _isMoving
                        ? const Color(0xFF34D399)
                        : Colors.white38, // Emerald 400
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 32),
                _buildMotionBar(),
                const SizedBox(height: 48),
                const Text(
                  'MOTION DETECTION ACTIVE',
                  style: TextStyle(
                    color: Colors.white24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMotionBar() {
    final progress = _elapsedSeconds / _requiredSeconds;
    final barWidth = MediaQuery.of(context).size.width - 48;

    return Column(
      children: [
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: Duration(seconds: _requiredSeconds),
            curve: Curves.linear,
            width: _isMoving ? barWidth * progress : 0,
            decoration: BoxDecoration(
              color: const Color(0xFF34D399),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STILL',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'WALKING',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

@UseCase(name: 'Default', type: WalkingChallengeScreen)
Widget buildWalkingChallengeScreenUseCase(BuildContext context) {
  return const WalkingChallengeScreen();
}
