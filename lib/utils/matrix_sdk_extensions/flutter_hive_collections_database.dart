/*
 * Modified by akquinet GmbH on 16.10.2023
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' hide Key;
import 'package:flutter/services.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';

class FlutterHiveCollectionsDatabase extends HiveCollectionsDatabase {
  FlutterHiveCollectionsDatabase(
    String name,
    String path, {
    HiveCipher? key,
  }) : super(
          name,
          path,
          key: key,
        );

  static const String _cipherStorageKey = 'hive_encryption_key';

  static Future<FlutterHiveCollectionsDatabase> databaseBuilder(
    Client client,
  ) async {
    Logs().d('Open Hive...');
    HiveAesCipher? hiverCipher;
    try {
      // Workaround for secure storage is calling Platform.operatingSystem on web
      if (kIsWeb) throw MissingPluginException();

      const secureStorage = FlutterSecureStorage();
      final containsEncryptionKey =
          await secureStorage.read(key: _cipherStorageKey) != null;
      if (!containsEncryptionKey) {
        // do not try to create a buggy secure storage for new Linux users
        if (Platform.isLinux) throw MissingPluginException();
        final key = Hive.generateSecureKey();
        await secureStorage.write(
          key: _cipherStorageKey,
          value: base64UrlEncode(key),
        );
      }

      // workaround for if we just wrote to the key and it still doesn't exist
      final rawEncryptionKey = await secureStorage.read(key: _cipherStorageKey);
      if (rawEncryptionKey == null) throw MissingPluginException();

      hiverCipher = HiveAesCipher(base64Url.decode(rawEncryptionKey));
    } on MissingPluginException catch (_) {
      const FlutterSecureStorage()
          .delete(key: _cipherStorageKey)
          .catchError((_) {});
      Logs().i('Hive encryption is not supported on this platform');
    } catch (e, s) {
      const FlutterSecureStorage()
          .delete(key: _cipherStorageKey)
          .catchError((_) {});
      Logs().w('Unable to init Hive encryption', e, s);
    }

    final db = FlutterHiveCollectionsDatabase(
      'hive_collections_${client.clientName.replaceAll(' ', '_').toLowerCase()}',
      await _findDatabasePath(client),
      key: hiverCipher,
    );
    try {
      await db.open();
    } catch (e, s) {
      Logs().w('Unable to open Hive. Delete database and storage key...', e, s);
      const FlutterSecureStorage().delete(key: _cipherStorageKey);
      await db.clear().catchError((_) {});
      await Hive.deleteFromDisk();
      rethrow;
    }
    Logs().d('Hive is ready');
    return db;
  }

  static Future<String> _findDatabasePath(Client client) async {
    String path = client.clientName;
    if (!kIsWeb) {
      Directory directory;
      try {
        if (Platform.isLinux) {
          directory = await getApplicationSupportDirectory();
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
      } catch (_) {
        try {
          directory = await getLibraryDirectory();
        } catch (_) {
          directory = Directory.current;
        }
      }
      // do not destroy your stable FluffyChat in debug mode
      directory = Directory(
        directory.uri.resolve(kDebugMode ? 'hive_debug' : 'hive').toFilePath(),
      );
      directory.create(recursive: true);
      path = directory.path;
    }
    return path;
  }

  @override
  int get maxFileSize => supportsFileStoring ? 100 * 1024 * 1024 : 0;
  @override
  bool get supportsFileStoring => !kIsWeb;

  Future<String> _getFileStoreDirectory() async {
    try {
      try {
        return (await getTemporaryDirectory()).path;
      } catch (_) {
        return (await getApplicationDocumentsDirectory()).path;
      }
    } catch (_) {
      return (await getDownloadsDirectory())!.path;
    }
  }

  @override
  Future<Uint8List?> getFile(Uri mxcUri) async {
    if (!supportsFileStoring) return null;
    final tempDirectory = await _getFileStoreDirectory();
    final file =
        File('$tempDirectory/${Uri.encodeComponent(mxcUri.toString())}');
    if (await file.exists() == false) return null;
    final bytes = await file.readAsBytes();
    return bytes;
  }

  @override
  Future storeFile(Uri mxcUri, Uint8List bytes, int time) async {
    if (!supportsFileStoring) return null;
    final tempDirectory = await _getFileStoreDirectory();
    final file =
        File('$tempDirectory/${Uri.encodeComponent(mxcUri.toString())}');
    if (await file.exists()) return;
    await file.writeAsBytes(bytes);
    return;
  }
}
