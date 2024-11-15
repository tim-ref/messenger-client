/*
 * Modified by akquinet GmbH on 08.11.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:io';

import 'package:fluffychat/utils/matrix_uri_validation.dart';
import 'package:fluffychat/utils/vcard.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:fluffychat/utils/url_launcher.dart';

class QrScannerModal extends StatefulWidget {
  const QrScannerModal({Key? key}) : super(key: key);

  @override
  QrScannerModalState createState() => QrScannerModalState();
}

class QrScannerModalState extends State<QrScannerModal> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_outlined),
          onPressed: Navigator.of(context).pop,
          tooltip: L10n.of(context)!.close,
        ),
        title: Text(L10n.of(context)!.scanQrCode),
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Theme.of(context).primaryColor,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    // Workaround for QR Scanner is started in Pause mode
    // https://github.com/juliuscanute/qr_code_scanner/issues/538#issuecomment-1133883828
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
    late StreamSubscription sub;
    sub = controller.scannedDataStream.listen((scanData) {
      sub.cancel();
      Navigator.of(context).pop();
      _handleScanData(scanData);
    });
  }

  // AFO 5.4.13 2D-Barcode scannen und weiterverarbeiten
  void _handleScanData(Barcode scanData) {
    final data = scanData.code;
    Logs().d('found barcode data: $data');

    if (data == null || data.isEmpty) return;

    String? matrixUri;

    if (RegExp(vCardBegin).hasMatch(data)) {
      try {
        final vCard = VCard.fromString(data);
        if (vCard.impps.isNotEmpty && vCard.impps.any((e) => checkExpectedMatrixUriIsValid(e))) {
          matrixUri = vCard.impps.firstWhere((e) => checkExpectedMatrixUriIsValid(e));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(L10n.of(context)!.qrScannerModalMatrixUriIsMissingError),
          ));
        }
      } on VCardBaseException catch (e) {
        Logs().e(e.toString());
      }
    }

    UrlLauncher(context, matrixUri ?? data).openMatrixToUrl();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
