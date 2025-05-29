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

      const String workflowId = "your-workflow-id";
      const String vendorData = "your-vendor-data";
      const String callbackUrl = "https://example.com/verification/callback";

      final sessionData = await createSession(
        workflowId: workflowId,
        vendorData: vendorData,
        callback: callbackUrl,
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

  /// Creates a new verification session using the Didit API.
  /// IMPORTANT: This function should be implemented on your backend/server
  /// to avoid exposing your API key in the client application. This is just
  /// an example implementation - move this logic to your secure backend.
  Future<Map<String, dynamic>> createSession({
    required String workflowId,
    required String vendorData,
    required String callback,
  }) async {
    final Uri sessionUri = Uri.parse(
      "https://verification.didit.me/v2/session/",
    );
    final headers = {
      "Content-Type": "application/json",
      "X-Api-Key": "your-api-key",
    };

    final body = jsonEncode({
      "workflow_id": workflowId,
      "vendor_data": vendorData,
      "callback": callback,
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
