# tim_contact_management_api.api.InfoApi

## Load the API package
```dart
import 'package:tim_contact_management_api/api.dart';
```

All URIs are relative to *https://localhost/tim-contact-mgmt/v1.0.2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getInfo**](InfoApi.md#getinfo) | **GET** / | 


# **getInfo**
> InfoObject getInfo()



Returns the meta data of this interface.

### Example
```dart
import 'package:tim_contact_management_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerMatrixOpenIdTokenAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = InfoApi();

try {
    final result = api_instance.getInfo();
    print(result);
} catch (e) {
    print('Exception when calling InfoApi->getInfo: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**InfoObject**](InfoObject.md)

### Authorization

[bearerMatrixOpenIdTokenAuth](../README.md#bearerMatrixOpenIdTokenAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

