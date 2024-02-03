import 'package:flutter/material.dart';

/// large text input for settings page
class FullSizedTextInput extends StatelessWidget {
  const FullSizedTextInput(
      {super.key, required this.controller, this.validator, this.hintText});

  final TextEditingController controller;
  final String? hintText;
  final String? Function(String text)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 250,
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (BuildContext context, value, Widget? child) {
          return TextField(
            controller: controller,
            cursorColor: theme.colorScheme.onPrimary,
            decoration: InputDecoration(
              errorText: validator != null ? validator!(controller.text) : null,
              filled: true,
              focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  borderSide:
                      BorderSide(color: theme.colorScheme.secondary, width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  borderSide:
                      BorderSide(color: theme.colorScheme.primary, width: 2)),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              hintText: hintText,
            ),
          );
        },
      ),
    );
  }
}
