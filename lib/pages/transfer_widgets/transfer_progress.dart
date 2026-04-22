import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../src/rust/api/wormhole.dart';
import '../../utils/file_formatter.dart';

class TransferProgress extends StatelessWidget {
  const TransferProgress(
      {super.key,
      required this.sent,
      required this.total,
      this.estimatedBytesPerSecond,
      this.linkType,
      this.linkName});

  final BigInt sent;
  final BigInt? total;
  final double? estimatedBytesPerSecond;
  final ConnectionType? linkType;
  final String? linkName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estimatedRemaining = _estimatedRemaining;
    double? percent;
    if (total != null) {
      percent = sent.toDouble() / total!.toDouble();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              '${sent.toInt().readableFileSize()}/${total?.toInt().readableFileSize()}'),
          const SizedBox(
            height: 8,
          ),
          Text(
            '${AppLocalizations.of(context)!.transfer_progress_average_speed}: ${estimatedBytesPerSecond == null ? AppLocalizations.of(context)!.transfer_progress_calculating : estimatedBytesPerSecond!.readableFileSize()}/s',
          ),
          Text(
            '${AppLocalizations.of(context)!.transfer_progress_remaining}: ${estimatedRemaining == null ? AppLocalizations.of(context)!.transfer_progress_calculating : _formatDuration(estimatedRemaining, context)}',
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: percent,
              color: theme.colorScheme.primary,
            ),
          ),
          if (linkType != null) ...[
            const SizedBox(
              height: 10,
            ),
            Text(parseLinkType(linkType!, linkName!, context)),
          ]
        ],
      ),
    );
  }

  String parseLinkType(
      ConnectionType linkType, String linkName, BuildContext context) {
    switch (linkType) {
      case ConnectionType.relay:
        final relayName = linkName;
        final locText =
            AppLocalizations.of(context)!.transfer_progress_connection_relay;
        return "$locText '$relayName'";
      case ConnectionType.direct:
        return AppLocalizations.of(context)!
            .transfer_progress_connection_direct;
    }
  }

  Duration? get _estimatedRemaining {
    final speed = estimatedBytesPerSecond;
    final totalBytes = total;
    if (speed == null ||
        speed <= 0 ||
        totalBytes == null ||
        sent >= totalBytes) {
      return null;
    }

    final remainingBytes = totalBytes - sent;
    return Duration(seconds: (remainingBytes.toDouble() / speed).ceil());
  }

  String _formatDuration(Duration duration, BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final totalSeconds = duration.inSeconds;
    if (totalSeconds < 60) {
      return loc.transfer_progress_duration_seconds(totalSeconds);
    }

    final totalMinutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (totalMinutes < 60) {
      return [
        loc.transfer_progress_duration_minutes(totalMinutes),
        if (seconds > 0) loc.transfer_progress_duration_seconds(seconds),
      ].join(' ');
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return [
      loc.transfer_progress_duration_hours(hours),
      if (minutes > 0) loc.transfer_progress_duration_minutes(minutes),
    ].join(' ');
  }
}
