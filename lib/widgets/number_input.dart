import 'package:flutter/material.dart';

class NumberInput extends StatefulWidget {
  const NumberInput(
      {Key? key,
      required this.initialValue,
      required this.minValue,
      required this.maxValue,
      required this.onValueChange})
      : super(key: key);

  final Future<int?> initialValue;
  final int minValue;
  final int maxValue;
  final void Function(int) onValueChange;

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  int value = 2;

  @override
  void initState() {
    super.initState();
    widget.initialValue.then((v) => setState(
          () => value = v ?? 2,
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
            borderRadius: BorderRadius.circular(15.0),
            color: theme.primaryColor),
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
                  color: theme.cardColor),
              child: Row(
                children: [
                  GestureDetector(
                    child: const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.add),
                    ),
                    onTap: () {
                      if (value < widget.maxValue) {
                        setState(() {
                          value++;
                        });
                        widget.onValueChange(value);
                      }
                    },
                  ),
                  Container(
                    color: theme.cardColor,
                    child: const VerticalDivider(
                      width: 0,
                      indent: 7,
                      endIndent: 7,
                    ),
                  ),
                  GestureDetector(
                    child: const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.remove),
                    ),
                    onTap: () {
                      if (value > widget.minValue) {
                        setState(() {
                          value--;
                        });
                        widget.onValueChange(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
