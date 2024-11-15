/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/tim/feature/fhir/fhir_endpoint_address_converter.dart';
import 'package:fluffychat/utils/vcard.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Create a widget which shows a QR-Code of the active users vCard, to invite someone
///
/// AFO 5.4.12 2D-Barcode erstellen und anzeigen
/// https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-Messenger-Client/latest/#5.4.12
class NewContactQrImage extends StatelessWidget {
  const NewContactQrImage({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final mxId = Matrix.of(context).client.userID;

    if (mxId == null) return const Text('Error: No Matrix ID was found');

    final fhirEndpointAdress = convertSigilToUri(mxId);
    final identifierParts = mxId.parseIdentifierIntoParts();

    if (identifierParts == null) return Text('Error: $mxId is Not a valid Matrix ID');

    return FutureBuilder(
      future: Matrix.of(context).client.getDisplayName(mxId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final vCardData = VCard(
          name: const VCardName(),
          formattedNames: [snapshot.data ?? identifierParts.primaryIdentifier],
          impps: [fhirEndpointAdress],
        ).toString();
        return QrImage(
          data: vCardData,
          version: QrVersions.auto,
          size: size,
        );
      },
    );
  }
}
