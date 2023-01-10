import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation_provider.dart';
import 'pages/receive_page.dart';
import 'pages/send_page.dart';
import 'pages/settings_page.dart';
import 'theme/dark_theme_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final themeprov = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Wormhole'),
          actions: [
            IconButton(
                onPressed: () {
                  themeprov.invertTheme();
                },
                icon: const Icon(Icons.light_mode_outlined))
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.upload),
              label: 'Send',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.download),
              label: 'Receive',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
        body: ChangeNotifierProvider(
          builder: (context, child) {
            return Consumer<NavigationProvider>(
              builder: (context, value, child) {
                return value.getActivePage();
              },
            );
          },
          create: (context) => navigation,
        ));
  }
}
