import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../gen/ffi.dart';
import '../settings/settings.dart';
import '../theme/dark_theme_provider.dart';
import '../widgets/fast_future_builder.dart';
import '../widgets/number_input.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeprov = Provider.of<DarkThemeProvider>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child:
                    Text(AppLocalizations.of(context).settings_page_wordlength),
              ),
              const SizedBox(
                height: 10,
              ),
              NumberInput(
                initialValue: Settings.getWordLength()
                    .then((value) => value ?? Defaults.wordlength),
                minValue: 2,
                maxValue: 8,
                onValueChange: (int value) {
                  Settings.setWordLength(value);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child:
                    Text(AppLocalizations.of(context).settings_page_code_type),
              ),
              const SizedBox(
                height: 10,
              ),
              FutureBuilder<CodeType>(
                  future: Settings.getCodeType(),
                  builder: (context, snapshot) {
                    return ToggleSwitch(
                      minWidth: 125.0,
                      cornerRadius: 15.0,
                      activeBgColors: [
                        [theme.primaryColor],
                        [theme.primaryColor]
                      ],
                      inactiveBgColor: theme.cardColor,
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
                  }),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child:
                    Text(AppLocalizations.of(context).settings_page_show_code),
              ),
              const SizedBox(
                height: 10,
              ),
              FutureBuilder<bool>(
                future: Settings.getCodeAlwaysVisible(),
                builder: (context, snapshot) => ToggleSwitch(
                  minWidth: 125.0,
                  cornerRadius: 15.0,
                  activeBgColors: [
                    [theme.primaryColor],
                    [theme.primaryColor]
                  ],
                  inactiveBgColor: theme.cardColor,
                  customTextStyles: [theme.textTheme.bodyMedium],
                  initialLabelIndex:
                      snapshot.hasData ? (snapshot.data! ? 0 : 1) : 1,
                  totalSwitches: 2,
                  labels: [
                    AppLocalizations.of(context).settings_page_show_always,
                    AppLocalizations.of(context).settings_page_show_never
                  ],
                  radiusStyle: true,
                  onToggle: (index) {
                    Settings.setCodeAlwaysVisible(index == 0);
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(AppLocalizations.of(context).settings_page_theming),
              ),
              const SizedBox(
                height: 10,
              ),
              ToggleSwitch(
                minWidth: 83.333,
                cornerRadius: 15.0,
                activeBgColors: [
                  [theme.primaryColor],
                  [theme.primaryColor],
                  [theme.primaryColor]
                ],
                inactiveBgColor: theme.cardColor,
                customTextStyles: [theme.textTheme.bodyMedium],
                initialLabelIndex: themeprov.theme.index,
                totalSwitches: 3,
                labels: [
                  AppLocalizations.of(context).settings_page_dark_theme,
                  AppLocalizations.of(context).settings_page_light_theme,
                  AppLocalizations.of(context).settings_page_system_theme
                ],
                radiusStyle: true,
                onToggle: (index) {
                  if (index == null) {
                    return;
                  }
                  themeprov.theme = ThemeType.values[index];
                },
              ),
            ],
          ),
          FastFutureBuilder<BuildInfo>(
            future: api.getBuildTime(),
            onData: (data) => Column(
              children: [
                Text('Version: ${data.version}'),
                if (data.devBuild)
                  Text(AppLocalizations.of(context).dev_build_warning),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
