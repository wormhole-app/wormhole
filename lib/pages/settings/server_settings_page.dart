import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../gen/ffi.dart';
import '../../settings/settings.dart';
import '../../widgets/fast_future_builder.dart';
import '../../widgets/full_sized_text_input.dart';
import '../../widgets/settings_row.dart';
import '../toasts/info_toast.dart';

class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  final TextEditingController _transitController = TextEditingController();
  final TextEditingController _rendezvousController = TextEditingController();

  @override
  void dispose() {
    _transitController.dispose();
    _rendezvousController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Settings.getRendezvousUrl().then((value) {
      if (value != null) {
        _transitController.text = value;
      }
    });

    Settings.getTransitUrl().then((value) {
      if (value != null) {
        _transitController.text = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings_page_serversettings),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final transitValue = _transitController.text;
              final rendezvousValue = _rendezvousController.text;

              if (_validateUriInput(transitValue) == null &&
                  _validateUriInput(rendezvousValue) == null) {
                Settings.setTransitUrl(
                    transitValue.isEmpty ? null : transitValue);
                Settings.setRendezvousUrl(
                    rendezvousValue.isEmpty ? null : rendezvousValue);
                InfoToast(
                  message:
                      AppLocalizations.of(context).settings_page_server_saved,
                ).show(context);
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            FastFutureBuilder(
              future: api.defaultRendezvousUrl(),
              onData: (String data) => SettingsRow(
                name:
                    AppLocalizations.of(context).settings_page_rendezvousserver,
                child: FullSizedTextInput(
                  controller: _rendezvousController,
                  validator: (v) => _validateUriInput(v),
                  hintText: data,
                ),
              ),
            ),
            FastFutureBuilder(
              future: api.defaultTransitUrl(),
              onData: (data) => SettingsRow(
                name: AppLocalizations.of(context).settings_page_transitserver,
                child: FullSizedTextInput(
                  controller: _transitController,
                  validator: (v) => _validateUriInput(v),
                  hintText: data,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String? _validateUriInput(String value) {
    if (value.isNotEmpty) {
      // to be a valid parsable url must have a trailing slash
      final valid = Uri.tryParse('$value/')?.hasAbsolutePath ?? false;
      return valid
          ? null
          : AppLocalizations.of(context).settings_page_error_url;
    }
    return null;
  }
}
