import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import '../src/rust/wormhole/types/t_update.dart';
import '../src/rust/wormhole/types/events.dart';
import '../src/rust/wormhole/types/value.dart';

/// Generates a demo receive stream that simulates downloading a file
/// without actually connecting to a wormhole server.
/// This is used for App Store review demonstrations.
Stream<TUpdate> generateDemoReceiveStream(String downloadPath) async* {
  // Step 1: Connecting
  yield const TUpdate(
    event: Events.connecting,
    value: Value.int(0),
  );
  await Future.delayed(const Duration(milliseconds: 800));

  // Step 2: Start transfer
  yield const TUpdate(
    event: Events.startTransfer,
    value: Value.int(0),
  );
  await Future.delayed(const Duration(milliseconds: 500));

  // Step 3: Send total size (1MB demo file)
  const int totalBytes = 1048576; // 1 MB
  yield const TUpdate(
    event: Events.total,
    value: Value.int(totalBytes),
  );
  await Future.delayed(const Duration(milliseconds: 200));

  // Step 4: Simulate progress in chunks
  const int chunkSize = 131072; // 128 KB chunks
  for (int sent = chunkSize; sent <= totalBytes; sent += chunkSize) {
    final int bytesToSend = sent > totalBytes ? totalBytes : sent;
    yield TUpdate(
      event: Events.sent,
      value: Value.int(bytesToSend),
    );
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Step 5: Copy demo file from assets to download path
  // Load the demo file from assets
  final ByteData data = await rootBundle.load('assets/demo/WormholeDemo.pdf');
  final List<int> bytes = data.buffer.asUint8List();

  // Create the destination file path
  final String fileName = 'WormholeDemo.pdf';
  String destinationPath = '$downloadPath${Platform.pathSeparator}$fileName';

  // Handle file name conflicts (add number suffix if file exists)
  int counter = 1;
  while (File(destinationPath).existsSync()) {
    destinationPath =
        '$downloadPath${Platform.pathSeparator}WormholeDemo ($counter).pdf';
    counter++;
  }

  // Write the file
  final File file = File(destinationPath);
  await file.writeAsBytes(bytes);
  final finalPath = destinationPath;

  await Future.delayed(const Duration(milliseconds: 300));

  // Step 6: Finished
  yield TUpdate(
    event: Events.finished,
    value: Value.string(finalPath),
  );
}
