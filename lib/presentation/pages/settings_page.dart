import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../providers/alarm_provider.dart';
import '../../core/preview.dart';

@Preview(name: 'SettingsPage')
Widget previewSettingsPage() {
  return const PreviewWrapper(child: SettingsPage());
}

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late AudioPlayer _player;
  String? _currentlyPreviewing;

  static const List<Map<String, String>> _ringtoneOptions = [
    {
      'name': 'Digital Watch',
      'url':
          'https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg',
    },
    {
      'name': 'Classic Clock',
      'url': 'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => _currentlyPreviewing = null);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePreview(String url) async {
    if (_currentlyPreviewing == url) {
      await _player.stop();
      setState(() => _currentlyPreviewing = null);
    } else {
      setState(() => _currentlyPreviewing = url);
      try {
        await _player.setUrl(url);
        await _player.play();
      } catch (e) {
        debugPrint("Error previewing: $e");
        setState(() => _currentlyPreviewing = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final currentRingtone = appState.globalRingtone;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionHeader('DEFAULT RINGTONE'),
                const SizedBox(height: 16),
                ..._ringtoneOptions.map((ringtone) {
                  final isSelected = ringtone['url'] == currentRingtone;
                  final isPlaying = _currentlyPreviewing == ringtone['url'];

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(appStateProvider.notifier)
                          .setRingtone(ringtone['url']!);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: isSelected
                            ? Border.all(
                                color: Colors.indigoAccent.withValues(
                                  alpha: 0.5,
                                ),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.indigoAccent
                                    : Colors.white.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: isSelected
                                ? Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.indigoAccent,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              ringtone['name']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _togglePreview(ringtone['url']!),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isPlaying ? Icons.stop : Icons.play_arrow,
                                color: Colors.indigoAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 48),
            child: Text(
              'STEPWAKE V1.2.0',
              style: TextStyle(
                color: Colors.white10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          fontSize: 12,
        ),
      ),
    );
  }
}

@UseCase(name: 'Default', type: SettingsPage)
Widget buildSettingsPageUseCase(BuildContext context) {
  return const ProviderScope(child: SettingsPage());
}
