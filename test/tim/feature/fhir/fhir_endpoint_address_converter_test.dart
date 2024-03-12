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
import 'package:flutter_test/flutter_test.dart';

void main() {

  const mxIdSigil = "@mxid:homeserver";
  const mxIdUri = "matrix:u/mxid:homeserver";


  test('should convert endpoint address from sigil to uri format', () {
    //when
    final result = convertSigilToUri(mxIdSigil);

    //then
    expect(result, equals(mxIdUri));
  });

  test('should not convert endpoint address already in uri format', () {
    //when
    final result = convertSigilToUri(mxIdUri);

    //then
    expect(result, equals(mxIdUri));
  });

  test('should convert endpoint address from uri to sigil format', () {
    //when
    final result = convertUriToSigil(mxIdUri);

    //then
    expect(result, equals(mxIdSigil));
  });

  test('should not convert endpoint address already in sigil format', () {
    //when
    final result = convertUriToSigil(mxIdSigil);

    //then
    expect(result, equals(mxIdSigil));
  });
}