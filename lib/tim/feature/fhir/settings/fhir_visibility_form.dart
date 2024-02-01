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
import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:fluffychat/tim/tim_constants.dart';

class FhirVisibilityForm extends StatefulWidget {
  final bool hbaAccess;
  final Future<bool> fhirVisible;
  final void Function(BuildContext, bool) onVisibilityChanged;

  const FhirVisibilityForm({
    Key? key,
    required this.hbaAccess,
    required this.fhirVisible,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<FhirVisibilityForm> createState() => _FhirVisibilityFormState();
}

class _FhirVisibilityFormState extends State<FhirVisibilityForm> {
  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: widget.fhirVisible,
        builder: (context, fhirVisibleSnapshot) {
          final bool isDebug = const bool.fromEnvironment(enableTestDriver) &&
              fhirVisibleSnapshot.connectionState != ConnectionState.waiting;

          return Stack(
            children: [
              fhirVisibleSnapshot.hasData
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFhirVisibilityLabel(fhirVisibleSnapshot),
                        _buildFhirVisibilitySwitch(fhirVisibleSnapshot),
                        if (isDebug)
                          _buildFhirVisibilityDebug(fhirVisibleSnapshot),
                      ],
                    )
                  : _buildFhirVisibilityNoData(context),
              if (fhirVisibleSnapshot.connectionState ==
                  ConnectionState.waiting)
                const Opacity(
                  opacity: 0.5,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      );

  Widget _buildFhirVisibilityNoData(BuildContext context) {
    // Workaround to force the visibility button to get unstuck
    Future.delayed(const Duration(seconds: 3), () {
      try {
        (context as Element).reassemble();
      } finally {}
    });

    return const Text(
      'No Visibility Data',
      key: ValueKey("fhirVisibilityNoData"),
    );
  }

  Widget _buildFhirVisibilityLabel(AsyncSnapshot fhirVisibleSnapshot) => Row(
        children: [
          Icon(
            (fhirVisibleSnapshot.data != null &&
                    fhirVisibleSnapshot.data! == true)
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 34,
            color: !widget.hbaAccess ? Theme.of(context).disabledColor : null,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: Text(
              L10n.of(context)!.timFhirVisibilityLabel,
              style: widget.hbaAccess
                  ? Theme.of(context).textTheme.bodyLarge
                  : Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
            ),
          ),
        ],
      );

  Widget _buildFhirVisibilitySwitch(AsyncSnapshot fhirVisibleSnapshot) =>
      Semantics(
        label: 'toggleFhirVisibilitySwitch',
        enabled: widget.hbaAccess,
        toggled: fhirVisibleSnapshot.data ?? false,
        child: Switch(
          key: const ValueKey("fhirVisibilityButton"),
          value: fhirVisibleSnapshot.data ?? false,
          onChanged: widget.hbaAccess
              ? (value) => widget.onVisibilityChanged(context, value)
              : null,
        ),
      );

  Widget _buildFhirVisibilityDebug(AsyncSnapshot fhirVisibleSnapshot) => Text(
        fhirVisibleSnapshot.data! ? "visible" : "invisible",
        key: const ValueKey("fhirVisibilityDebugText"),
      );
}
