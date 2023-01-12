import 'package:flutter/material.dart';

class TransferConnecting extends StatelessWidget {
  const TransferConnecting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text('Connecting...'),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: LinearProgressIndicator(
              minHeight: 10,
            ),
          )
        ],
      ),
    );
  }
}
