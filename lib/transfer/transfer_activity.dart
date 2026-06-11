import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../src/rust/api/wormhole.dart';

typedef NotificationPermissionRequester = Future<void> Function();

class TransferActivityStrings {
  const TransferActivityStrings({
    required this.title,
    required this.channel,
    required this.connecting,
    required this.waiting,
    required this.preparing,
    required this.transferring,
    required this.progress,
  });

  final String title;
  final String channel;
  final String connecting;
  final String waiting;
  final String preparing;
  final String transferring;
  final String Function(int percent) progress;
}

class TransferActivity {
  TransferActivity({
    required TransferActivityStrings strings,
    MethodChannel channel =
        const MethodChannel('io.wormhole.app/transfer_activity'),
    bool? isAndroid,
    NotificationPermissionRequester? requestNotificationPermission,
    DateTime Function()? now,
  })  : _strings = strings,
        _channel = channel,
        _isAndroid = isAndroid ??
            (!kIsWeb && defaultTargetPlatform == TargetPlatform.android),
        _requestNotificationPermission =
            requestNotificationPermission ?? _requestPermission,
        _now = now ?? DateTime.now;

  static const Duration _progressUpdateInterval = Duration(seconds: 1);
  static const int _progressMax = 1000;

  final MethodChannel _channel;
  final TransferActivityStrings _strings;
  final bool _isAndroid;
  final NotificationPermissionRequester _requestNotificationPermission;
  final DateTime Function() _now;

  BigInt? _total;
  DateTime? _lastProgressUpdate;
  bool _started = false;
  bool _stopped = false;

  Future<void> start() async {
    if (!_isAndroid || _started) return;
    _started = true;

    unawaited(_requestNotificationPermission().catchError((Object error) {
      debugPrint('Failed to request notification permission: $error');
    }));
    await _invoke('start', {'status': _strings.connecting});
  }

  Future<void> handleUpdate(TUpdate update) async {
    if (!_isAndroid || !_started || _stopped) return;

    switch (update.event) {
      case Events.connecting:
        await _update(status: _strings.connecting);
        break;
      case Events.code:
        await _update(status: _strings.waiting);
        break;
      case Events.total:
        _total = update.value.field0 as BigInt;
        break;
      case Events.startTransfer:
        _lastProgressUpdate = null;
        await _update(
          status: _transferStatus(calculateProgress(BigInt.zero, _total)),
          progress: calculateProgress(BigInt.zero, _total),
        );
        break;
      case Events.sent:
        final progress =
            calculateProgress(update.value.field0 as BigInt, _total);
        final now = _now();
        if (progress == _progressMax ||
            _lastProgressUpdate == null ||
            now.difference(_lastProgressUpdate!) >= _progressUpdateInterval) {
          _lastProgressUpdate = now;
          await _update(status: _transferStatus(progress), progress: progress);
        }
        break;
      case Events.zipFilesTotal:
        await _update(status: _strings.preparing);
        break;
      case Events.error:
      case Events.finished:
        await stop();
        break;
      case Events.connectionType:
      case Events.zipFiles:
        break;
    }
  }

  Future<void> stop() async {
    if (!_isAndroid || !_started || _stopped) return;
    _stopped = true;
    await _invoke('stop');
  }

  @visibleForTesting
  static int? calculateProgress(BigInt sent, BigInt? total) {
    if (total == null || total <= BigInt.zero) return null;
    final progress = sent * BigInt.from(_progressMax) ~/ total;
    if (progress <= BigInt.zero) return 0;
    if (progress >= BigInt.from(_progressMax)) return _progressMax;
    return progress.toInt();
  }

  Future<void> _update({required String status, int? progress}) {
    return _invoke('update', {
      'status': status,
      if (progress != null) 'progress': progress,
    });
  }

  Future<void> _invoke(String method, [Map<String, Object>? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, {
        'title': _strings.title,
        'channel': _strings.channel,
        ...?arguments,
      });
    } on PlatformException catch (error) {
      debugPrint('Transfer activity failed: ${error.message}');
    } on MissingPluginException {
      // The foreground transfer service is only available on Android.
    }
  }

  static Future<void> _requestPermission() async {
    await Permission.notification.request();
  }

  String _transferStatus(int? progress) {
    return progress == null
        ? _strings.transferring
        : _strings.progress(progress ~/ 10);
  }
}
