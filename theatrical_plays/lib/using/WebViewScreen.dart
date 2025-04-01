import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final void Function(String decision)? onDecision; // 👈 Νέο callback

  WebViewScreen({required this.url, this.onDecision});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(title: Text("Προβολή Αρχείου")),
      body: SafeArea(
        child: isUrlValid(widget.url)
            ? WebViewWidget(
                controller: _controller..loadRequest(Uri.parse(widget.url)),
              )
            : Center(child: Text("❌ Πρόβλημα με τη φόρτωση της σελίδας.")),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onDecision != null) widget.onDecision!("accept");
                Navigator.pop(context);
              },
              icon: Icon(Icons.check),
              label: Text("Αποδοχή"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onDecision != null) widget.onDecision!("reject");
                Navigator.pop(context);
              },
              icon: Icon(Icons.close),
              label: Text("Απόρριψη"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
