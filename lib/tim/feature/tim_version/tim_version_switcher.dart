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

import 'package:fluffychat/tim/feature/tim_version/tim_version.dart';
import 'package:fluffychat/tim/feature/tim_version/tim_version_service.dart';
import 'package:fluffychat/tim/shared/tim_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:provider/provider.dart';

/// Control widget for automated testing. Supports setting the desired TI-M
/// version.
class TimVersionSwitcher extends StatefulWidget {
  const TimVersionSwitcher({super.key});

  @override
  State<TimVersionSwitcher> createState() => _TimVersionSwitcherState();
}

class _TimVersionSwitcherState extends State<TimVersionSwitcher> {
  late final TimVersionService _service;
  TimVersion? _selectedVersion;

  @override
  void initState() {
    super.initState();
    _service = context.read<TimServices>().timVersionService;
    _loadActiveVersion();
  }

  Future<void> _loadActiveVersion() async {
    final loadedVersion = await _service.get();
    setState(() {
      _selectedVersion = loadedVersion;
    });
  }

  Future<void> setVersion(TimVersion? version) async {
    if (version != null) {
      await _service.set(version);
      setState(() {
        _selectedVersion = version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(L10n.of(context)!.timVersionLabel),
        RadioListTile<TimVersion>(
          title: Text(L10n.of(context)!.timVersionClassic),
          key: const Key("radio button: TI-M version classic"),
          value: TimVersion.classic,
          groupValue: _selectedVersion,
          onChanged: setVersion,
        ),
        RadioListTile<TimVersion>(
          title: Text(L10n.of(context)!.timVersionEpa),
          key: const Key("radio button: TI-M version ePA"),
          value: TimVersion.ePA,
          groupValue: _selectedVersion,
          onChanged: setVersion,
        ),
      ],
    );
  }
}
