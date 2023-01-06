import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/pages/receive_page.dart';
import 'package:flutter_rust_bridge_template/pages/send_page.dart';
import 'package:flutter_rust_bridge_template/pages/settings_page.dart';
import 'package:flutter_rust_bridge_template/theme/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    SendPage(),
    ReceivePage(),
    SettingsPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeprov = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wormhole"),
        actions: [IconButton(onPressed: () {
          themeprov.invertTheme();
        }, icon: const Icon(Icons.light_mode_outlined))],
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
      body: _widgetOptions[_selectedIndex]
    );
  }
}
