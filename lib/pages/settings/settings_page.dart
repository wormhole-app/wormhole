import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../l10n/app_localizations.dart';
import '../../locale/locale_provider.dart';
import '../../src/rust/api/wormhole.dart';
import '../../settings/settings.dart';
import '../../theme/theme_provider.dart';
import '../../utils/logger.dart';
import '../../widgets/fast_future_builder.dart';
import '../../widgets/number_input.dart';
import '../../widgets/settings_row.dart';
import '../../widgets/settings_section_button.dart';
import 'package:share_plus/share_plus.dart';
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

  Future<void> _showExportLogsDialog() async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.logs_dialog_title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                    'This will create a compressed archive of the application logs that you can share to help with debugging issues.'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _exportLogs();
                      },
                      child:
                          Text(AppLocalizations.of(context)!.logs_dialog_share),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportLogs() async {
    try {
      // Archive logs - this creates a zip file
      final archivePath = await AppLogger.archiveLog();
      AppLogger.info('Logs archived to: $archivePath');

      // Share the archived log file
      final params = ShareParams(
        files: [XFile(archivePath)],
        subject: 'Wormhole App Logs',
      );
      final result = await SharePlus.instance.share(params);

      AppLogger.info('Logs exported with result: ${result.status}');
    } catch (e) {
      AppLogger.error('Failed to export logs: $e');
    }
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

  Widget _buildLanguageDropdown(
    BuildContext context,
    LanguageType currentLanguage,
    LocaleProvider localeprov,
    ThemeData theme,
  ) {
    final items = LanguageType.values;

    final labels = {
      for (var lang in LanguageType.values)
        lang: LocaleProvider.getLanguageDisplayName(lang, context)
    };

    return SizedBox(
      width: 180.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: DropdownButton<LanguageType>(
          value: currentLanguage,
          items: items
              .map((language) => DropdownMenuItem(
                    value: language,
                    child: Text(labels[language] ?? ''),
                  ))
              .toList(),
          onChanged: (LanguageType? value) {
            if (value != null) {
              localeprov.language = value;
            }
          },
          underline: const SizedBox(),
          isExpanded: true,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  List<Widget> _buildSettingsContent() {
    final theme = Theme.of(context);
    final themeprov = Provider.of<ThemeProvider>(context);
    final localeprov = Provider.of<LocaleProvider>(context);

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
                  labels: [
                    AppLocalizations.of(context)!.settings_page_qr_code,
                    AppLocalizations.of(context)!.settings_page_aztec_code
                  ],
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
          name: AppLocalizations.of(context)!.settings_page_language,
          child: _buildLanguageDropdown(
              context, localeprov.language, localeprov, theme)),
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
      SettingsRow(
        name: AppLocalizations.of(context)!.settings_page_logs,
        child: SettingsSectionButton(
          onButtonClick: _showExportLogsDialog,
          text: AppLocalizations.of(context)!.settings_page_export_logs,
          iconRight: Icons.file_upload_outlined,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildSettingsContent(),
            ),
          ),
        ),
        Center(child: _buildBottomVersion())
      ],
    );
  }
}
