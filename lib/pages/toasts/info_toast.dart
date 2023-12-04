import 'package:flutter/material.dart';

import 'base_toast.dart';
import 'my_toast.dart';

class InfoToast extends MyToast {
  const InfoToast({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => BaseToast(
        message: message,
        color: Colors.orangeAccent.withOpacity(.5),
        icon: const Icon(Icons.info_outline),
      );
}
