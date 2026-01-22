import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarm/alarm.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/providers/alarm_provider.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/screens/alarm_ringing_screen.dart';
import 'presentation/screens/walking_challenge_screen.dart';
import 'presentation/pages/permission_check_page.dart';
import 'presentation/pages/splash_page.dart';
import 'domain/entities/alarm.dart' as domain;

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
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
    // Global listener for alarm ringing
    Alarm.ringStream.stream.listen((alarmSettings) {
      final alarms = ref.read(alarmsProvider);
      if (alarms.isEmpty) return;

      final activeAlarm = alarms.firstWhere(
        (a) => a.id.hashCode == alarmSettings.id,
        orElse: () => alarms.first,
      );

      ref.read(appStateProvider.notifier).setActiveAlarm(activeAlarm);
      ref.read(appStateProvider.notifier).setMode(domain.AppMode.ringing);

      navigatorKey.currentState?.pushNamed('/alarm-ringing');
    });
  }

  @override
  Widget build(BuildContext context) {
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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/': (context) => const PermissionCheckPage(child: HomePage()),
        '/alarm-ringing': (context) => const AlarmRingingScreen(),
        '/walking-challenge': (context) => const WalkingChallengeScreen(),
      },
    );
  }
}
