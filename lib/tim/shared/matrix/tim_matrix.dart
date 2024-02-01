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

import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:fluffychat/tim/shared/matrix/tim_matrix_crypto.dart';
import 'package:matrix/matrix.dart' as matrix;

/// Abstraction for services that communicate using Matrix.
abstract class TimMatrix {
  TimMatrixClient client();

  TimMatrixCrypto crypto();
}

class TimMatrixImpl implements TimMatrix {
  final TimMatrixClient _client;
  final TimMatrixCrypto _crypto;

  TimMatrixImpl(matrix.Client client)
      : _client = TimMatrixClientImpl(client: client),
        _crypto = TimMatrixCryptoImpl(client: client);

  @override
  TimMatrixClient client() => _client;

  @override
  TimMatrixCrypto crypto() => _crypto;
}
