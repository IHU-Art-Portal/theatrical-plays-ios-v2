import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  WebViewScreen({required this.url});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Αρχικοποιούμε το WebView και την πλατφόρμα του
    WebViewPlatform.instance;
    _controller = WebViewController();
  }

  bool isUrlValid(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == "http" || uri.scheme == "https");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ολοκλήρωση Πληρωμής")),
      body: SafeArea(
        child: isUrlValid(widget.url)
            ? WebViewWidget(
                controller: _controller..loadRequest(Uri.parse(widget.url)),
              )
            : Center(child: Text("❌ Πρόβλημα με τη φόρτωση της σελίδας.")),
      ),
    );
  }
}
