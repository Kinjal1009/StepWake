import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/native_alarm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/repositories/alarm_repository_impl.dart';
import 'presentation/providers/alarm_provider.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/screens/walking_challenge_screen.dart';
import 'presentation/pages/permission_check_page.dart';

import 'domain/entities/alarm.dart' as domain;

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final alarmRepository = AlarmRepositoryImpl(
    sharedPreferences: sharedPreferences,
  );
  final initialAlarms = await alarmRepository.getAlarms();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        alarmRepositoryProvider.overrideWithValue(alarmRepository),
        alarmsProvider.overrideWith(
          (ref) => AlarmNotifier(
            repository: alarmRepository,
            initialAlarms: initialAlarms,
          ),
        ),
      ],
      child: const StepWakeApp(),
    ),
  );
}

class StepWakeApp extends ConsumerStatefulWidget {
  const StepWakeApp({super.key});

  @override
  ConsumerState<StepWakeApp> createState() => _StepWakeAppState();
}

class _StepWakeAppState extends ConsumerState<StepWakeApp> {
  @override
  void initState() {
    super.initState();
    // Check if app was launched by alarm
    _checkAlarmTrigger();

    // Listen for alarm triggers while app is running
    NativeAlarmService.setMethodCallHandler((call) async {
      if (call.method == 'alarmTriggered') {
        final args = call.arguments;
        final startChallenge = args is Map && (args['startChallenge'] == true);
        final alarmId = args is Map ? args['alarmId'] as int? : null;
        _handleAlarmTrigger(startChallenge: startChallenge, alarmId: alarmId);
      }
    });
  }

  void _checkAlarmTrigger() {
    NativeAlarmService.checkLaunchIntent().then((data) {
      final triggered = data['triggered'] == true;
      final startChallenge = data['startChallenge'] == true;
      final alarmId = data['alarmId'] as int?;
      if (triggered) {
        _handleAlarmTrigger(startChallenge: startChallenge, alarmId: alarmId);
      }
    });
  }

  void _handleAlarmTrigger({bool startChallenge = false, int? alarmId}) {
    final alarms = ref.read(alarmsProvider);
    domain.Alarm? matchingAlarm;

    // First, try to find alarm by ID if provided
    if (alarmId != null) {
      try {
        matchingAlarm = alarms.firstWhere(
          (alarm) => alarm.id.hashCode == alarmId && alarm.isEnabled,
        );
        print(
          'Found alarm by ID: ${matchingAlarm.label} - Walk duration: ${matchingAlarm.walkMinutes} minutes',
        );
      } catch (e) {
        print('Could not find alarm with ID $alarmId');
      }
    }

    // If no alarm found by ID, try to match by current time
    if (matchingAlarm == null) {
      final now = DateTime.now();

      for (final alarm in alarms) {
        if (alarm.isEnabled) {
          final alarmParts = alarm.time.split(':');
          final alarmHour = int.parse(alarmParts[0]);
          final alarmMinute = int.parse(alarmParts[1]);

          // Check if alarm time matches current time (within 1 minute tolerance)
          if ((alarmHour == now.hour &&
                  (alarmMinute - now.minute).abs() <= 1) ||
              (alarmHour == now.hour && alarmMinute == now.minute)) {
            matchingAlarm = alarm;
            print(
              'Found alarm by time: ${matchingAlarm.label} - Walk duration: ${matchingAlarm.walkMinutes} minutes',
            );
            break;
          }
        }
      }
    }

    // If still no match, use first enabled alarm as fallback
    if (matchingAlarm == null) {
      final firstEnabled = alarms.where((a) => a.isEnabled).firstOrNull;
      if (firstEnabled != null) {
        matchingAlarm = firstEnabled;
        print(
          'Using first enabled alarm as fallback: ${firstEnabled.label} - Walk duration: ${firstEnabled.walkMinutes} minutes',
        );
      }
    }

    // Set the active alarm if found
    if (matchingAlarm != null) {
      ref.read(appStateProvider.notifier).setActiveAlarm(matchingAlarm);
    }

    // Always go directly to the walking challenge
    ref.read(appStateProvider.notifier).setMode(domain.AppMode.challenge);
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'StepWake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
          surface: const Color(0xFF020617), // Slate 950 (Background)
          surfaceContainer: const Color(0xFF0F172A), // Slate 900 (Surface)
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF020617),
      ),
      home:
          (appState.mode == domain.AppMode.ringing ||
              appState.mode == domain.AppMode.challenge)
          ? const WalkingChallengeScreen()
          : const PermissionCheckPage(child: HomePage()),
    );
  }
}
