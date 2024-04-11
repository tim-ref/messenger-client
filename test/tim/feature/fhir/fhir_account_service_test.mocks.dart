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

// Mocks generated by Mockito 5.4.2 from annotations
// in fluffychat/test/tim/feature/fhir/fhir_account_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:fluffychat/tim/feature/fhir/dto/entry.dart' as _i7;
import 'package:fluffychat/tim/feature/fhir/dto/resource_type.dart' as _i8;
import 'package:fluffychat/tim/feature/fhir/fhir_repository.dart' as _i6;
import 'package:fluffychat/tim/shared/tim_auth_repository.dart' as _i4;
import 'package:fluffychat/tim/shared/tim_auth_state.dart' as _i9;
import 'package:fluffychat/tim/shared/tim_auth_token.dart' as _i2;
import 'package:http/http.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeTimAuthToken_0 extends _i1.SmartFake implements _i2.TimAuthToken {
  _FakeTimAuthToken_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeResponse_1 extends _i1.SmartFake implements _i3.Response {
  _FakeResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TimAuthRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTimAuthRepository extends _i1.Mock implements _i4.TimAuthRepository {
  MockTimAuthRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.TimAuthToken> getOpenIdToken() => (super.noSuchMethod(
        Invocation.method(
          #getOpenIdToken,
          [],
        ),
        returnValue: _i5.Future<_i2.TimAuthToken>.value(_FakeTimAuthToken_0(
          this,
          Invocation.method(
            #getOpenIdToken,
            [],
          ),
        )),
      ) as _i5.Future<_i2.TimAuthToken>);
  @override
  _i5.Future<_i2.TimAuthToken> getFhirToken() => (super.noSuchMethod(
        Invocation.method(
          #getFhirToken,
          [],
        ),
        returnValue: _i5.Future<_i2.TimAuthToken>.value(_FakeTimAuthToken_0(
          this,
          Invocation.method(
            #getFhirToken,
            [],
          ),
        )),
      ) as _i5.Future<_i2.TimAuthToken>);
  @override
  _i5.Future<_i2.TimAuthToken> getHbaToken() => (super.noSuchMethod(
        Invocation.method(
          #getHbaToken,
          [],
        ),
        returnValue: _i5.Future<_i2.TimAuthToken>.value(_FakeTimAuthToken_0(
          this,
          Invocation.method(
            #getHbaToken,
            [],
          ),
        )),
      ) as _i5.Future<_i2.TimAuthToken>);
  @override
  _i5.Future<_i2.TimAuthToken> getHbaTokenFromUrl(String? url) => (super.noSuchMethod(
        Invocation.method(
          #getHbaTokenFromUrl,
          [url],
        ),
        returnValue: _i5.Future<_i2.TimAuthToken>.value(_FakeTimAuthToken_0(
          this,
          Invocation.method(
            #getHbaTokenFromUrl,
            [url],
          ),
        )),
      ) as _i5.Future<_i2.TimAuthToken>);
  @override
  _i5.Future<_i3.Response> get(
    Uri? uri, {
    required Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [uri],
          {#headers: headers},
        ),
        returnValue: _i5.Future<_i3.Response>.value(_FakeResponse_1(
          this,
          Invocation.method(
            #get,
            [uri],
            {#headers: headers},
          ),
        )),
      ) as _i5.Future<_i3.Response>);
  @override
  _i5.Future<_i3.Response> post(
    Uri? uri, {
    required Map<String, String>? headers,
    String? body,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [uri],
          {
            #headers: headers,
            #body: body,
          },
        ),
        returnValue: _i5.Future<_i3.Response>.value(_FakeResponse_1(
          this,
          Invocation.method(
            #post,
            [uri],
            {
              #headers: headers,
              #body: body,
            },
          ),
        )),
      ) as _i5.Future<_i3.Response>);
  @override
  _i5.Future<_i3.Response> put(
    Uri? uri, {
    required Map<String, String>? headers,
    String? body,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [uri],
          {
            #headers: headers,
            #body: body,
          },
        ),
        returnValue: _i5.Future<_i3.Response>.value(_FakeResponse_1(
          this,
          Invocation.method(
            #put,
            [uri],
            {
              #headers: headers,
              #body: body,
            },
          ),
        )),
      ) as _i5.Future<_i3.Response>);
  @override
  _i5.Future<_i3.Response> delete(
    Uri? uri, {
    required Map<String, String>? headers,
    String? body,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [uri],
          {
            #headers: headers,
            #body: body,
          },
        ),
        returnValue: _i5.Future<_i3.Response>.value(_FakeResponse_1(
          this,
          Invocation.method(
            #delete,
            [uri],
            {
              #headers: headers,
              #body: body,
            },
          ),
        )),
      ) as _i5.Future<_i3.Response>);
}

