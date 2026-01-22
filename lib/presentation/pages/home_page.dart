import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../providers/alarm_provider.dart';
import '../widgets/alarm_item_widget.dart';
import '../widgets/add_alarm_dialog.dart';
import '../widgets/ringing_overlay.dart';
import '../widgets/walking_challenge.dart';
import '../widgets/pro_tip_dialog.dart';
import '../../domain/entities/alarm.dart';
import './settings_page.dart';
import '../../core/preview.dart';

@Preview(name: 'HomePage')
Widget previewHomePage() {
  return const PreviewWrapper(child: HomePage());
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        _currentTime = now;
      });
    });

    // Global alarm listener is now in main.dart
    // We don't need to listen here anymore.
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alarms = ref.watch(alarmsProvider);
    final appState = ref.watch(appStateProvider);

    // Sort alarms by time
    final sortedAlarms = [...alarms]..sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _buildTopBar(),
                  const SizedBox(height: 30),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildAlarmsList(sortedAlarms),
                  const SizedBox(height: 100), // Spacing for footer and FAB
                ],
              ),
            ),
          ),

          // Footer at the absolute bottom
          // Positioned(bottom: 0, left: 0, right: 0, child: _buildFooter()),

          // Overlays (Full Screen)
          if (appState.mode == AppMode.ringing)
            Positioned.fill(child: _buildRingingOverlay(appState.activeAlarm!)),
          if (appState.mode == AppMode.challenge)
            Positioned.fill(
              child: _buildChallengeOverlay(appState.activeAlarm!),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 10),
        child: FloatingActionButton(
          onPressed: () => _showAddAlarm(context),
          backgroundColor: Colors.indigoAccent,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'STEPWAKE',
          style: TextStyle(
            color: Colors.indigoAccent,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white38),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const ProTipDialog(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white38),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final dateStr = DateFormat('EEEE, MMMM d').format(_currentTime);

    return Column(
      children: [
        Text(
          dateStr.toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmsList(List<Alarm> alarms) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alarms',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${alarms.where((a) => a.isEnabled).length} active',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (alarms.isEmpty)
            _buildEmptyState()
          else
            Expanded(
              child: ListView.separated(
                itemCount: alarms.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  return AlarmItemWidget(
                    alarm: alarm,
                    onToggle: () =>
                        ref.read(alarmsProvider.notifier).toggleAlarm(alarm.id),
                    onDelete: () =>
                        ref.read(alarmsProvider.notifier).deleteAlarm(alarm.id),
                    onEdit: () => _showAddAlarm(context, initialAlarm: alarm),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return CustomPaint(
      painter: DashedRectPainter(
        color: Colors.white.withValues(alpha: 0.1),
        strokeWidth: 2,
        gap: 8,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Text(
              'No alarms set',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildFooter() {
  //   return const Padding(
  //     padding: EdgeInsets.only(bottom: 24.0),
  //     child: Center(
  //       child: Text(
  //         'Stepwake motion tracking enabled',
  //         style: TextStyle(
  //           color: Colors.white38,
  //           fontWeight: FontWeight.w500,
  //           fontSize: 12,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showAddAlarm(BuildContext context, {Alarm? initialAlarm}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      useSafeArea: true,
      builder: (context) => AddAlarmDialog(initialAlarm: initialAlarm),
    );
  }

  Widget _buildRingingOverlay(Alarm alarm) {
    return RingingOverlay(
      time: alarm.time,
      label: alarm.label,
      onStartChallenge: () {
        ref.read(appStateProvider.notifier).setMode(AppMode.challenge);
      },
    );
  }

  Widget _buildChallengeOverlay(Alarm alarm) {
    return WalkingChallenge(
      requiredSeconds: alarm.walkMinutes * 60,
      onComplete: () {
        ref.read(appStateProvider.notifier).setMode(AppMode.idle);
        ref.read(appStateProvider.notifier).setActiveAlarm(null);
      },
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(32),
        ),
      );

    final dashPath = Path();
    double dashWidth = gap;
    double dashSpace = gap;
    double distance = 0.0;

    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) => false;
}

@UseCase(name: 'Default', type: HomePage)
Widget buildHomePageUseCase(BuildContext context) {
  return const ProviderScope(child: HomePage());
}
