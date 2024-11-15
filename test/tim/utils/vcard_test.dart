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

import 'package:fluffychat/utils/vcard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const crlf = '\r\n';

  group('parse VCard', () {
    test('trying to parse vcard from valid string, should create vcard', () {
      const vcardData = 'BEGIN:VCARD$crlf'
          'VERSION:4.0$crlf'
          'FN:Felicitas Gräfin von Lüdenscheidt-Klöbner$crlf'
          'IMPP:matrix:u/dr_bob_tiger_1:testserver.test$crlf'
          'N:Hubertús;Tatjana,Gräfin;Maxi-Muß;Prof.,Dr.;B.Sc.$crlf'
          'FN:Tatjana Gräfin Hubertús$crlf'
          'IMPP;PREF=1:xmpp:alice@example.com$crlf'
          'END:VCARD';

      const expectedVcard = VCard(
        name: VCardName(
          familyNames: {'Hubertús'},
          givenNames: {'Tatjana', 'Gräfin'},
          additionalNames: {'Maxi-Muß'},
          honoricPrefixes: {'Prof.', 'Dr.'},
          honoricSuffixes: {'B.Sc.'},
        ),
        formattedNames: ['Felicitas Gräfin von Lüdenscheidt-Klöbner', 'Tatjana Gräfin Hubertús'],
        impps: ['matrix:u/dr_bob_tiger_1:testserver.test', 'xmpp:alice@example.com'],
      );

      final vCard = VCard.fromString(vcardData);

      expect(vCard, expectedVcard);
    });

    test('trying to convert vCard to String, should return wellformed String', () {
      const givenVCard = VCard(
        name: VCardName(
          familyNames: {'Graßl'},
          givenNames: {'Ludwig-Götz'},
        ),
        formattedNames: ['Ludwig-Götz Graßl', 'Isabelle Popówitsch'],
        impps: ['matrix:u/dr_bob_tiger_1:testserver.test', 'xmpp:alice@example.com'],
      );

      const expectedVCardData = 'BEGIN:VCARD$crlf'
          'VERSION:4.0$crlf'
          'N:Graßl;Ludwig-Götz;;;$crlf'
          'FN:Ludwig-Götz Graßl$crlf'
          'FN:Isabelle Popówitsch$crlf'
          'IMPP:matrix:u/dr_bob_tiger_1:testserver.test$crlf'
          'IMPP:xmpp:alice@example.com$crlf'
          'END:VCARD';

      final vCardData = givenVCard.toString();

      expect(vCardData, expectedVCardData);
    });

    test('trying to parse vCard from empty String, should throw exception', () {
      const vCardData = '';

      expect(() => VCard.fromString(vCardData), throwsA(isA<VCardFormatException>()));
    });

    test('trying to parse vCard from malformed String with wrong version, should throw exception',
        () {
      const vCardData = 'BEGIN:VCARD$crlf'
          'VERSION:3.0$crlf'
          'FN:Dr. Bob Tiger$crlf'
          'END:VCARD';

      expect(() => VCard.fromString(vCardData), throwsA(isA<VCardFormatException>()));
    });

    test('trying to parse vCard from malformed String without FN, should throw exception', () {
      const vCardData = 'BEGIN:VCARD$crlf'
          'VERSION:4.0$crlf'
          'N:Graßl;Ludwig-Götz;;;$crlf'
          'IMPP:matrix:u/dr_bob_tiger:testserver$crlf'
          'END:VCARD';

      expect(() => VCard.fromString(vCardData), throwsA(isA<VCardFormatException>()));
    });

    test('trying to parse vCard with minimal data, should create vcard', () {
      const vCardData = 'BEGIN:VCARD$crlf'
          'VERSION:4.0$crlf'
          'FN:Lena Freifrau Adamiç$crlf'
          'END:VCARD';

      const expectedVCard = VCard(formattedNames: ['Lena Freifrau Adamiç'], impps: []);

      final vCard = VCard.fromString(vCardData);

      expect(vCard, expectedVCard);
    });
  });

  group('parse VCardName', () {
    test('trying to parse vCardName from valid String, should parse vCardName', () {
      const vCardNameData = 'Gräfin,Wessel-Toft;Edith;Adamiç,Mondwürfel,Nöther;Prof.,Dr.;M.Sc.';

      const expectedVCardName = VCardName(
        familyNames: {'Gräfin', 'Wessel-Toft'},
        givenNames: {'Edith'},
        additionalNames: {'Adamiç', 'Mondwürfel', 'Nöther'},
        honoricPrefixes: {'Prof.', 'Dr.'},
        honoricSuffixes: {'M.Sc.'},
      );

      expect(VCardName.fromString(vCardNameData), expectedVCardName);
    });

    test('trying to parse vCardName from empty String, should throw exception', () {
      const vCardNameData = '';

      expect(() => VCardName.fromString(vCardNameData), throwsA(isA<VCardFormatException>()));
    });

    test('trying to parse vCardName missing one semicolon, should throw exception', () {
      const vCardNameData = '; semicolons; ; ';

      expect(() => VCardName.fromString(vCardNameData), throwsA(isA<VCardFormatException>()));
    });

    test('trying to parse vCardName without fullname String, should parse vCardName', () {
      const vCardNameData = ';Hännelôre,Frei frau;;;';

      const expectedVCardName = VCardName(
        givenNames: {'Hännelôre', 'Frei frau'},
      );

      expect(VCardName.fromString(vCardNameData), expectedVCardName);
    });
  });
}
