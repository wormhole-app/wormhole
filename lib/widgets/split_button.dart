import 'package:flutter/material.dart';

/// Split button with large left text button and smaller right icon button
class SplitButton extends StatelessWidget {
  const SplitButton(
      {Key? key,
      required this.onLeftButtonClick,
      required this.onRightButtonClick,
      required this.textLeft,
      required this.iconRight})
      : super(key: key);

  final void Function() onLeftButtonClick;
  final void Function() onRightButtonClick;
  final String textLeft;
  final IconData iconRight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: SizedBox(
          width: 140,
          height: 50,
          child: Row(
            children: [
              Material(
                color: theme.cardColor,
                child: InkWell(
                  highlightColor: theme.primaryColor,
                  onTap: onLeftButtonClick,
                  child: SizedBox(
                    width: 90,
                    child: Center(
                      child: Text(
                        textLeft,
                      ),
                    ),
                  ),
                ),
              ),
              Material(
                color: theme.primaryColor,
                child: InkWell(
                  highlightColor: theme.primaryColor,
                  onTap: onRightButtonClick,
                  child: SizedBox(
                    width: 50,
                    child: Center(
                      child: Icon(
                        iconRight,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
