# tim_contact_management_api.api.ContactsApi

## Load the API package
```dart
import 'package:tim_contact_management_api/api.dart';
```

All URIs are relative to *https://localhost/tim-contact-mgmt/v1.0.2*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createContactSetting**](ContactsApi.md#createcontactsetting) | **POST** /contacts | 
[**deleteContactSetting**](ContactsApi.md#deletecontactsetting) | **DELETE** /contacts/{mxid} | 
[**getContact**](ContactsApi.md#getcontact) | **GET** /contacts/{mxid} | 
[**getContacts**](ContactsApi.md#getcontacts) | **GET** /contacts | 
[**updateContactSetting**](ContactsApi.md#updatecontactsetting) | **PUT** /contacts | 


# **createContactSetting**
> Contact createContactSetting(mxid, contact)



Creates the setting for the contact {mxid}.

### Example
```dart
import 'package:tim_contact_management_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerMatrixOpenIdTokenAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ContactsApi();
final mxid = mxid_example; // String | MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
final contact = Contact(); // Contact | 

try {
    final result = api_instance.createContactSetting(mxid, contact);
    print(result);
} catch (e) {
    print('Exception when calling ContactsApi->createContactSetting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mxid** | **String**| MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token. | 
 **contact** | [**Contact**](Contact.md)|  | 

### Return type

[**Contact**](Contact.md)

### Authorization

[bearerMatrixOpenIdTokenAuth](../README.md#bearerMatrixOpenIdTokenAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteContactSetting**
> deleteContactSetting(mxid, mxid2)



Deletes the setting for the contact {mxid}.

### Example
```dart
import 'package:tim_contact_management_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerMatrixOpenIdTokenAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ContactsApi();
final mxid = mxid_example; // String | MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
final mxid2 = mxid_example; // String | ID of the contact (mxid)).

try {
    api_instance.deleteContactSetting(mxid, mxid2);
} catch (e) {
    print('Exception when calling ContactsApi->deleteContactSetting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mxid** | **String**| MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token. | 
 **mxid2** | **String**| ID of the contact (mxid)). | 

### Return type

void (empty response body)

### Authorization

[bearerMatrixOpenIdTokenAuth](../README.md#bearerMatrixOpenIdTokenAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getContact**
> Contact getContact(mxid, mxid2)



Returns the contacts with invite settings.

### Example
```dart
import 'package:tim_contact_management_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerMatrixOpenIdTokenAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ContactsApi();
final mxid = mxid_example; // String | MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
final mxid2 = mxid_example; // String | ID of the contact (mxid)).

try {
    final result = api_instance.getContact(mxid, mxid2);
    print(result);
} catch (e) {
    print('Exception when calling ContactsApi->getContact: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mxid** | **String**| MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token. | 
 **mxid2** | **String**| ID of the contact (mxid)). | 

### Return type

[**Contact**](Contact.md)

### Authorization

[bearerMatrixOpenIdTokenAuth](../README.md#bearerMatrixOpenIdTokenAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getContacts**
> Contacts getContacts(mxid)



Returns the contacts with invite settings.

### Example
```dart
import 'package:tim_contact_management_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerMatrixOpenIdTokenAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ContactsApi();
final mxid = mxid_example; // String | MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.

try {
    final result = api_instance.getContacts(mxid);
    print(result);
} catch (e) {
    print('Exception when calling ContactsApi->getContacts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mxid** | **String**| MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token. | 

### Return type

[**Contacts**](Contacts.md)

### Authorization

[bearerMatrixOpenIdTokenAuth](../README.md#bearerMatrixOpenIdTokenAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateContactSetting**
> Contact updateContactSetting(mxid, contact)



Updates the setting for the contact {mxid}.

### Example
```dart
import 'package:tim_contact_management_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearerMatrixOpenIdTokenAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerMatrixOpenIdTokenAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ContactsApi();
final mxid = mxid_example; // String | MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token.
final contact = Contact(); // Contact | 

try {
    final result = api_instance.updateContactSetting(mxid, contact);
    print(result);
} catch (e) {
    print('Exception when calling ContactsApi->updateContactSetting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mxid** | **String**| MXID of the contact settings owner. MUST match with the MXID resolved from the Matrix-OpenID-Token. | 
 **contact** | [**Contact**](Contact.md)|  | 

### Return type

[**Contact**](Contact.md)

### Authorization

[bearerMatrixOpenIdTokenAuth](../README.md#bearerMatrixOpenIdTokenAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

