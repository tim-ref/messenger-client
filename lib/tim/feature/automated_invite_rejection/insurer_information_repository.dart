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

import 'package:fluffychat/tim/shared/matrix/tim_matrix_client.dart';
import 'package:fluffychat/tim/shared/tim_auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:tim_information_api/api.dart';

import '../../tim_constants.dart';

class InsurerInformationRepository {
  final TimAuthRepository _authRepository;
  LookUpServerApi? _lookUpServerApi;
  final Client? _httpClient;
  final TimMatrixClient _timMatrixClient;
  final Logger _logger = Logger();

  InsurerInformationRepository(this._timMatrixClient, this._authRepository, [this._httpClient]);

  /// Resolve an IK number to the associated TI-Messenger server name.
  /// Used to construct the mxid of users based on KVNR and Ik-Number
  /// https://gemspec.gematik.de/docs/gemSpec/gemSpec_TI-M_Pro/gemSpec_TI-M_Pro_V1.0.1/#3.2.2
  /// Is currently unused in this client
  Future<Either<ApiException, V1ServerFindByIkGet200Response?>> getServerByIk(
    String ikNumber,
  ) async {
    initApiClientIfNeeded();
    try {
      await _setBearerToken();
      final serverName = await _lookUpServerApi!.v1ServerFindByIkGet(ikNumber);
      return Right(serverName);
    } on ApiException catch (exception, stacktrace) {
      _logger.e(
        'Api exception getting server for Ik number',
        error: exception,
        stackTrace: stacktrace,
      );
      return Left(exception);
    } catch (error, stacktrace) {
      _logger.e(
        'Error getting server for Ik number',
        error: error,
        stackTrace: stacktrace,
      );
      return Left(ApiException.withInner(500, error.toString(), null, stacktrace));
    }
  }

  Future<Option<bool?>> doesServerBelongToInsurer(String serverName) async {
    initApiClientIfNeeded();
    try {
      await _setBearerToken();
      final isInsurance = await _lookUpServerApi!.v1ServerIsInsuranceGet(serverName);
      // optionOf wraps non-null values in Some, and returns None if the value is null.
      return optionOf(isInsurance?.isInsurance);
    } catch (error, stacktrace) {
      _logger.e(
        'Error determining whether server is Insurance',
        error: error,
        stackTrace: stacktrace,
      );
      return none();
    }
  }

  /// The initialization of the api client can only happen once a user is logged in. Otherwise the homeserver is null
  void initApiClientIfNeeded() {
    if (_lookUpServerApi == null) {
      _lookUpServerApi = LookUpServerApi(
        ApiClient(
          basePath: 'https://${_timMatrixClient.homeserver.host}$timInformationPath',
          authentication: HttpBearerAuth(),
        ),
      );
      if (_httpClient != null) {
        _lookUpServerApi?.apiClient.client = _httpClient;
      }
    }
  }

  Future<void> _setBearerToken() async {
    final token = await _authRepository.getOpenIdToken();
    final bearerAuth = _lookUpServerApi!.apiClient.authentication as HttpBearerAuth;
    bearerAuth.accessToken = token.accessToken;
  }
}
