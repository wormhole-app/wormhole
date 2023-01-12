import 'package:flutter/material.dart';

class TransferError extends StatelessWidget {
  const TransferError({Key? key, required this.error}) : super(key: key);

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cancel_outlined,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Transfer error occured: $error'),
            ),
          ]),
    );
  }
}
