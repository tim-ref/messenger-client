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

import 'package:fluffychat/tim/feature/tim_version/tim_version_service.dart';
import 'package:fluffychat/tim/shared/tim_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget wrapWithTimVersionServiceProvider({
  required Widget child,
  required TimVersionService timVersionService,
}) =>
    Provider<TimServices>(
      create: (_) => _TimVersionServiceProviderStub(timVersionService),
      child: child,
    );

class _TimVersionServiceProviderStub implements TimServices {
  @override
  TimVersionService timVersionService;

  _TimVersionServiceProviderStub(this.timVersionService);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
