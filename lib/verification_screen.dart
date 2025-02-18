import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  bool _isLoading = true;
  String? sessionUrl;

  InAppWebViewSettings settings = InAppWebViewSettings(
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  @override
  void initState() {
    super.initState();
    _createSessionAndLoad();
  }

  /// Authenticates with the Didit API and then creates a verification session.
  Future<void> _createSessionAndLoad() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final String clientAccessToken = await getClientAccessToken();

      const String features = "OCR + FACE";
      const String callbackUrl = "https://example.com/verification/callback";
      const String vendorData = "your-vendor-data";

      final sessionData = await createSession(
        features: features,
        callback: callbackUrl,
        vendorData: vendorData,
        accessToken: clientAccessToken,
      );

      sessionUrl = sessionData["url"];

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      debugPrint("Error creating session: $error");
      setState(() {
        _isLoading = false;
      });
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  /// Obtains the client access token by authenticating with the Didit API.
  Future<String> getClientAccessToken() async {
    const String clientId = "YOUR_CLIENT_ID";
    const String clientSecret = "YOUR_CLIENT_SECRET";

    // Combine and Base64 encode the credentials.
    final String encodedCredentials = base64Encode(
      utf8.encode('$clientId:$clientSecret'),
    );

    final Uri authUri = Uri.parse('https://apx.didit.me/auth/v2/token/');

    final response = await http.post(
      authUri,
      headers: {
        'Authorization': 'Basic $encodedCredentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      throw Exception(
        'Failed to obtain client access token: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Creates a new verification session using the Didit API.
  Future<Map<String, dynamic>> createSession({
    required String features,
    required String callback,
    required String vendorData,
    required String accessToken,
  }) async {
    final Uri sessionUri = Uri.parse(
      "https://verification.didit.me/v1/session/",
    );
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final body = jsonEncode({
      "callback": callback,
      "features": features,
      "vendor_data": vendorData,
    });

    final response = await http.post(sessionUri, headers: headers, body: body);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to create session: ${response.statusCode} ${response.body}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          if (sessionUrl != null)
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(sessionUrl!)),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onPermissionRequest: (controller, request) async {
                debugPrint('Permission requested: ${request.resources}');
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              onLoadStop: (controller, url) {
                debugPrint('Page loaded: $url');
              },
              onLoadError: (controller, url, code, message) {
                debugPrint('Load error: $code - $message');
              },
            ),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing verification session...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
