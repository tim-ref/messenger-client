import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

class MockFirebaseApp extends FirebaseAppPlatform {
  MockFirebaseApp({
    String? name,
    FirebaseOptions? options,
  }) : super(
    name ?? defaultFirebaseAppName,
    options ??
        const FirebaseOptions(
          apiKey: 'testApiKey',
          appId: 'testAppId',
          messagingSenderId: 'testSenderId',
          projectId: 'testProjectId',
        ),
  );
}

class MockFirebasePlatform extends FirebasePlatform {
  MockFirebasePlatform() : super();

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseApp(
      name: name,
      options: const FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      ),
    );
  }

  @override
  List<FirebaseAppPlatform> get apps {
    return [
      MockFirebaseApp(
        name: defaultFirebaseAppName,
        options: const FirebaseOptions(
          apiKey: 'apiKey',
          appId: 'appId',
          messagingSenderId: 'messagingSenderId',
          projectId: 'projectId',
        ),
      ),
    ];
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseApp(name: name, options: options);
  }
}
