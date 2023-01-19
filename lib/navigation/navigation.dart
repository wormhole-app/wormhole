import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../pages/qr_scanner_page.dart';
import '../pages/receive_page.dart';
import '../pages/send_page.dart';
import '../pages/settings_page.dart';
import '../theme/dark_theme_provider.dart';
import '../transfer/transfer_receiver.dart';
import 'navigation_provider.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  final navigation = NavigationProvider(_widgetOptions[0]);

  static const List<Widget> _widgetOptions = <Widget>[
    SendPage(),
    ReceivePage(),
    SettingsPage()
  ];

  void _onItemTapped(int index) {
    navigation.setActivePage(_widgetOptions[index]);

    setState(() {
      _selectedIndex = index;
    });
  }

  _onQrButtonPress() {
    navigation.push(const QrScannerPage());
  }

  @override
  Widget build(BuildContext context) {
    final themeprov = Provider.of<DarkThemeProvider>(context);

    return ChangeNotifierProvider(
      builder: (context, child) {
        return TransferReceiver(
            child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).title),
            actions: [
              if (Platform.isAndroid || Platform.isIOS)
                IconButton(
                  onPressed: _onQrButtonPress,
                  icon: const Icon(Icons.qr_code),
                ),
              IconButton(
                onPressed: () {
                  themeprov.invertTheme();
                },
                icon: Icon(themeprov.darkTheme
                    ? Icons.light_mode_outlined
                    : Icons.light_mode),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.upload),
                label: AppLocalizations.of(context).menu_send,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.download),
                label: AppLocalizations.of(context).menu_receive,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: AppLocalizations.of(context).menu_settings,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
          ),
          body: Consumer<NavigationProvider>(builder: (context, value, child) {
            return value.getActivePage();
          }),
        ));
      },
      create: (context) => navigation,
    );
  }
}
