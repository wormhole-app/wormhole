import 'package:flutter/cupertino.dart';

class NavigationProvider with ChangeNotifier {
  Widget _activePage;

  void setActivePage(Widget widget) {
    _activePage = widget;
    notifyListeners();
  }

  Widget getActivePage() {
    return _activePage;
  }

  NavigationProvider(this._activePage);
}
