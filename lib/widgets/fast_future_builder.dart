import 'package:flutter/widgets.dart';

class FastFutureBuilder<T> extends StatelessWidget {
  const FastFutureBuilder(
      {super.key, required this.future, required this.onData, this.loadWidget});
  final Future<T> future;
  final Widget Function(T data) onData;
  final Widget? loadWidget;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return onData(snapshot.data as T);
        } else {
          return loadWidget ?? Container();
        }
      },
      future: future,
    );
  }
}
