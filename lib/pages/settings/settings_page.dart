import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../l10n/app_localizations.dart';
import '../../src/rust/api/wormhole.dart';
import '../../settings/settings.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/fast_future_builder.dart';
import '../../widgets/number_input.dart';
import '../../widgets/settings_row.dart';
import '../../widgets/settings_section_button.dart';
import 'server_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _controllerWordLength = TextEditingController();

  @override
  void initState() {
    super.initState();
    Settings.getWordLength().then((value) {
      _controllerWordLength.text = value?.toString() ?? '';
    });
  }

  Widget _buildBottomVersion() {
    return FastFutureBuilder<BuildInfo>(
      future: getBuildTime(),
      onData: (data) => Column(
        children: [
          Text('Version: ${data.version}'),
          if (data.devBuild)
            Text(AppLocalizations.of(context)!.dev_build_warning),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  List<Widget> _buildSettingsContent() {
    final theme = Theme.of(context);
    final themeprov = Provider.of<ThemeProvider>(context);

    return [
      SettingsRow(
        name: AppLocalizations.of(context)!.settings_page_wordlength,
        topSpacing: 25,
        child: NumberInput(
          initialValue: Settings.getWordLength()
              .then((value) => value ?? Defaults.wordlength),
          minValue: 2,
          maxValue: 8,
          onValueChange: (int value) {
            Settings.setWordLength(value);
          },
        ),
      ),
      SettingsRow(
          name: AppLocalizations.of(context)!.settings_page_code_type,
          child: FutureBuilder<CodeType>(
              future: Settings.getCodeType(),
              builder: (context, snapshot) {
                return ToggleSwitch(
                  minWidth: 125.0,
                  cornerRadius: 15.0,
                  activeBgColors: [
                    [theme.colorScheme.primary],
                    [theme.colorScheme.primary]
                  ],
                  inactiveBgColor: theme.colorScheme.secondary,
                  customTextStyles: [theme.textTheme.bodyMedium],
                  initialLabelIndex: snapshot.hasData
                      ? (snapshot.data! == CodeType.qrCode ? 0 : 1)
                      : 0,
                  totalSwitches: 2,
                  labels: const ['Qr Code', 'Aztec Code'],
                  radiusStyle: true,
                  onToggle: (index) {
                    Settings.setCodeType(
                        index == 0 ? CodeType.qrCode : CodeType.aztecCode);
                  },
                );
              })),
      SettingsRow(
          name: AppLocalizations.of(context)!.settings_page_show_code,
          child: FutureBuilder<bool>(
            future: Settings.getCodeAlwaysVisible(),
            builder: (context, snapshot) => ToggleSwitch(
              minWidth: 125.0,
              cornerRadius: 15.0,
              activeBgColors: [
                [theme.colorScheme.primary],
                [theme.colorScheme.primary]
              ],
              inactiveBgColor: theme.colorScheme.secondary,
              customTextStyles: [theme.textTheme.bodyMedium],
              initialLabelIndex:
                  snapshot.hasData ? (snapshot.data! ? 0 : 1) : 1,
              totalSwitches: 2,
              labels: [
                AppLocalizations.of(context)!.settings_page_show_always,
                AppLocalizations.of(context)!.settings_page_show_never
              ],
              radiusStyle: true,
              onToggle: (index) {
                Settings.setCodeAlwaysVisible(index == 0);
              },
            ),
          )),
      SettingsRow(
          name: AppLocalizations.of(context)!.settings_page_theming,
          child: ToggleSwitch(
            minWidth: 83.333,
            cornerRadius: 15.0,
            activeBgColors: [
              [theme.colorScheme.primary],
              [theme.colorScheme.primary],
              [theme.colorScheme.primary]
            ],
            inactiveBgColor: theme.colorScheme.secondary,
            customTextStyles: [theme.textTheme.bodyMedium],
            initialLabelIndex: themeprov.theme.index,
            totalSwitches: 3,
            labels: [
              AppLocalizations.of(context)!.settings_page_dark_theme,
              AppLocalizations.of(context)!.settings_page_light_theme,
              AppLocalizations.of(context)!.settings_page_system_theme
            ],
            radiusStyle: true,
            onToggle: (index) {
              if (index == null) {
                return;
              }
              themeprov.theme = ThemeType.values[index];
            },
          )),
      SettingsRow(
        name: AppLocalizations.of(context)!.settings_page_advanced,
        child: SettingsSectionButton(
          onButtonClick: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ServerSettingsPage(),
            ));
          },
          text: AppLocalizations.of(context)!.settings_page_serversettings,
          iconRight: Icons.arrow_right_outlined,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _buildSettingsContent(),
          ),
          _buildBottomVersion()
        ],
      ),
    );
  }
}
