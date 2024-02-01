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

import 'package:matrix/matrix.dart' as matrix;

/// Abstraction to access Matrix cryptography functions.
abstract class TimMatrixCrypto {
  /// See [Encryption.decryptRoomEvent].
  Future<matrix.Event> decryptRoomEvent(String roomId, matrix.Event event);
}

class TimMatrixCryptoImpl implements TimMatrixCrypto {
  final matrix.Client client;

  TimMatrixCryptoImpl({required this.client});

  @override
  Future<matrix.Event> decryptRoomEvent(
          String roomId, matrix.Event event) async =>
      (await client.encryption?.decryptRoomEvent(roomId, event)) ?? event;
}
