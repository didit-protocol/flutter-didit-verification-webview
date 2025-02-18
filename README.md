# Welcome to Didit Verification Webview in Flutter (flutter_inappwebview) 🚀

This is an [Flutter](https://flutter.dev) app using [flutter_inappwebview](https://inappwebview.dev/docs/intro)

## Requirements

- [flutter](https://flutter.dev)
- you need to have a [Didit Application](https://docs.didit.me/identity-verification/quick-start#create-your-didit-account)

- didit `client_id` and `client_secret` to create a verification session


> **Note:** For more detailed configuration information, please check the [inappwebview documentation](https://inappwebview.dev/docs/intro#configure-android).


## Android Configuration

On Android, you need to add these permissions in your `AndroidManifest.xml` file to be able to use camera for taking images and videos:

Add internet permission to `android/app/src/main/AndroidManifest.xml`:
   ```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.VIDEO_CAPTURE" />
    <uses-permission android:name="android.permission.AUDIO_CAPTURE" />
   ```

Also, you need to add the following code inside the `<application>` tag of your `AndroidManifest.xml` file:

```xml
<provider
    android:name="com.pichillilorenzo.flutter_inappwebview_android.InAppWebViewFileProvider"
    android:authorities="${applicationId}.flutter_inappwebview_android.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths" />
</provider>
```


## Configure iOS
On iOS, you need to add the following properties in your Info.plist file to be able to use camera for taking images and videos:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take a picture for verification</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone to record a video for verification</string>
```

## Runtime Permissions
In addition to manifest/plist configurations, the app needs to request camera and microphone permissions at runtime using the permission_handler package:

```dart
await Permission.camera.request();      // Request camera permission
await Permission.microphone.request();  // Request microphone permission
```

These runtime permission requests ensure that the app explicitly asks for user consent before accessing the camera and microphone.


## Get started

1. Install dependencies

   ```bash
   flutter pub get
   ```

2. Start the app

   ```bash
    flutter run
   ```