/// A class which mocks [FhirRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockFhirRepository extends _i1.Mock implements _i6.FhirRepository {
  MockFhirRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<List<_i7.Entry>?> search(
    _i8.ResourceType? resourceType,
    String? query,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #search,
          [
            resourceType,
            query,
          ],
        ),
        returnValue: _i5.Future<List<_i7.Entry>?>.value(),
      ) as _i5.Future<List<_i7.Entry>?>);
  @override
  _i5.Future<Map<String, dynamic>> ownerSearch(
    String? query,
    _i2.TimAuthToken? token,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #ownerSearch,
          [
            query,
            token,
          ],
        ),
        returnValue: _i5.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i5.Future<Map<String, dynamic>>);
  @override
  _i5.Future<Map<String, dynamic>> createResource(
    _i8.ResourceType? resourceType,
    _i2.TimAuthToken? token,
    String? bodyJson,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createResource,
          [
            resourceType,
            token,
            bodyJson,
          ],
        ),
        returnValue: _i5.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i5.Future<Map<String, dynamic>>);
  @override
  _i5.Future<Map<String, dynamic>> updateResource(
    _i8.ResourceType? resourceType,
    String? resourceId,
    _i2.TimAuthToken? token,
    String? bodyJson,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateResource,
          [
            resourceType,
            resourceId,
            token,
            bodyJson,
          ],
        ),
        returnValue: _i5.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i5.Future<Map<String, dynamic>>);
  @override
  _i5.Future<Map<String, dynamic>> deleteResource(
    _i8.ResourceType? resourceType,
    String? resourceId,
    _i2.TimAuthToken? token,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteResource,
          [
            resourceType,
            resourceId,
            token,
          ],
        ),
        returnValue: _i5.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i5.Future<Map<String, dynamic>>);
  @override
  _i5.Future<_i3.Response> get(
    Uri? uri, {
    required Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [uri],
          {#headers: headers},
        ),
        returnValue: _i5.Future<_i3.Response>.value(_FakeResponse_1(
          this,
          Invocation.method(
            #get,
            [uri],
            {#headers: headers},
          ),
        )),
      ) as _i5.Future<_i3.Response>);
  @override
  _i5.Future<_i3.Response> post(
    Uri? uri, {
    required Map<String, String>? headers,
    String? body,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [uri],
          {
            #headers: headers,
            #body: body,
          },
        ),
        returnValue: _i5.Future<_i3.Response>.value(_FakeResponse_1(
          this,
          Invocation.method(
            #post,
            [uri],
            {
              #headers: headers,
              #body: body,
            },
          ),
        )),
      ) as _i5.Future<_i3.Response>);
  @override
  _i5.Future<_i3.Response> put(
    Uri? uri, {
    required Map<String, String>? headers,
    String? body,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [uri],
          {
            #headers: headers,
            #body: body,
          },
        ),
        returnValue: _i5.Future<_i3.Response>.value(_FakeResponse_1(
          this,
          Invocation.method(
            #put,
            [uri],
            {
              #headers: headers,
              #body: body,
            },
          ),
        )),
      ) as _i5.Future<_i3.Response>);
  @override
  _i5.Future<_i3.Response> delete(
    Uri? uri, {
    required Map<String, String>? headers,
    String? body,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [uri],
          {
            #headers: headers,
            #body: body,
          },
        ),
        returnValue: _i5.Future<_i3.Response>.value(_FakeResponse_1(
          this,
          Invocation.method(
            #delete,
            [uri],
            {
              #headers: headers,
              #body: body,
            },
          ),
        )),
      ) as _i5.Future<_i3.Response>);
}

/// A class which mocks [TimAuthState].
///
/// See the documentation for Mockito's code generation for more information.
class MockTimAuthState extends _i1.Mock implements _i9.TimAuthState {
  MockTimAuthState() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set hbaToken(_i2.TimAuthToken? _hbaToken) => super.noSuchMethod(
        Invocation.setter(
          #hbaToken,
          _hbaToken,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool hbaTokenValid() => (super.noSuchMethod(
        Invocation.method(
          #hbaTokenValid,
          [],
        ),
        returnValue: false,
      ) as bool);
  @override
  void disposeHbaToken() => super.noSuchMethod(
        Invocation.method(
          #disposeHbaToken,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
