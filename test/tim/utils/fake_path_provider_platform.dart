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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A fake for [PathProviderPlatform] that returns real folders under the system's temp directory.
class FakePathProviderPlatform
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  FakePathProviderPlatform() {
    for (final path in _allPaths) {
      Directory(path).createSync(recursive: true);
    }
  }

  @override
  Future<String> getTemporaryPath() async => _temporaryPath;

  @override
  Future<String> getApplicationSupportPath() async => _applicationSupportPath;

  @override
  Future<String> getLibraryPath() async => _libraryPath;

  @override
  Future<String> getApplicationDocumentsPath() async =>
      _applicationDocumentsPath;

  @override
  Future<String> getExternalStoragePath() async => _externalStoragePath;

  @override
  Future<List<String>> getExternalCachePaths() async => [_externalCachePath];

  @override
  Future<List<String>> getExternalStoragePaths(
          {StorageDirectory? type}) async =>
      [await getExternalStoragePath()];

  @override
  Future<String> getDownloadsPath() async => _downloadsPath;
}

final _rootPath = "${Directory.systemTemp.path}/tim";
final _temporaryPath = "$_rootPath/temporaryPath";
final _applicationSupportPath = "$_rootPath/applicationSupportPath";
final _libraryPath = "$_rootPath/libraryPath";
final _applicationDocumentsPath = "$_rootPath/applicationDocumentsPath";
final _externalStoragePath = "$_rootPath/externalStoragePath";
final _externalCachePath = "$_rootPath/externalCachePath";
final _downloadsPath = "$_rootPath/downloadsPath";

final _allPaths = [
  _rootPath,
  _temporaryPath,
  _applicationSupportPath,
  _libraryPath,
  _applicationDocumentsPath,
  _externalStoragePath,
  _externalCachePath,
  _downloadsPath
];
