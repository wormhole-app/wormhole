import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_scanner/media_scanner.dart';

import '../src/rust/api/wormhole.dart';
import '../navigation/back_pop_context.dart';
import '../navigation/disallow_pop_context.dart';
import 'transfer_widgets/transfer_code.dart';
import 'transfer_widgets/transfer_connecting.dart';
import 'transfer_widgets/transfer_error.dart';
import 'transfer_widgets/transfer_progress.dart';
import 'transfer_widgets/transfer_zip_progress.dart';
import 'type_helpers.dart';

class ConnectingPage extends StatefulWidget {
  const ConnectingPage({super.key, required this.stream, required this.finish});

  final Stream<TUpdate> stream;
  final Widget Function(String file) finish;

  @override
  State<ConnectingPage> createState() => _ConnectingPageState();
}

class _ConnectingPageState extends State<ConnectingPage> {
  static const Duration _transferEstimateInterval = Duration(seconds: 1);
  static const Duration _transferEstimateSmoothingWindow = Duration(seconds: 3);

  BigInt? total;
  BigInt? totalFileNr;
  BigInt sent = BigInt.zero;
  BigInt estimateSampleSent = BigInt.zero;
  DateTime? transferStartedAt;
  double? estimatedBytesPerSecond;
  Timer? estimateTimer;
  ConnectionType? connectionType;
  String? connectionTypeName;

  late StreamController<TUpdate> controller =
      StreamController<TUpdate>.broadcast()..addStream(widget.stream);

  @override
  void initState() {
    super.initState();
    controller.stream.listen((e) {
      switch (e.event) {
        case Events.total:
          total = e.getValue();
          break;
        case Events.startTransfer:
          sent = BigInt.zero;
          estimateSampleSent = sent;
          transferStartedAt = DateTime.now();
          estimatedBytesPerSecond = null;
          _startEstimateTimer();
          break;
        case Events.sent:
          sent = e.getValue();
          _setFirstTransferEstimate();
          break;
        case Events.connectionType:
          connectionType = (e.value as Value_ConnectionType).field0;
          connectionTypeName = (e.value as Value_ConnectionType).field1;
          break;
        case Events.zipFilesTotal:
          totalFileNr = e.getValue();
          break;
        default:
          break;
      }
    });
  }

  Widget _handleEvent(TUpdate event) {
    switch (event.event) {
      case Events.connecting:
        return const TransferConnecting();
      case Events.code:
        return BackPopContext(
          child: TransferCode(
            data: event,
          ),
        );
      case Events.startTransfer:
      case Events.connectionType:
      case Events.total:
      case Events.sent:
        return DisallowPopContext(
          child: TransferProgress(
              sent: sent,
              total: total,
              estimatedBytesPerSecond: estimatedBytesPerSecond,
              linkType: connectionType,
              linkName: connectionTypeName),
        );
      case Events.error:
        _stopEstimateTimer();
        return BackPopContext(
            child: TransferError(
                error: event.value.field0 as ErrorType,
                message: event.value is Value_ErrorValue
                    ? (event.value as Value_ErrorValue).field1
                    : null));
      case Events.finished:
        _stopEstimateTimer();
        final String file = event.getValue();
        if (Platform.isAndroid) {
          // register the new device to the Android Media Database
          try {
            MediaScanner.loadMedia(path: file);
          } on PlatformException {
            debugPrint('Failed to trigger media scan for $file');
          }
        }
        return BackPopContext(child: widget.finish(file));
      case Events.zipFilesTotal:
      case Events.zipFiles:
        return DisallowPopContext(
          child: TransferZipProgress(
            data: event,
            totalFileNr: totalFileNr,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TUpdate>(
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const DisallowPopContext(child: TransferConnecting());
          case ConnectionState.waiting:
            return const DisallowPopContext(child: TransferConnecting());
          case ConnectionState.active:
            final d = snapshot.data!;
            return _handleEvent(d);
          case ConnectionState.done:
            return const BackPopContext(
                child: TransferError(
              error: ErrorType.connectionError,
              message: 'Connection Stream closed',
            ));
        }
      },
      stream: controller.stream,
    );
  }

  @override
  void dispose() {
    _stopEstimateTimer();
    super.dispose();
  }

  void _startEstimateTimer() {
    _stopEstimateTimer();
    estimateTimer = Timer.periodic(
      _transferEstimateInterval,
      (_) => _updateTransferEstimates(),
    );
  }

  void _stopEstimateTimer() {
    estimateTimer?.cancel();
    estimateTimer = null;
  }

  void _setFirstTransferEstimate() {
    if (estimatedBytesPerSecond != null || sent <= BigInt.zero) {
      return;
    }

    final startedAt = transferStartedAt;
    if (startedAt == null) {
      return;
    }

    final elapsedSeconds =
        DateTime.now().difference(startedAt).inMilliseconds / 1000;
    if (elapsedSeconds <= 0) {
      return;
    }

    estimatedBytesPerSecond = sent.toDouble() / elapsedSeconds;
  }

  void _updateTransferEstimates() {
    final updatedSent = sent;
    final sampleSent = estimateSampleSent;
    estimateSampleSent = updatedSent;

    if (updatedSent <= sampleSent) {
      estimatedBytesPerSecond = null;
      return;
    }

    final transferredBytes = updatedSent - sampleSent;
    final instantBytesPerSecond =
        transferredBytes.toDouble() / _transferEstimateInterval.inSeconds;
    estimatedBytesPerSecond = _ema(
      current: estimatedBytesPerSecond,
      sample: instantBytesPerSecond,
      alpha: _emaAlpha(),
    );

    if (mounted) {
      setState(() {});
    }
  }

  double _emaAlpha() {
    return 1 -
        math.exp(-_transferEstimateInterval.inMilliseconds /
            _transferEstimateSmoothingWindow.inMilliseconds);
  }

  double _ema({
    required double? current,
    required double sample,
    required double alpha,
  }) {
    if (current == null) {
      return sample;
    }
    return current + alpha * (sample - current);
  }
}
