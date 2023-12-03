import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'navigation_provider.dart';

class BackPopContext extends StatelessWidget {
  const BackPopContext({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Provider.of<NavigationProvider>(context, listen: false).pop();
      },
      child: child,
    );
  }
}
