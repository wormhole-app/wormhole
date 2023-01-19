import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'navigation_provider.dart';

class BackPopContext extends StatelessWidget {
  const BackPopContext({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationProvider>(context, listen: false).pop();
        return false;
      },
      child: child,
    );
  }
}
