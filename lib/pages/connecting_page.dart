import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_scanner/media_scanner.dart';

import '../l10n/app_localizations.dart';
import '../src/rust/api/wormhole.dart';
import '../navigation/cancel_action_scope.dart';
import '../navigation/disallow_pop_context.dart';
import '../transfer/transfer_activity.dart';
import 'transfer_widgets/transfer_code.dart';
import 'transfer_widgets/transfer_connecting.dart';
import 'transfer_widgets/transfer_error.dart';
import 'transfer_widgets/transfer_progress.dart';
import 'transfer_widgets/transfer_zip_progress.dart';
import 'type_helpers.dart';

class ConnectingPage extends StatefulWidget {
  const ConnectingPage({
    super.key,
    required this.stream,
    required this.finish,
    this.onCancel,
  });

  final Stream<TUpdate> stream;
  final Widget Function(String file) finish;

  /// Aborts the running transfer. When set, the app bar shows a cancel
  /// button and the back gesture asks to cancel instead of being blocked.
  final VoidCallback? onCancel;

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
  late final TransferActivity transferActivity;
  StreamSubscription<TUpdate>? transferSubscription;

  /// Whether the transfer is still running and can be cancelled.
  bool _running = true;
  bool _confirmingCancel = false;
  BuildContext? _cancelDialogContext;
  ValueNotifier<VoidCallback?>? _cancelAction;

  final StreamController<TUpdate> controller =
      StreamController<TUpdate>.broadcast();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (transferSubscription != null) return;

    // The transfer stream from the Rust bridge is single-subscription. If this
    // page ever gets remounted (its State recreated) the stream is already
    // consumed; closing the controller shows the connection-closed error
    // instead of crashing the build (see issue #196).
    try {
      unawaited(controller.addStream(widget.stream));
    } on StateError {
      unawaited(controller.close());
    }

    final localizations = AppLocalizations.of(context)!;
    transferActivity = TransferActivity(
      strings: TransferActivityStrings(
        title: localizations.notification_transfer_title,
        channel: localizations.notification_transfer_channel,
        connecting: localizations.notification_transfer_connecting,
        waiting: localizations.notification_transfer_waiting,
        preparing: localizations.notification_transfer_preparing,
        transferring: localizations.notification_transfer_transferring,
        progress: localizations.notification_transfer_progress,
      ),
    );
    unawaited(transferActivity.start());

    if (widget.onCancel != null) {
      _cancelAction = CancelActionScope.maybeOf(context)
        ?..value = _confirmCancel;
    }
    transferSubscription = controller.stream.listen((e) {
      unawaited(transferActivity.handleUpdate(e));
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
        case Events.finished:
        case Events.error:
          _onTransferEnded();
          break;
        default:
          break;
      }
    }, onError: (_, __) {
      _onTransferEnded();
      unawaited(transferActivity.stop());
    }, onDone: () {
      _onTransferEnded();
      unawaited(transferActivity.stop());
    });
  }

  Widget _handleEvent(TUpdate event) {
    switch (event.event) {
      case Events.connecting:
        return _guardIfCancellable(const TransferConnecting());
      case Events.code:
        return _guardIfCancellable(TransferCode(
          data: event,
        ));
      case Events.startTransfer:
      case Events.connectionType:
      case Events.total:
      case Events.sent:
        return _guard(TransferProgress(
            sent: sent,
            total: total,
            estimatedBytesPerSecond: estimatedBytesPerSecond,
            linkType: connectionType,
            linkName: connectionTypeName));
      case Events.error:
        _stopEstimateTimer();
        return TransferError(
            error: event.value.field0 as ErrorType,
            message: event.value is Value_ErrorValue
                ? (event.value as Value_ErrorValue).field1
                : null);
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
        return widget.finish(file);
      case Events.zipFilesTotal:
      case Events.zipFiles:
        return _guard(TransferZipProgress(
          data: event,
          totalFileNr: totalFileNr,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TUpdate>(
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return _guard(const TransferConnecting());
          case ConnectionState.waiting:
            return _guard(const TransferConnecting());
          case ConnectionState.active:
            final d = snapshot.data!;
            return _handleEvent(d);
          case ConnectionState.done:
            return TransferError(
              error: ErrorType.connectionError,
              message: 'Connection Stream closed',
            );
        }
      },
      stream: controller.stream,
    );
  }

  /// Keeps the user on the page while the transfer runs. For cancellable
  /// transfers the back gesture asks to cancel.
  Widget _guard(Widget child) {
    if (widget.onCancel == null) {
      return DisallowPopContext(child: child);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmCancel());
      },
      child: child,
    );
  }

  /// Leaving is allowed here without a way to cancel, as the transfer did
  /// not start yet.
  Widget _guardIfCancellable(Widget child) {
    return widget.onCancel == null ? child : _guard(child);
  }

  Future<void> _confirmCancel() async {
    if (!_running || _confirmingCancel) return;
    _confirmingCancel = true;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        _cancelDialogContext = context;
        return AlertDialog(
          content: Text(l10n.transfer_cancel_confirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.transfer_cancel_confirm_no),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.transfer_cancel_confirm_yes),
            ),
          ],
        );
      },
    );
    _cancelDialogContext = null;
    _confirmingCancel = false;

    // the transfer may have ended while the dialog was open
    if (confirmed != true || !_running || !mounted) return;
    _running = false;
    _clearCancelAction();
    widget.onCancel!();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Nothing left to cancel, so close a still open confirmation dialog.
  void _onTransferEnded() {
    _running = false;
    _clearCancelAction();
    final dialogContext = _cancelDialogContext;
    if (dialogContext != null && dialogContext.mounted) {
      Navigator.of(dialogContext).pop(false);
    }
  }

  void _clearCancelAction() {
    final action = _cancelAction;
    // a newer transfer page may own the button by now
    if (action != null && action.value == _confirmCancel) {
      action.value = null;
    }
  }

  @override
  void dispose() {
    _clearCancelAction();
    _stopEstimateTimer();
    final subscription = transferSubscription;
    if (subscription != null) {
      unawaited(subscription.cancel());
      unawaited(transferActivity.stop());
    }
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
