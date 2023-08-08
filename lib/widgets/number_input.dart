import 'package:flutter/material.dart';

/// full sized number input for settings page
class NumberInput extends StatefulWidget {
  const NumberInput(
      {Key? key,
      required this.initialValue,
      required this.minValue,
      required this.maxValue,
      required this.onValueChange})
      : super(key: key);

  final Future<int> initialValue;
  final int minValue;
  final int maxValue;
  final void Function(int) onValueChange;

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  int value = 0;

  @override
  void initState() {
    super.initState();
    widget.initialValue.then((v) => setState(
          () => value = v,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 250,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0), color: theme.cardColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 13,
                ),
                Text(value.toString()),
              ],
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: theme.primaryColor),
              child: Row(
                children: [
                  _squaredButton(const Icon(Icons.add), () {
                    if (value < widget.maxValue) {
                      setState(() {
                        value++;
                      });
                      widget.onValueChange(value);
                    }
                  }, false, true),
                  Container(
                    color: theme.cardColor,
                    child: const VerticalDivider(
                      width: 0,
                      indent: 7,
                      endIndent: 7,
                    ),
                  ),
                  _squaredButton(const Icon(Icons.remove), () {
                    if (value > widget.minValue) {
                      setState(() {
                        value--;
                      });
                      widget.onValueChange(value);
                    }
                  }, true, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _squaredButton(
      Widget child, void Function() onTap, bool cornerRight, bool cornerLeft) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 50,
      height: 50,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          highlightColor: theme.hoverColor,
          hoverColor: Colors.transparent,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: cornerLeft ? const Radius.circular(15) : Radius.zero,
                bottomLeft:
                    cornerLeft ? const Radius.circular(15) : Radius.zero,
                topRight: cornerRight ? const Radius.circular(15) : Radius.zero,
                bottomRight:
                    cornerRight ? const Radius.circular(15) : Radius.zero),
          ),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}
