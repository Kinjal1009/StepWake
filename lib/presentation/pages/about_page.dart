import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../core/preview.dart';

@preview
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About StepWake'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.info_outline,
                  size: 80,
                  color: Colors.indigoAccent,
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'STEPWAKE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'MOTION TRACKING ALARM',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.indigoAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              _buildInfoSection(
                'How it works',
                'StepWake is designed to make sure you actually get out of bed. '
                    'When the alarm rings, you must complete a walking challenge '
                    'to dismiss it. The app uses your device\'s motion sensors to '
                    'detect movement.',
              ),
              const SizedBox(height: 32),
              _buildInfoSection(
                'Motion Tracking',
                'Ensure your device is in your hand or pocket while walking. '
                    'The sensitivity can be adjusted in settings if steps are not '
                    'being detected correctly.',
              ),
              const SizedBox(height: 48),
              const Center(
                child: Text(
                  'Version 1.2.0 • Made with ❤️',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.indigoAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

@UseCase(name: 'Default', type: AboutPage)
Widget buildAboutPageUseCase(BuildContext context) {
  return const AboutPage();
}
