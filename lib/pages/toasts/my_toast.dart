import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

abstract class MyToast extends StatelessWidget {
  const MyToast({super.key});

  void show(BuildContext context) {
    FToast toast = FToast();
    toast.init(context);
    toast.showToast(
      child: this,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}
