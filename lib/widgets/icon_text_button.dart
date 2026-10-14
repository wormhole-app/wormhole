import 'package:flutter/material.dart';

/// A responsive button with text and an icon.
class IconTextButton extends StatelessWidget {
  const IconTextButton(
      {super.key,
      required this.onClick,
      required this.text,
      required this.icon,
      this.outlined = false});

  final void Function() onClick;
  final String text;
  final IconData icon;

  /// A border instead of a filled background, for a secondary action.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    );
    final iconWidget = Icon(icon, size: 24);
    final label = Text(
      text,
      textAlign: TextAlign.center,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 250,
        maxWidth: 320,
        minHeight: 56,
      ),
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onClick,
              icon: iconWidget,
              label: label,
              style: OutlinedButton.styleFrom(
                padding: padding,
                shape: shape,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                side: BorderSide(
                    color: Theme.of(context).colorScheme.secondary, width: 2),
              ),
            )
          : FilledButton.icon(
              onPressed: onClick,
              icon: iconWidget,
              label: label,
              style: FilledButton.styleFrom(
                padding: padding,
                shape: shape,
              ),
            ),
    );
  }
}
