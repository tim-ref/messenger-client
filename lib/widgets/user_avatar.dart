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

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import 'avatar.dart';

class UserAvatar extends StatefulWidget {
  final User user;
  final GestureTapCallback? onTap;
  final double? size;
  final double? fontSize;

  const UserAvatar({
    required this.user,
    this.onTap,
    this.size,
    this.fontSize,
    super.key,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  late final Future<CachedPresence> _userPresenceFtr;

  @override
  void initState() {
    super.initState();
    _userPresenceFtr = widget.user.fetchCurrentPresence();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<CachedPresence>(
        future: _userPresenceFtr,
        builder: (context, snapshot) {
          final diameter = widget.size ?? Avatar.defaultSize;
          if (snapshot.hasData) {
            final cachedPresence = snapshot.data!;
            return InkWell(
              onTap: widget.onTap,
              child: Stack(
                children: [
                  Avatar(
                    mxContent: widget.user.avatarUrl,
                    name: widget.user.calcDisplayname(),
                    size: diameter,
                    fontSize: widget.fontSize ?? 18,
                  ),
                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: Icon(
                      Icons.circle,
                      color: switch (cachedPresence.presence) {
                        PresenceType.online => Colors.green,
                        PresenceType.unavailable => Colors.yellow,
                        PresenceType.offline => Colors.red,
                      },
                      size: diameter * 0.35,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Avatar(
              mxContent: widget.user.avatarUrl,
              name: widget.user.calcDisplayname(),
              size: diameter,
              onTap: widget.onTap,
              fontSize: widget.fontSize ?? 18,
            );
          }
        },
      );
}
