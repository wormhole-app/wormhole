import 'package:flutter/cupertino.dart';

class NavigationProvider with ChangeNotifier {
  List<Widget> _popStack = [];

  // push page to back-stack
  void push(Widget widget) {
    _popStack.add(widget);
    notifyListeners();
  }

  // pop last page from back stack and remove it
  Widget pop() {
    Widget popItem;
    if (_popStack.length == 1) {
      popItem = _popStack.last;
    } else {
      popItem = _popStack.removeLast();
    }
    notifyListeners();
    return popItem;
  }

  // set active page and remove back-stack
  void setActivePage(Widget widget) {
    _popStack = [widget];
    notifyListeners();
  }

  // get active page
  Widget getActivePage() {
    return _popStack.last;
  }

  NavigationProvider(Widget widget) {
    _popStack.add(widget);
  }
}
