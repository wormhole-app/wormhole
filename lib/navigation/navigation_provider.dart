import 'package:flutter/cupertino.dart';

class NavigationProvider with ChangeNotifier {
  final List<Widget> _rootPages;
  late final List<List<Widget>> _tabStacks;
  int _selectedIndex = 0;

  // push page to back-stack
  void push(Widget widget) {
    _tabStacks[_selectedIndex].add(widget);
    notifyListeners();
  }

  // pop last page from back stack and remove it
  Widget pop() {
    Widget popItem;
    final activeStack = _tabStacks[_selectedIndex];
    if (activeStack.length == 1) {
      popItem = activeStack.last;
    } else {
      popItem = activeStack.removeLast();
    }
    notifyListeners();
    return popItem;
  }

  // set active page and remove back-stack
  void setActivePage(Widget widget) {
    final rootIndex = _rootPages.indexWhere(
      (rootPage) => rootPage.runtimeType == widget.runtimeType,
    );

    if (rootIndex == -1) {
      _tabStacks[_selectedIndex] = [widget];
    } else {
      _selectedIndex = rootIndex;
      _tabStacks[rootIndex] = [widget];
    }

    notifyListeners();
  }

  void setActiveTab(int index) {
    if (index == _selectedIndex) {
      return;
    }

    _selectedIndex = index;
    notifyListeners();
  }

  // get active page
  Widget getActivePage() {
    return _tabStacks[_selectedIndex].last;
  }

  List<Widget> getActivePages() {
    return _tabStacks.map((stack) => stack.last).toList(growable: false);
  }

  int getSelectedIndex() {
    return _selectedIndex;
  }

  NavigationProvider(List<Widget> rootPages) : _rootPages = rootPages {
    _tabStacks = rootPages.map((page) => [page]).toList();
  }
}
