import 'package:flutter/material.dart';

/// A responsive button with text and an icon.
class IconTextButton extends StatelessWidget {
  const IconTextButton(
      {super.key,
      required this.onClick,
      required this.text,
      required this.icon});

  final void Function() onClick;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 250,
        maxWidth: 320,
        minHeight: 56,
      ),
      child: FilledButton.icon(
        onPressed: onClick,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          textAlign: TextAlign.center,
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
