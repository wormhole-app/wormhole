import 'package:flutter/material.dart';

/// Full sized Settings page button
class SettingsSectionButton extends StatelessWidget {
  const SettingsSectionButton(
      {super.key,
      required this.onButtonClick,
      required this.text,
      this.iconRight});

  final void Function() onButtonClick;
  final String text;
  final IconData? iconRight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: SizedBox(
        width: 250,
        height: 50,
        child: Material(
          color: theme.cardColor,
          child: InkWell(
            highlightColor: theme.primaryColor,
            onTap: onButtonClick,
            child: Row(
              children: [
                SizedBox(
                  width: iconRight == null ? 250 : 200,
                  child: Center(
                    child: Text(
                      text,
                    ),
                  ),
                ),
                if (iconRight != null)
                  SizedBox(
                    width: 50,
                    child: Icon(
                      iconRight,
                      size: 32,
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
