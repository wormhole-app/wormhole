import 'package:flutter/widgets.dart';

class DisallowPopContext extends StatelessWidget {
  const DisallowPopContext({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: child,
    );
  }
}
