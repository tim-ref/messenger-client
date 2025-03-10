# tim_information_api.api.LookUpServerApi

## Load the API package
```dart
import 'package:tim_information_api/api.dart';
```

All URIs are relative to *https://tobereplaced.de/tim-information*

Method | HTTP request | Description
------------- | ------------- | -------------
[**v1ServerFindByIkGet**](LookUpServerApi.md#v1serverfindbyikget) | **GET** /v1/server/findByIk | Resolve an IK number to the associated TI-Messenger server name.
[**v1ServerIsInsuranceGet**](LookUpServerApi.md#v1serverisinsuranceget) | **GET** /v1/server/isInsurance | Check whether a TI-Messenger server name represents an insurance.


# **v1ServerFindByIkGet**
> V1ServerFindByIkGet200Response v1ServerFindByIkGet(ikNumber)

Resolve an IK number to the associated TI-Messenger server name.

### Example
```dart
import 'package:tim_information_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerMatrixOpenIdTokenAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LookUpServerApi();
final ikNumber = ikNumber_example; // String | IK number to look up.

try {
    final result = api_instance.v1ServerFindByIkGet(ikNumber);
    print(result);
} catch (e) {
    print('Exception when calling LookUpServerApi->v1ServerFindByIkGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ikNumber** | **String**| IK number to look up. | 

### Return type

[**V1ServerFindByIkGet200Response**](V1ServerFindByIkGet200Response.md)

### Authorization

[bearerMatrixOpenIdTokenAuth](../README.md#bearerMatrixOpenIdTokenAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **v1ServerIsInsuranceGet**
> V1ServerIsInsuranceGet200Response v1ServerIsInsuranceGet(serverName)

Check whether a TI-Messenger server name represents an insurance.

### Example
```dart
import 'package:tim_information_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerMatrixOpenIdTokenAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = LookUpServerApi();
final serverName = serverName_example; // String | The server name to query.

try {
    final result = api_instance.v1ServerIsInsuranceGet(serverName);
    print(result);
} catch (e) {
    print('Exception when calling LookUpServerApi->v1ServerIsInsuranceGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverName** | **String**| The server name to query. | 

### Return type

[**V1ServerIsInsuranceGet200Response**](V1ServerIsInsuranceGet200Response.md)

### Authorization

[bearerMatrixOpenIdTokenAuth](../README.md#bearerMatrixOpenIdTokenAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

