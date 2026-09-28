import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../pages/qr_scanner_page.dart';
import '../pages/receive_page.dart';
import '../pages/send_page.dart';
import '../pages/settings/settings_page.dart';
import '../transfer/transfer_receiver.dart';
import '../utils/device.dart';
import 'cancel_action_scope.dart';

/// The three bottom-navigation tabs. Each tab owns an independent [Navigator]
/// so an ongoing flow (e.g. a running transfer) survives switching tabs or
/// pushing further pages on top of it.
enum AppTab { send, receive, settings }

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  final _navigatorKeys = <AppTab, GlobalKey<NavigatorState>>{
    for (final tab in AppTab.values) tab: GlobalKey<NavigatorState>(),
  };

  /// Cancel action of the page shown in each tab, see [CancelActionScope].
  final _cancelActions = <AppTab, ValueNotifier<VoidCallback?>>{
    for (final tab in AppTab.values) tab: ValueNotifier(null),
  };

  static const _rootPages = <AppTab, Widget>{
    AppTab.send: SendPage(),
    AppTab.receive: ReceivePage(),
    AppTab.settings: SettingsPage(),
  };

  @override
  void initState() {
    super.initState();
    for (final action in _cancelActions.values) {
      action.addListener(_onCancelActionChanged);
    }
  }

  @override
  void dispose() {
    for (final action in _cancelActions.values) {
      action.dispose();
    }
    super.dispose();
  }

  /// Pages update their cancel action while building or disposing, when
  /// this ancestor can't rebuild, so defer to after the frame then.
  void _onCancelActionChanged() {
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      scheduler.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setPrefferedAppOrientation(ctx: context);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  /// Switches to [tab] and pushes [page] onto its navigator.
  /// The returned future completes when the page is popped again.
  Future<void> _pushOnTab(AppTab tab, Widget page) {
    setState(() => _selectedIndex = tab.index);
    return _navigatorKeys[tab]!.currentState!.push(
          MaterialPageRoute<void>(
            // The page widgets are bare bodies without a background of their own;
            // add an explicit background to avoid a flash of the previous page
            builder: (context) => Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: page,
            ),
          ),
        );
  }

  /// Whether the QR scanner page is currently open.
  bool _scannerOpen = false;

  /// Scanning a QR code starts a receive, so the scanner lives on the
  /// receive tab.
  Future<void> _onQrButtonPress() async {
    setState(() => _scannerOpen = true);
    // The push future completes when the scanner is popped, no matter how
    // (back gesture, successful scan, invalid code).
    await _pushOnTab(AppTab.receive, const QrScannerPage());
    if (mounted) {
      setState(() => _scannerOpen = false);
    }
  }

  /// Routes the system back gesture to the active tab's navigator. Pages can
  /// veto the pop with their own PopScope (see DisallowPopContext). when the
  /// tab is already at its root, back leaves the app like a plain single-page
  /// app would.
  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop) return;
    final navigator =
        _navigatorKeys[AppTab.values[_selectedIndex]]!.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.maybePop();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final cancelAction = _cancelActions[AppTab.values[_selectedIndex]]!.value;

    return TransferReceiver(
      pushPage: _pushOnTab,
      child: Scaffold(
        appBar: AppBar(
          leading: _scannerOpen && _selectedIndex == AppTab.receive.index
              ? BackButton(
                  onPressed: () =>
                      _navigatorKeys[AppTab.receive]!.currentState!.maybePop(),
                )
              : cancelAction != null
                  ? IconButton(
                      onPressed: cancelAction,
                      icon: const Icon(Icons.close),
                      tooltip: AppLocalizations.of(context)!.transfer_cancel,
                    )
                  : null,
          title: Text(AppLocalizations.of(context)!.title),
          actions: [
            if (isMobile && !_scannerOpen)
              IconButton(
                onPressed: _onQrButtonPress,
                icon: const Icon(Icons.qr_code),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.upload),
              label: AppLocalizations.of(context)!.menu_send,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.download),
              label: AppLocalizations.of(context)!.menu_receive,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: AppLocalizations.of(context)!.menu_settings,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: _onPopInvoked,
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              for (final tab in AppTab.values)
                CancelActionScope(
                  action: _cancelActions[tab]!,
                  child: Navigator(
                    key: _navigatorKeys[tab],
                    onGenerateRoute: (settings) => MaterialPageRoute<void>(
                      builder: (_) => _rootPages[tab]!,
                      settings: settings,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
