import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final cookieManager = WebviewCookieManager();
  late WebViewController webViewController;

  bool _cookiesAreReady = false;

  final String _url = 'https://youtube.com';
  final String cookieValue = 'some-cookie-value';
  final String domain = 'youtube.com';
  final String cookieName = 'some_cookie_name';

  @override
  void initState() {
    super.initState();

    _setCookies();

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            final gotCookies = await cookieManager.getCookies(_url);
            for (var item in gotCookies) {
              print(item);
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(_url),
      );
  }

  Future<void> _setCookies() async {
    await cookieManager.clearCookies();

    await cookieManager.setCookies([
      Cookie(cookieName, cookieValue)
        ..domain = domain
        ..expires = DateTime.now().add(Duration(days: 10))
        ..httpOnly = false
    ]);

    setState(() {
      _cookiesAreReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            IconButton(
              icon: Icon(Icons.ac_unit),
              onPressed: () async {
                // TEST CODE
                await cookieManager.getCookies(null);
              },
            )
          ],
        ),
        body: _cookiesAreReady
            ? WebViewWidget(controller: webViewController)
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
