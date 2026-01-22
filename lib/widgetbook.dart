import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'widgetbook.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

@WidgetbookApp()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Dark',
              data: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  brightness: Brightness.dark,
                  surface: const Color(0xFF020617),
                  surfaceContainer: const Color(0xFF0F172A),
                ),
                scaffoldBackgroundColor: const Color(0xFF020617),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
