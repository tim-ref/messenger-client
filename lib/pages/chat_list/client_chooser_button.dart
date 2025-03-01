/*
 * Modified by akquinet GmbH on 05.02.2025
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:keyboard_shortcuts/keyboard_shortcuts.dart';
import 'package:logger/logger.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

import '../../tim/shared/tim_services.dart';
import '../../utils/fluffy_share.dart';
import 'chat_list.dart';

class ClientChooserButton extends StatefulWidget {
  final ChatListController controller;

  const ClientChooserButton(this.controller, {Key? key}) : super(key: key);

  @override
  State<ClientChooserButton> createState() => _ClientChooserButtonState();
}

class _ClientChooserButtonState extends State<ClientChooserButton> {
  late final Future<Profile?>? _ownProfileFuture;
  late final Future<bool>? _hideContactManagementFuture;

  @override
  void initState() {
    super.initState();
    final matrix = Matrix.of(context);
    _ownProfileFuture = fetchOwnProfileSafe(matrix);

    final versionService = context.read<TimServices>().timVersionService;
    _hideContactManagementFuture = versionService.versionFeaturesClientSideInviteRejection();
  }

  Future<Profile?> fetchOwnProfileSafe(MatrixState matrix) async {
    try {
      return await matrix.client.fetchOwnProfile();
    } catch (e) {
      Logger().e('Could not fetch own Profile');
      return null;
    }
  }

  List<PopupMenuEntry<Object>> _bundleMenuItems(BuildContext context, bool hideContactManagement) {
    final matrix = Matrix.of(context);
    final bundles = matrix.accountBundles.keys.toList()
      ..sort(
        (a, b) => a!.isValidMatrixId == b!.isValidMatrixId
            ? 0
            : a.isValidMatrixId && !b.isValidMatrixId
                ? -1
                : 1,
      );
    return <PopupMenuEntry<Object>>[
      PopupMenuItem(
        value: SettingsAction.newGroup,
        child: Row(
          children: [
            const Icon(Icons.group_add_outlined),
            const SizedBox(width: 18),
            Text(L10n.of(context)!.createNewGroup),
          ],
        ),
      ),
      PopupMenuItem(
        value: SettingsAction.newSpace,
        child: Row(
          children: [
            const Icon(Icons.workspaces_outlined),
            const SizedBox(width: 18),
            Text(L10n.of(context)!.createNewSpace),
          ],
        ),
      ),
      if (!hideContactManagement)
        PopupMenuItem(
          key: const ValueKey("popupMenuContacts"),
          value: SettingsAction.contacts,
          child: Row(
            children: [
              const Icon(Icons.contacts_outlined),
              const SizedBox(width: 18),
              Text(L10n.of(context)!.timContactApprovals),
            ],
          ),
        ),
      PopupMenuItem(
        value: SettingsAction.invite,
        child: Row(
          children: [
            Icon(Icons.adaptive.share_outlined),
            const SizedBox(width: 18),
            Text(L10n.of(context)!.inviteContact),
          ],
        ),
      ),
      PopupMenuItem(
        key: const ValueKey("popupMenuArchive"),
        value: SettingsAction.archive,
        child: Row(
          children: [
            const Icon(Icons.archive_outlined),
            const SizedBox(width: 18),
            Text(L10n.of(context)!.archive),
          ],
        ),
      ),
      PopupMenuItem(
        key: const ValueKey("popupMenuSettings"),
        value: SettingsAction.settings,
        child: Row(
          children: [
            const Icon(Icons.settings_outlined),
            const SizedBox(width: 18),
            Text(L10n.of(context)!.settings),
          ],
        ),
      ),
      const PopupMenuItem(
        value: null,
        child: Divider(height: 1),
      ),
      for (final bundle in bundles) ...[
        if (matrix.accountBundles[bundle]!.length != 1 ||
            matrix.accountBundles[bundle]!.single!.userID != bundle)
          PopupMenuItem(
            value: null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bundle!,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleMedium!.color,
                    fontSize: 14,
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),
        ...matrix.accountBundles[bundle]!
            .map(
              (client) => PopupMenuItem(
                value: client,
                child: FutureBuilder<Profile?>(
                  // analyzer does not understand this type cast for error
                  // handling
                  //
                  // ignore: unnecessary_cast
                  future: (client!.fetchOwnProfile() as Future<Profile?>).onError((e, s) => null),
                  builder: (context, snapshot) => Row(
                    children: [
                      Avatar(
                        mxContent: snapshot.data?.avatarUrl,
                        name: snapshot.data?.displayName ?? client.userID!.localpart,
                        size: 32,
                        fontSize: 12,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          snapshot.data?.displayName ?? client.userID!.localpart!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => widget.controller.editBundlesForAccount(
                          client.userID,
                          bundle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ],
      PopupMenuItem(
        value: SettingsAction.addAccount,
        child: Row(
          children: [
            const Icon(Icons.person_add_outlined),
            const SizedBox(width: 18),
            Text(L10n.of(context)!.addAccount),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final matrix = Matrix.of(context);

    int clientCount = 0;
    matrix.accountBundles.forEach((key, value) => clientCount += value.length);
    return FutureBuilder<Profile?>(
      future: _ownProfileFuture,
      builder: (context, snapshot) => Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(
            clientCount,
            (index) => KeyBoardShortcuts(
              keysToPress: _buildKeyboardShortcut(index + 1),
              helpLabel: L10n.of(context)!.switchToAccount(index + 1),
              onKeysPressed: () => _handleKeyboardShortcut(
                matrix,
                index,
                context,
              ),
              child: const SizedBox.shrink(),
            ),
          ),
          KeyBoardShortcuts(
            keysToPress: {LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.tab},
            helpLabel: L10n.of(context)!.nextAccount,
            onKeysPressed: () => _nextAccount(matrix, context),
            child: const SizedBox.shrink(),
          ),
          KeyBoardShortcuts(
            keysToPress: {
              LogicalKeyboardKey.controlLeft,
              LogicalKeyboardKey.shiftLeft,
              LogicalKeyboardKey.tab,
            },
            helpLabel: L10n.of(context)!.previousAccount,
            onKeysPressed: () => _previousAccount(matrix, context),
            child: const SizedBox.shrink(),
          ),
          FutureBuilder<bool?>(
            future: _hideContactManagementFuture,
            builder: (context, snapshotContactManagement) {
              return PopupMenuButton<Object>(
                key: const ValueKey("popupMenuButton"),
                onSelected: (o) => _clientSelected(o, context),
                itemBuilder: (_) {
                  if (snapshotContactManagement.hasData && snapshotContactManagement.data == true) {
                    return _bundleMenuItems(context, true);
                  } else {
                    return _bundleMenuItems(context, false);
                  }
                },
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                  child: Avatar(
                    mxContent: snapshot.data?.avatarUrl,
                    name: snapshot.data?.displayName ?? matrix.client.userID!.localpart,
                    size: 28,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Set<LogicalKeyboardKey>? _buildKeyboardShortcut(int index) {
    if (index > 0 && index < 10) {
      return {LogicalKeyboardKey.altLeft, LogicalKeyboardKey(0x00000000030 + index)};
    } else {
      return null;
    }
  }

  void _clientSelected(
    Object object,
    BuildContext context,
  ) async {
    if (object is Client) {
      widget.controller.setActiveClient(object);
    } else if (object is String) {
      widget.controller.setActiveBundle(object);
    } else if (object is SettingsAction) {
      switch (object) {
        case SettingsAction.addAccount:
          final consent = await showOkCancelAlertDialog(
            context: context,
            title: L10n.of(context)!.addAccount,
            message: L10n.of(context)!.enableMultiAccounts,
            okLabel: L10n.of(context)!.next,
            cancelLabel: L10n.of(context)!.cancel,
          );
          if (consent != OkCancelResult.ok) return;
          VRouter.of(context).to('/settings/addaccount');
          break;
        case SettingsAction.newGroup:
          VRouter.of(context).to('/newgroup');
          break;
        case SettingsAction.newSpace:
          VRouter.of(context).to('/newspace');
          break;
        case SettingsAction.contacts:
          VRouter.of(context).to('/contacts');
          break;
        case SettingsAction.invite:
          FluffyShare.share(
            L10n.of(context)!.inviteText(
              Matrix.of(context).client.userID!,
              'https://matrix.to/#/${Matrix.of(context).client.userID}?client=im.fluffychat',
            ),
            context,
          );
          break;
        case SettingsAction.settings:
          VRouter.of(context).to('/settings');
          break;
        case SettingsAction.archive:
          VRouter.of(context).to('/archive');
          break;
      }
    }
  }

  void _handleKeyboardShortcut(
    MatrixState matrix,
    int index,
    BuildContext context,
  ) {
    final bundles = matrix.accountBundles.keys.toList()
      ..sort(
        (a, b) => a!.isValidMatrixId == b!.isValidMatrixId
            ? 0
            : a.isValidMatrixId && !b.isValidMatrixId
                ? -1
                : 1,
      );
    // beginning from end if negative
    if (index < 0) {
      int clientCount = 0;
      matrix.accountBundles.forEach((key, value) => clientCount += value.length);
      _handleKeyboardShortcut(matrix, clientCount, context);
    }
    for (final bundleName in bundles) {
      final bundle = matrix.accountBundles[bundleName];
      if (bundle != null) {
        if (index < bundle.length) {
          return _clientSelected(bundle[index]!, context);
        } else {
          index -= bundle.length;
        }
      }
    }
    // if index too high, restarting from 0
    _handleKeyboardShortcut(matrix, 0, context);
  }

  int? _shortcutIndexOfClient(MatrixState matrix, Client client) {
    int index = 0;

    final bundles = matrix.accountBundles.keys.toList()
      ..sort(
        (a, b) => a!.isValidMatrixId == b!.isValidMatrixId
            ? 0
            : a.isValidMatrixId && !b.isValidMatrixId
                ? -1
                : 1,
      );
    for (final bundleName in bundles) {
      final bundle = matrix.accountBundles[bundleName];
      if (bundle == null) return null;
      if (bundle.contains(client)) {
        return index + bundle.indexOf(client);
      } else {
        index += bundle.length;
      }
    }
    return null;
  }

  void _nextAccount(MatrixState matrix, BuildContext context) {
    final client = matrix.client;
    final lastIndex = _shortcutIndexOfClient(matrix, client);
    _handleKeyboardShortcut(matrix, lastIndex! + 1, context);
  }

  void _previousAccount(MatrixState matrix, BuildContext context) {
    final client = matrix.client;
    final lastIndex = _shortcutIndexOfClient(matrix, client);
    _handleKeyboardShortcut(matrix, lastIndex! - 1, context);
  }
}

enum SettingsAction { addAccount, newGroup, newSpace, contacts, invite, settings, archive }
