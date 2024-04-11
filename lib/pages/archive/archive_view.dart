/*
 * Modified by akquinet GmbH on 10.04.2024
 * Originally forked from https://github.com/krille-chan/fluffychat
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/pages/archive/archive.dart';
import 'package:fluffychat/pages/chat_list/chat_list_item.dart';

import '../../tim/tim_constants.dart';

class ArchiveView extends StatelessWidget {
  final ArchiveController controller;

  const ArchiveView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var archive = controller.archive;
    return FutureBuilder<List<Room>>(
      future: controller.getArchive(context),
      builder: (BuildContext context, snapshot) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(L10n.of(context)!.archive),
          actions: [
            // always show clear archive button when test driver is enabled
            if ((const bool.fromEnvironment(enableTestDriver)) ||
                (snapshot.data?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  key: const ValueKey("clearArchiveButton"),
                  onPressed: controller.forgetAllAction,
                  label: Text(L10n.of(context)!.clearArchive),
                  icon: const Icon(Icons.cleaning_services_outlined),
                ),
              ),
          ],
        ),
        body: Builder(
          builder: (BuildContext context) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  L10n.of(context)!.oopsSomethingWentWrong,
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              );
            } else {
              archive = snapshot.data;
              if (archive == null || archive!.isEmpty) {
                return const Center(
                  child: Icon(Icons.archive_outlined, size: 80),
                );
              }
              return ListView.builder(
                itemCount: archive!.length,
                itemBuilder: (BuildContext context, int i) => ChatListItem(
                  archive![i],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
