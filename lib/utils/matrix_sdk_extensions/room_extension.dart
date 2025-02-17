/*
 * Modified by akquinet GmbH on 10.02.2025
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:collection/collection.dart';
import 'package:fluffychat/tim/tim_constants.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/src/utils/markdown.dart';

/// Extend the Matrix SDK Room class with TIM custom room functionality
///
/// To get the correct values use these functions over Matrix SDK Room class
extension RoomExtension on Room {
  /// The name of the room if set by a participant.
  String get displayName {
    final state = getState(TimRoomStateEventType.roomName.value) ?? getState(EventTypes.RoomName);
    final contentName = state?.content['name'];
    return (contentName is String) ? contentName : '';
  }

  /// The topic of the room if set by a participant.
  String get displayTopic {
    final state = getState(TimRoomStateEventType.roomTopic.value) ?? getState(EventTypes.RoomName);
    final contentTopic = state?.content['topic'];
    return contentTopic is String ? contentTopic : '';
  }

  /// The type of the room, defaults to TimRoomTypes.timDefault
  String get roomType {
    return getState(EventTypes.RoomCreate)?.content.tryGet('type') ??
        TimRoomType.defaultValue.value;
  }

  /// Check if room type is casereference
  bool get isCaseReferenceRoom => roomType == TimRoomType.caseReference.value;

  /// Content of CustomRoom Type Initial State Events
  Map<String, dynamic> get caseReferenceContent {
    final state = getState(TimRoomStateEventType.caseReference.value) ??
        getState(TimRoomStateEventType.defaultValue.value);
    return state?.content ?? {};
  }

  /// Returns a localized displayname for this server. If the room is a groupchat
  /// without a name, then it will return the localized version of 'Group with Alice' instead
  /// of just 'Alice' to make it different to a direct chat.
  /// Empty chats will become the localized version of 'Empty Chat'.
  /// This method requires a localization class which implements [MatrixLocalizations]
  String getLocalizedDisplaynameFromCustomNameEvent([
    MatrixLocalizations i18n = const MatrixDefaultLocalizations(),
  ]) {
    if (displayName.isNotEmpty) return displayName;

    final canonicalAlias = this.canonicalAlias.localpart;
    if (canonicalAlias != null && canonicalAlias.isNotEmpty) {
      return canonicalAlias;
    }

    final directChatMatrixID = this.directChatMatrixID;
    final heroes = summary.mHeroes ?? (directChatMatrixID == null ? [] : [directChatMatrixID]);
    if (heroes.isNotEmpty) {
      final result = heroes
          .where((hero) => hero.isNotEmpty)
          .map((hero) => unsafeGetUserFromMemoryOrFallback(hero).calcDisplayname())
          .join(', ');
      if (isAbandonedDMRoom) {
        return i18n.wasDirectChatDisplayName(result);
      }

      return isDirectChat ? result : i18n.groupWith(result);
    }
    switch (membership) {
      case Membership.invite:
        final event = getState(EventTypes.RoomMember, client.userID!);
        if (event is Event) {
          return event.senderFromMemoryOrFallback.calcDisplayname();
        }
        break;
      case Membership.join:
        final event = getState(EventTypes.RoomMember, client.userID!);
        if (event is Event && event.unsigned?['prev_sender'] != null) {
          final name =
              unsafeGetUserFromMemoryOrFallback(event.unsigned!.tryGet<String>('prev_sender')!)
                  .calcDisplayname();
          return i18n.wasDirectChatDisplayName(name);
        }
        break;
      default: // ignore other Membership states
    }
    return i18n.emptyChat;
  }

  /// Call the Matrix API to change the name of this room.
  /// Returns the event ID of the new room event.
  Future<String> setDisplayName(String value) => client.setRoomStateWithKey(
        id,
        TimRoomStateEventType.roomName.value,
        '',
        {'name': value},
      );

  /// Call the Matrix API to change the topic of this room.
  Future<String> setDisplayTopic(String value) => client.setRoomStateWithKey(
        id,
        TimRoomStateEventType.roomTopic.value,
        '',
        {'topic': value},
      );

  /// Sends an event to this room with this json as a content. Returns the
  /// event ID generated from the server.
  /// It uses list of completer to make sure events are sending in a row.
  Future<String?> sendTextEventWithMentions(
    String message, {
    String? txid,
    Event? inReplyTo,
    String? editEventId,
    bool parseMarkdown = true,
    bool parseCommands = true,
    String msgtype = MessageTypes.Text,
    String? threadRootEventId,
    String? threadLastEventId,
  }) {
    if (parseCommands) {
      return client.parseAndRunCommand(
        this,
        message,
        inReplyTo: inReplyTo,
        editEventId: editEventId,
        txid: txid,
        threadRootEventId: threadRootEventId,
        threadLastEventId: threadLastEventId,
      );
    }
    final event = <String, dynamic>{
      'msgtype': msgtype,
      'body': message,
      'm.mentions': {},
    };

    final Map<String, dynamic> enrichedEvent = parseMarkdown ? enrichEventWithMentions(event) : event;
    return sendEvent(
      enrichedEvent,
      txid: txid,
      inReplyTo: inReplyTo,
      editEventId: editEventId,
      threadRootEventId: threadRootEventId,
      threadLastEventId: threadLastEventId,
    );
  }

  Map<String, dynamic> enrichEventWithMentions(Map<String, dynamic> event) {
    final enrichedEvent = event;
    final mentionsRaw = extractRawMentionsFromEventBody(enrichedEvent['body']);
    final mentionsMxid = extractMentionMxidsFromRawMentionList(mentionsRaw);

    final html = markdown(enrichedEvent['body'],
        getEmotePacks: () => getImagePacksFlat(ImagePackUsage.emoticon), getMention: getMention);
    // if the decoded html is the same as the body, there is no need in sending a formatted message
    if (HtmlUnescape().convert(html.replaceAll(RegExp(r'<br />\n?'), '\n')) !=
        enrichedEvent['body']) {
      enrichedEvent['format'] = 'org.matrix.custom.html';
      enrichedEvent['formatted_body'] = html;
      enrichedEvent['m.mentions'] = mentionsMxid.isEmpty
          ? {}
          : {
              'user_ids': mentionsMxid,
            };
    }

    return enrichedEvent;
  }

  // Return all mentioned users from a message body
  static List<String> extractRawMentionsFromEventBody(String text) {
    // The regular expression matches an '@' followed by one or more word characters.
    final RegExp regex = RegExp(r'@(\w+)');

    final matches = regex.allMatches(text);

    return matches.map((match) => match.group(0)!).toList();
  }

  // Extracts the Mxids for a raw Mentions list
  List<String> extractMentionMxidsFromRawMentionList(List<String> mentionsRaw) =>
      mentionsRaw.map((e) => getMention(e)).whereNotNull().toList();

  /// Sends a [file] to this room after uploading it. Returns the mxc uri of
  /// the uploaded file. If [waitUntilSent] is true, the future will wait until
  /// the message event has received the server. Otherwise the future will only
  /// wait until the file has been uploaded.
  /// Optionally specify [extraContent] to tack on to the event.
  ///
  /// In case [file] is a [MatrixImageFile], [thumbnail] is automatically
  /// computed unless it is explicitly provided.
  /// Set [shrinkImageMaxDimension] to for example `1600` if you want to shrink
  /// your image before sending. This is ignored if the File is not a
  /// [MatrixImageFile].
  Future<String?> sendFileEventWithMessageBody(
    MatrixFile file, {
    String? txid,
    Event? inReplyTo,
    String? editEventId,
    int? shrinkImageMaxDimension,
    MatrixImageFile? thumbnail,
    Map<String, dynamic>? extraContent,
    String? messageBody,
  }) async {
    txid ??= client.generateUniqueTransactionId();
    sendingFilePlaceholders[txid] = file;
    if (thumbnail != null) {
      sendingFileThumbnails[txid] = thumbnail;
    }

    // Create a fake Event object as a placeholder for the uploading file:
    final syncUpdate = SyncUpdate(
      nextBatch: '',
      rooms: RoomsUpdate(
        join: {
          id: JoinedRoomUpdate(
            timeline: TimelineUpdate(
              events: [
                MatrixEvent(
                  content: {
                    'msgtype': file.msgType,
                    'body': messageBody ?? file.name,
                    'filename': file.name,
                  },
                  type: EventTypes.Message,
                  eventId: txid,
                  senderId: client.userID!,
                  originServerTs: DateTime.now(),
                  unsigned: {
                    messageSendingStatusKey: EventStatus.sending.intValue,
                    'transaction_id': txid,
                    ...FileSendRequestCredentials(
                      inReplyTo: inReplyTo?.eventId,
                      editEventId: editEventId,
                      shrinkImageMaxDimension: shrinkImageMaxDimension,
                      extraContent: extraContent,
                    ).toJson(),
                  },
                ),
              ],
            ),
          ),
        },
      ),
    );

    // Check media config of the server before sending the file. Stop if the
    // Media config is unreachable or the file is bigger than the given maxsize.
    try {
      final mediaConfig = await client.getConfig();
      final maxMediaSize = mediaConfig.mUploadSize;
      if (maxMediaSize != null && maxMediaSize < file.bytes.lengthInBytes) {
        throw FileTooBigMatrixException(file.bytes.lengthInBytes, maxMediaSize);
      }
    } catch (e) {
      Logs().d('Config error while sending file', e);
      syncUpdate.rooms!.join!.values.first.timeline!.events!.first
          .unsigned![messageSendingStatusKey] = EventStatus.error.intValue;
      await _handleFakeSync(syncUpdate);
      rethrow;
    }

    MatrixFile uploadFile = file; // ignore: omit_local_variable_types
    // computing the thumbnail in case we can
    if (file is MatrixImageFile && (thumbnail == null || shrinkImageMaxDimension != null)) {
      syncUpdate.rooms!.join!.values.first.timeline!.events!.first.unsigned![fileSendingStatusKey] =
          FileSendingStatus.generatingThumbnail.name;
      await _handleFakeSync(syncUpdate);
      thumbnail ??= await file.generateThumbnail(
        nativeImplementations: client.nativeImplementations,
        customImageResizer: client.customImageResizer,
      );
      if (shrinkImageMaxDimension != null) {
        file = await MatrixImageFile.shrink(
          bytes: file.bytes,
          name: file.name,
          maxDimension: shrinkImageMaxDimension,
          customImageResizer: client.customImageResizer,
          nativeImplementations: client.nativeImplementations,
        );
      }

      if (thumbnail != null && file.size < thumbnail.size) {
        thumbnail = null; // in this case, the thumbnail is not usefull
      }
    }

    MatrixFile? uploadThumbnail = thumbnail; // ignore: omit_local_variable_types
    EncryptedFile? encryptedFile;
    EncryptedFile? encryptedThumbnail;
    if (encrypted && client.fileEncryptionEnabled) {
      syncUpdate.rooms!.join!.values.first.timeline!.events!.first.unsigned![fileSendingStatusKey] =
          FileSendingStatus.encrypting.name;
      await _handleFakeSync(syncUpdate);
      encryptedFile = await file.encrypt();
      uploadFile = encryptedFile.toMatrixFile();

      if (thumbnail != null) {
        encryptedThumbnail = await thumbnail.encrypt();
        uploadThumbnail = encryptedThumbnail.toMatrixFile();
      }
    }
    Uri? uploadResp, thumbnailUploadResp;

    final timeoutDate = DateTime.now().add(client.sendTimelineEventTimeout);

    syncUpdate.rooms!.join!.values.first.timeline!.events!.first.unsigned![fileSendingStatusKey] =
        FileSendingStatus.uploading.name;
    while (uploadResp == null || (uploadThumbnail != null && thumbnailUploadResp == null)) {
      try {
        uploadResp = await client.uploadContent(
          uploadFile.bytes,
          filename: uploadFile.name,
          contentType: uploadFile.mimeType,
        );
        thumbnailUploadResp = uploadThumbnail != null
            ? await client.uploadContent(
                uploadThumbnail.bytes,
                filename: uploadThumbnail.name,
                contentType: uploadThumbnail.mimeType,
              )
            : null;
      } on MatrixException catch (_) {
        syncUpdate.rooms!.join!.values.first.timeline!.events!.first
            .unsigned![messageSendingStatusKey] = EventStatus.error.intValue;
        await _handleFakeSync(syncUpdate);
        rethrow;
      } catch (_) {
        if (DateTime.now().isAfter(timeoutDate)) {
          syncUpdate.rooms!.join!.values.first.timeline!.events!.first
              .unsigned![messageSendingStatusKey] = EventStatus.error.intValue;
          await _handleFakeSync(syncUpdate);
          rethrow;
        }
        Logs().v('Send File into room failed. Try again...');
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // Send event
    final content = <String, dynamic>{
      'msgtype': file.msgType,
      'body': messageBody ?? file.name,
      'filename': file.name,
      if (encryptedFile == null) 'url': uploadResp.toString(),
      if (encryptedFile != null)
        'file': {
          'url': uploadResp.toString(),
          'mimetype': file.mimeType,
          'v': 'v2',
          'key': {
            'alg': 'A256CTR',
            'ext': true,
            'k': encryptedFile.k,
            'key_ops': ['encrypt', 'decrypt'],
            'kty': 'oct'
          },
          'iv': encryptedFile.iv,
          'hashes': {'sha256': encryptedFile.sha256}
        },
      'info': {
        ...file.info,
        if (thumbnail != null && encryptedThumbnail == null)
          'thumbnail_url': thumbnailUploadResp.toString(),
        if (thumbnail != null && encryptedThumbnail != null)
          'thumbnail_file': {
            'url': thumbnailUploadResp.toString(),
            'mimetype': thumbnail.mimeType,
            'v': 'v2',
            'key': {
              'alg': 'A256CTR',
              'ext': true,
              'k': encryptedThumbnail.k,
              'key_ops': ['encrypt', 'decrypt'],
              'kty': 'oct'
            },
            'iv': encryptedThumbnail.iv,
            'hashes': {'sha256': encryptedThumbnail.sha256}
          },
        if (thumbnail != null) 'thumbnail_info': thumbnail.info,
        if (thumbnail?.blurhash != null && file is MatrixImageFile && file.blurhash == null)
          'xyz.amorgan.blurhash': thumbnail!.blurhash
      },
      if (extraContent != null) ...extraContent,
    };
    final eventId = await sendEvent(
      content,
      txid: txid,
      inReplyTo: inReplyTo,
      editEventId: editEventId,
    );
    sendingFilePlaceholders.remove(txid);
    sendingFileThumbnails.remove(txid);
    return eventId;
  }

  Future<void> _handleFakeSync(SyncUpdate syncUpdate, {Direction? direction}) async {
    if (client.database != null) {
      await client.database?.transaction(() async {
        await client.handleSync(syncUpdate, direction: direction);
      });
    } else {
      await client.handleSync(syncUpdate, direction: direction);
    }
  }
}

class FileSendRequestCredentials {
  final String? inReplyTo;
  final String? editEventId;
  final int? shrinkImageMaxDimension;
  final Map<String, dynamic>? extraContent;

  const FileSendRequestCredentials({
    this.inReplyTo,
    this.editEventId,
    this.shrinkImageMaxDimension,
    this.extraContent,
  });

  factory FileSendRequestCredentials.fromJson(Map<String, dynamic> json) =>
      FileSendRequestCredentials(
        inReplyTo: json['in_reply_to'],
        editEventId: json['edit_event_id'],
        shrinkImageMaxDimension: json['shrink_image_max_dimension'],
        extraContent: json['extra_content'],
      );

  Map<String, dynamic> toJson() => {
        if (inReplyTo != null) 'in_reply_to': inReplyTo,
        if (editEventId != null) 'edit_event_id': editEventId,
        if (shrinkImageMaxDimension != null) 'shrink_image_max_dimension': shrinkImageMaxDimension,
        if (extraContent != null) 'extra_content': extraContent,
      };
}
