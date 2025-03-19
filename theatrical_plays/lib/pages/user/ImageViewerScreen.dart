import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:convert';

class ImageViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> images;
  final int initialIndex;
  final Function(String) onProfileSet;
  final Function(String) onDelete;

  const ImageViewerScreen({
    Key? key,
    required this.images,
    required this.initialIndex,
    required this.onProfileSet,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Όπως στο Facebook, μαύρο φόντο
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () async {
              final imageId = widget.images[_currentIndex]['id'];
              await widget.onProfileSet(imageId);
            },
            tooltip: "Ορισμός ως φωτογραφία προφίλ",
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final imageId = widget.images[_currentIndex]['id'];
              bool success = await widget.onDelete(imageId);
              if (success && widget.images.length == 1) {
                Navigator.pop(
                    context); // Κλείνει αν διαγραφεί η τελευταία εικόνα
              } else if (success) {
                setState(() {
                  if (_currentIndex >= widget.images.length) {
                    _currentIndex = widget.images.length - 1;
                  }
                });
              }
            },
            tooltip: "Διαγραφή φωτογραφίας",
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final image = widget.images[index];
          String imageUrl = image['url'] ?? "";
          bool isBase64Image =
              !imageUrl.startsWith("http") && imageUrl.isNotEmpty;

          return PhotoView(
            imageProvider: isBase64Image
                ? MemoryImage(base64Decode(imageUrl))
                : NetworkImage(imageUrl) as ImageProvider,
            backgroundDecoration: BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(),
            ),
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(Icons.error, color: Colors.red, size: 50),
            ),
          );
        },
      ),
    );
  }
}
