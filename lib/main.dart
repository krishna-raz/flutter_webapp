import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Website App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController _webViewController;
  DateTime? currentBackPressTime;

  bool hasConnectivityError = false;

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          hasConnectivityError = false;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        hasConnectivityError = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    await _checkConnectivity();

    if (hasConnectivityError) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
          content: Text("Please check your internet connection."),
        ),
      );
      return false;
    }

    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return false; // Do not exit the app
    } else {
      if (currentBackPressTime == null ||
          DateTime.now().difference(currentBackPressTime!) >
              Duration(seconds: 2)) {
        currentBackPressTime = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Press back again to exit the app"),
          ),
        );
        return false; // Do not exit the app
      } else {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Exit'),
            content: Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ?? false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
          child: WebView(
            initialUrl:
                'https://bcepatna.live/KnitKraft/', // Replace with your website URL
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onWebResourceError: (WebResourceError error) {
              if (error.errorCode == 101) {
                // 101 indicates connection error
                setState(() {
                  hasConnectivityError = true;
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
