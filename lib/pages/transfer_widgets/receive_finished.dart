import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class ReceiveFinished extends StatelessWidget {
  const ReceiveFinished({Key? key, required this.file}) : super(key: key);

  final String file;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Finished receive of file!'),
            ),
            const SizedBox(
              height: 25,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: SizedBox(
                width: 120,
                height: 40,
                child: ElevatedButton(
                    onPressed: () {
                      OpenFilex.open(file);
                    },
                    child: const Text(
                      'Open file',
                    )),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: SizedBox(
                width: 120,
                height: 40,
                child: ElevatedButton(
                    onPressed: () {
                      Share.shareXFiles([XFile(file)],
                          text: file.split('/').last);
                    },
                    child: const Text(
                      'Share file',
                    )),
              ),
            ),
          ]),
    );
  }
}
