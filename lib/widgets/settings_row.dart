import 'package:flutter/material.dart';

/// Settings row with title and space for child
class SettingsRow extends StatelessWidget {
  const SettingsRow(
      {super.key, required this.child, required this.name, this.topSpacing});

  final Widget child;
  final String name;
  final double? topSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: topSpacing ?? 20.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(name),
        ),
        const SizedBox(
          height: 10,
        ),
        child
      ],
    );
  }
}
