import 'package:flutter/material.dart';

class BaseToast extends StatelessWidget {
  const BaseToast(
      {Key? key,
      required this.message,
      required this.color,
      required this.icon})
      : super(key: key);
  final String message;
  final Color color;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(
            width: 12.0,
          ),
          Text(message),
        ],
      ),
    );
  }
}
