import 'package:flutter/widgets.dart';

class DisallowPopContext extends StatelessWidget {
  const DisallowPopContext({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: child,
    );
  }
}
