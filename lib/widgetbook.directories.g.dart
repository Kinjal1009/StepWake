import 'package:widgetbook/widgetbook.dart';
import 'package:step_wake/presentation/pages/home_page.dart';
import 'package:step_wake/presentation/pages/settings_page.dart';
import 'package:step_wake/presentation/pages/about_page.dart';
import 'package:step_wake/presentation/widgets/add_alarm_dialog.dart';
import 'package:step_wake/presentation/widgets/alarm_item_widget.dart';
import 'package:step_wake/presentation/widgets/ringing_overlay.dart';
import 'package:step_wake/presentation/widgets/walking_challenge.dart';
import 'package:step_wake/presentation/widgets/pro_tip_dialog.dart';

final directories = [
  WidgetbookFolder(
    name: 'Pages',
    children: [
      WidgetbookComponent(
        name: 'HomePage',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => buildHomePageUseCase(context),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SettingsPage',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => buildSettingsPageUseCase(context),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'AboutPage',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => buildAboutPageUseCase(context),
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'Widgets',
    children: [
      WidgetbookComponent(
        name: 'AddAlarmDialog',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => buildAddAlarmDialogUseCase(context),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'AlarmItemWidget',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => buildAlarmItemWidgetUseCase(context),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'RingingOverlay',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => buildRingingOverlayUseCase(context),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'WalkingChallenge',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => buildWalkingChallengeUseCase(context),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'ProTipDialog',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (context) => buildProTipDialogUseCase(context),
          ),
        ],
      ),
    ],
  ),
];
