/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:tim_contact_management_api/api.dart';
import 'package:vrouter/vrouter.dart';

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/utils/date_time_extension.dart';
import 'package:fluffychat/utils/future_with_retries.dart';
import 'package:fluffychat/utils/localized_exception_extension.dart';
import 'package:fluffychat/tim/shared/provider/tim_provider.dart';
import 'package:fluffychat/widgets/content_banner.dart';
import 'package:fluffychat/widgets/matrix.dart';

class ContactsProfileBottomSheet extends StatefulWidget {
  final String userId;
  final BuildContext outerContext;

  const ContactsProfileBottomSheet({
    required this.userId,
    required this.outerContext,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactsProfileBottomSheetState();
}

class _ContactsProfileBottomSheetState extends State<ContactsProfileBottomSheet> {
  bool _approveContactOnDirectMessage = false;
  bool _isCaseReference = false;

  set isCaseReference(bool value) => setState(() => _isCaseReference = value);

  Future<Profile>? _userProfileFuture;

  Future<Profile> _getUserProfileFuture() => _userProfileFuture ??= runFutureWithRetries(
        () => Matrix.of(context).client.getProfileFromUserId(widget.userId),
      );

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: min(
            MediaQuery.of(context).size.width,
            FluffyThemes.columnWidth * 1.5,
          ),
          child: Material(
            elevation: 4,
            child: SafeArea(
              child: Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                  leading: Semantics(
                    label: "closeContactsProfileBottomSheetButton",
                    container: true,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_downward_outlined),
                      onPressed: Navigator.of(context, rootNavigator: false).pop,
                      tooltip: L10n.of(context)!.close,
                    ),
                  ),
                ),
                body: FutureBuilder<Profile>(
                  future: _getUserProfileFuture(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return _buildProfileLoading();
                      default:
                        if (snapshot.hasData) {
                          return _buildProfileContent(snapshot);
                        } else if (snapshot.hasError) {
                          Logs().e(
                            L10n.of(context)!.timProfileError,
                            snapshot.error,
                            snapshot.stackTrace,
                          );
                          return _buildProfileError();
                        } else {
                          return _buildProfileNotAvailable();
                        }
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildProfileHeader(Profile profile) => ContentBanner(
        mxContent: profile.avatarUrl,
        defaultIcon: Icons.account_circle_outlined,
        client: Matrix.of(context).client,
        placeholder: (context) => Center(
          child: Text(
            widget.userId.localpart ?? widget.userId,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
      );

  Widget _buildProfileMissing(AsyncSnapshot<Profile> snapshot) => Container(
        alignment: Alignment.center,
        color: Theme.of(context).secondaryHeaderColor,
        child: snapshot.hasError
            ? Text(snapshot.error!.toLocalizedString(context))
            : const CircularProgressIndicator.adaptive(strokeWidth: 2),
      );

  Widget _buildProfileContent(AsyncSnapshot<Profile> snapshot) {
    final profile = snapshot.data;
    final isNewContactMode = VRouter.of(context).path == "/newcontact";
    return Column(
      children: [
        Expanded(
          child: profile == null ? _buildProfileMissing(snapshot) : _buildProfileHeader(profile),
        ),
        ListTile(
          title: Text(profile?.displayName ?? widget.userId.localpart ?? ''),
          subtitle: Text(widget.userId),
          trailing: const Icon(Icons.account_box_outlined),
        ),
        if (_isUserFromADifferentHomeserver(widget.userId) && !isNewContactMode)
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Switch(
                  value: _approveContactOnDirectMessage,
                  onChanged: (bool value) {
                    setState(() {
                      _approveContactOnDirectMessage = !_approveContactOnDirectMessage;
                    });
                  },
                ),
              ),
              Text(L10n.of(context)!.timApproveContact),
            ],
          ),
        if (!isNewContactMode)
          SwitchListTile(
            title: Text(L10n.of(context)!.createRoomWithCaseReference),
            value: _isCaseReference,
            onChanged: (value) => isCaseReference = value,
          ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: isNewContactMode
              ? ElevatedButton.icon(
                  key: const ValueKey("approveContactButton"),
                  onPressed: () => _addContactToApprovals(context, profile),
                  label: Text(L10n.of(context)!.timApproveContact),
                  icon: const Icon(Icons.add),
                )
              : ElevatedButton.icon(
                  key: const ValueKey("profileContactNewChatButton"),
                  onPressed: () => _startDirectChat(context, profile),
                  label: Text(L10n.of(context)!.newChat),
                  icon: const Icon(Icons.send_outlined),
                ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProfileLoading() => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildProfileError() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            L10n.of(context)!.timProfileError,
            key: const ValueKey("profileMissingError"),
          ),
        ),
      );

  Widget _buildProfileNotAvailable() => Center(
        child: Text(L10n.of(context)!.timProfileNotAvailable),
      );

  Future<void> _startDirectChat(BuildContext context, Profile? profile) async {
    final client = TimProvider.of(context).matrix().client();
    if (_approveContactOnDirectMessage) {
      try {
        await _addContactToApprovals(context, profile);
      } catch (e, s) {
        Logs().e('Error adding to Approvals', e, s);
        return;
      }
    }
    final result = await showFutureLoadingDialog<String>(
      context: context,
      future: () => client.startDirectChatWithCustomRoomType(
        widget.userId,
        isCaseReference: _isCaseReference,
      ),
    );
    if (result.error == null) {
      VRouter.of(context).toSegments(['rooms', result.result!]);
      Navigator.of(context, rootNavigator: false).pop();
    }
  }

  Future<void> _addContactToApprovals(
    BuildContext context,
    Profile? profile,
  ) async {
    final contact = Contact(
      mxid: profile!.userId,
      displayName: profile.displayName!,
      inviteSettings: ContactInviteSettings(start: DateTime.now().secondsSinceEpoch),
    );
    await showFutureLoadingDialog<Contact?>(
      context: context,
      future: () => TimProvider.of(context).contactsApprovalRepository().addApproval(contact),
      onError: (error) =>
          error is ApiException && error.message != null ? error.message! : error.toString(),
    );
    if (VRouter.of(context).path == '/newcontact') {
      VRouter.of(context).to("/contacts");
    }
  }

  bool _isUserFromADifferentHomeserver(String userId) {
    final client = TimProvider.of(context).matrix().client();
    return client.userID.domain != userId.domain;
  }
}
