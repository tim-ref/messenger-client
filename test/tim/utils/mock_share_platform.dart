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

import 'dart:ui';

import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/platform_interface/share_plus_platform.dart';

/// Mocking static SharePlatform is tricky.
/// We need to include [MockPlatformInterfaceMixin] or the mock will fail at runtime, so we cannot have Mockito create
/// the mock via build runner. Also, because mocks that are not created using Mockito's build runner do not work well
/// with null-safety, we need to define the to-be-mocked methods ourselves, compare
/// [https://github.com/dart-lang/mockito/blob/master/NULL_SAFETY_README.md].
class MockSharePlatform extends Mock with MockPlatformInterfaceMixin implements SharePlatform {
  @override
  Future<ShareResult> shareXFiles(
    List<XFile>? files, {
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
  }) async => (super.noSuchMethod(
        Invocation.method(
          #shareXFiles,
          [files],
          {
            #subject: subject,
            #text: text,
            #sharePositionOrigin: sharePositionOrigin,
          },
        ),
        returnValue: Future<ShareResult>.value(const ShareResult("dev.fluttercommunity.plus/share/unavailable", ShareResultStatus.unavailable)),
        returnValueForMissingStub: Future<ShareResult>.value(const ShareResult("dev.fluttercommunity.plus/share/unavailable", ShareResultStatus.unavailable)),
      ));
}
