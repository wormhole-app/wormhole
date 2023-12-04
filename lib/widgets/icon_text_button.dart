import 'package:flutter/material.dart';

/// a button with text and icon
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
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: SizedBox(
          width: 145,
          height: 50,
          child: Material(
            color: theme.primaryColor,
            child: InkWell(
              highlightColor: theme.primaryColor,
              onTap: onClick,
              child: Row(
                children: [
                  SizedBox(
                    width: 45,
                    child: Center(
                      child: Icon(
                        icon,
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 95,
                    child: Text(
                      text,
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
