import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../l10n/app_localizations.dart';
import '../settings/settings.dart';
import '../transfer/transfer_provider.dart';
import '../utils/code.dart';
import '../utils/logger.dart';
import 'toasts/error_toast.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  /// The camera keeps reporting detections; only the first one may act,
  /// otherwise a single scan would pop the page multiple times.
  bool _handled = false;

  /// Camera views initialize the camera as soon as they are built, which
  /// makes the page transition stutter and slides in an uninitialized void.
  /// The scanner only mounts once the transition is done, and stays behind
  /// an opaque cover until the camera renders frames.
  bool _transitionDone = false;
  bool _cameraReady = false;
  Animation<double>? _routeAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_transitionDone || _routeAnimation != null) return;

    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) {
      _transitionDone = true;
    } else {
      _routeAnimation = animation;
      animation.addStatusListener(_onRouteAnimationStatus);
    }
  }

  void _onRouteAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    _routeAnimation = null;
    setState(() => _transitionDone = true);
  }

  /// Called by the scanner view once the camera is up.
  void _onCameraReady() {
    if (mounted && !_cameraReady) {
      setState(() => _cameraReady = true);
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    super.dispose();
  }

  void _onQrDetect(String? code, BuildContext context) {
    if (_handled) return;
    _handled = true;

    if (code != null) {
      AppLogger.info('Barcode found: $code');

      final uri = Uri.parse(code);

      // assume its a valid code if it starts with this string
      if (uri.scheme == 'wormhole-transfer') {
        final passphrase = uri.path;

        if (isCodeValid(passphrase)) {
          unawaited(Settings.getHapticFeedback().then((enabled) {
            if (enabled) {
              Vibration.vibrate();
            }
          }));
          final transfer =
              Provider.of<TransferProvider>(context, listen: false);
          Navigator.of(context).pop();
          transfer.receiveFile(passphrase);
          return;
        }
        // todo handle extra query parameters
      }

      AppLogger.warn('Invalid QR code scanned');
      Navigator.of(context).pop();
      ErrorToast(message: AppLocalizations.of(context)!.toast_error_qr_invalid)
          .show(context);
    } else {
      AppLogger.warn('Failed to scan barcode');
      Navigator.of(context).pop();
      ErrorToast(message: AppLocalizations.of(context)!.toast_error_qr_fail)
          .show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_transitionDone) _buildMobileScannerWidget(context),
        // Opaque cover while the camera spins up: the page slides in looking
        // like the rest of the app instead of an uninitialized void, and the
        // preview fades in once it has frames to show.
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _cameraReady ? 0 : 1,
            duration: const Duration(milliseconds: 100),
            child: ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildFlutterZxingWidget(BuildContext context) {
    return _FlutterZxingView(
      onDetect: _onQrDetect,
      onCameraReady: _onCameraReady,
    );
  }

  // ignore: unused_element
  Widget _buildMobileScannerWidget(BuildContext context) {
    return _MobileScannerView(
      onDetect: _onQrDetect,
      onCameraReady: _onCameraReady,
    );
  }
}

// flutter_zxing scanner, used by the F-Droid build
// (see scripts/prepare-fdroid-build.sh).
// ignore: unused_element
class _FlutterZxingView extends StatelessWidget {
  const _FlutterZxingView(
      {required this.onDetect, required this.onCameraReady});

  final void Function(String? code, BuildContext context) onDetect;
  final VoidCallback onCameraReady;

  @override
  Widget build(BuildContext context) {
    return ReaderWidget(
      tryInverted: true,
      cropPercent: 1.0,
      showScannerOverlay: false,
      tryDownscale: true,
      scanDelay: const Duration(milliseconds: 16),
      onControllerCreated: (controller, error) {
        if (error != null) {
          AppLogger.error('Failed to start QR scanner camera: $error');
        }
        onCameraReady();
      },
      onScan: (result) async {
        onDetect(result.text, context);
      },
    );
  }
}

// mobile_scanner scanner, the default. Stripped out for the F-Droid build by
// scripts/prepare-fdroid-build.sh, because mobile_scanner depends on the
// proprietary MLKit. Keep all mobile_scanner usage inside these two classes.
class _MobileScannerView extends StatefulWidget {
  const _MobileScannerView(
      {required this.onDetect, required this.onCameraReady});

  final void Function(String? code, BuildContext context) onDetect;
  final VoidCallback onCameraReady;

  @override
  State<_MobileScannerView> createState() => _MobileScannerViewState();
}

class _MobileScannerViewState extends State<_MobileScannerView> {
  final MobileScannerController _controller =
      MobileScannerController(autoStart: false);

  @override
  void initState() {
    super.initState();
    // The controller can only start once the MobileScanner widget is built
    // and attached to it, so wait for the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCamera());
  }

  void _startCamera() async {
    if (!mounted) return;
    try {
      await _controller.start();
      // The platform view needs a moment to composite its first camera
      // frames; lifting the cover right away would reveal a white flash
      // instead of the preview.
      await Future.delayed(const Duration(milliseconds: 100));
    } on Exception catch (e) {
      // Lifting the cover reveals MobileScanner's own error UI.
      AppLogger.error('Failed to start QR scanner camera: $e');
    }
    widget.onCameraReady();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _controller,
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          if (barcode.rawValue != null) {
            widget.onDetect(barcode.rawValue, context);
            break;
          }
        }
      },
    );
  }
}
