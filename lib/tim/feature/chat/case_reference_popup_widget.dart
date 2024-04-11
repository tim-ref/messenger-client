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

import 'dart:convert';

import 'package:flutter/material.dart';

class CaseReferencePopupWidget extends StatelessWidget {
  const CaseReferencePopupWidget({super.key, required this.caseReference});

  final Map caseReference;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Case Reference Info",
      container: true,
      child: IconButton(
        icon: const Icon(Icons.attach_file),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Case Reference Info"),
              content: SingleChildScrollView(
                child: Column(
                  children: [Text(const JsonEncoder.withIndent('  ').convert(caseReference))],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
