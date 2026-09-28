import 'package:flutter/widgets.dart';

/// Lets a page inside a tab put a cancel button into the app bar, which
/// lives outside of the per-tab navigators. The page sets the action while
/// it can be cancelled and clears it again afterwards.
class CancelActionScope extends InheritedWidget {
  const CancelActionScope({
    super.key,
    required this.action,
    required super.child,
  });

  final ValueNotifier<VoidCallback?> action;

  static ValueNotifier<VoidCallback?>? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<CancelActionScope>()?.action;
  }

  @override
  bool updateShouldNotify(CancelActionScope oldWidget) =>
      action != oldWidget.action;
}
