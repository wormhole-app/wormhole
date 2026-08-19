#!/bin/bash
# This script prepares the codebase for F-Droid build by replacing the QR scanner
# implementation to use only flutter_zxing instead of mobile_scanner

set -e

SCANNER_FILE="lib/pages/qr_scanner_page.dart"
PUBSPEC_FILE="pubspec.yaml"

# Replace the conditional logic to use flutter_zxing on all platforms.
# The '/^class _MobileScannerView/,/^}$/d' range matches twice: once for the
# _MobileScannerView widget and once for its _MobileScannerViewState.
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' 's/_buildMobileScannerWidget(context)/_buildFlutterZxingWidget(context)/g' "$SCANNER_FILE"
  sed -i '' '/mobile_scanner:/d' "$PUBSPEC_FILE"
  sed -i '' "/import 'package:mobile_scanner\/mobile_scanner.dart';/d" "$SCANNER_FILE"
  sed -i '' '/Widget _buildMobileScannerWidget/,/^  }/d' "$SCANNER_FILE"
  sed -i '' '/^class _MobileScannerView/,/^}$/d' "$SCANNER_FILE"
else
  sed -i 's/_buildMobileScannerWidget(context)/_buildFlutterZxingWidget(context)/g' "$SCANNER_FILE"
  sed -i '/mobile_scanner:/d' "$PUBSPEC_FILE"
  sed -i "/import 'package:mobile_scanner\/mobile_scanner.dart';/d" "$SCANNER_FILE"
  sed -i '/Widget _buildMobileScannerWidget/,/^  }/d' "$SCANNER_FILE"
  sed -i '/^class _MobileScannerView/,/^}$/d' "$SCANNER_FILE"
fi

echo "F-Droid build preparation complete:"
echo "  - Replaced _buildMobileScannerWidget with _buildFlutterZxingWidget"
echo "  - Removed _buildMobileScannerWidget method from qr_scanner_page.dart"
echo "  - Removed the _MobileScannerView classes from qr_scanner_page.dart"
echo "  - Removed mobile_scanner import from qr_scanner_page.dart"
echo "  - Removed mobile_scanner dependency from pubspec.yaml"
