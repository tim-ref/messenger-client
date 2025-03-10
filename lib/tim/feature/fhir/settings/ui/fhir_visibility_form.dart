/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - 2025 – akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/tim/feature/fhir/settings/ui/disableable_text.dart';
import 'package:fluffychat/tim/feature/fhir/settings/ui/visibility_icon.dart';
import 'package:fluffychat/tim/tim_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

/// A [Switch] with a [Text] label.
///
/// The following arguments are required:
///
/// * [visible] determines whether this switch is on or off.
/// * [onChanged] is called when the user toggles the switch on or off.
class FhirVisibilityForm extends StatefulWidget {
  final bool? visible;
  final void Function(BuildContext, bool)? onChanged;

  const FhirVisibilityForm({
    Key? key,
    required this.visible,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<FhirVisibilityForm> createState() => _FhirVisibilityFormState();
}

class _FhirVisibilityFormState extends State<FhirVisibilityForm> {
  @override
  Widget build(BuildContext context) {
    const bool isDebug = bool.fromEnvironment(enableTestDriver);

    return Stack(
      children: [
        (widget.visible != null)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFhirVisibilityLabel(isVisible: widget.visible!),
                  _buildFhirVisibilitySwitch(isVisible: widget.visible!),
                  if (isDebug) _buildFhirVisibilityDebug(isVisible: widget.visible!),
                ],
              )
            : _buildFhirVisibilityNoData(context),
      ],
    );
  }

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

  Widget _buildFhirVisibilityLabel({required bool isVisible}) => Row(
        children: [
          VisibilityIcon(visibilityOn: isVisible, enabled: widget.onChanged != null),
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: DisableableText(
              L10n.of(context)!.timFhirVisibilityLabel,
              enabled: widget.onChanged != null,
            ),
          ),
        ],
      );

  Widget _buildFhirVisibilitySwitch({required bool isVisible}) => Semantics(
        label: 'toggleFhirVisibilitySwitch',
        enabled: widget.onChanged != null,
        toggled: isVisible,
        child: Switch(
          key: const ValueKey("fhirVisibilityButton"),
          value: isVisible,
          onChanged:
              (widget.onChanged != null) ? (value) => widget.onChanged!(context, value) : null,
        ),
      );

  Widget _buildFhirVisibilityDebug({required bool isVisible}) => Text(
        isVisible ? "visible" : "invisible",
        key: const ValueKey("fhirVisibilityDebugText"),
      );
}
