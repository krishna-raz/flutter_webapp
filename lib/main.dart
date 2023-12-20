import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: WebViewWidget(),
        ),
      ),
    );
  }
}

class WebViewWidget extends StatefulWidget {
  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  final String url = 'https://knitkraft.onrender.com/';
  bool isInternetAvailable = true;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  Future<void> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('knitkraft.onrender.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isInternetAvailable = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isInternetAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          _webViewController.goBack();
          return Future.value(false);
        } else {
          // Show the exit confirmation dialog
          final bool exit = await showDialog(
            context: context,
            builder: (context) => ExitConfirmationDialog(),
          );

          return Future.value(exit);
        }
      },
      child: isInternetAvailable
          ? WebView(
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
              gestureNavigationEnabled: false, // Disable full-screen rendering
            )
          : const Center(
              child: Text('No Internet'),
            ),
    );
  }
}

class ExitConfirmationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Exit Confirmation'),
      content: Text('Are you sure you want to exit?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Yes'),
        ),
      ],
    );
  }
}
