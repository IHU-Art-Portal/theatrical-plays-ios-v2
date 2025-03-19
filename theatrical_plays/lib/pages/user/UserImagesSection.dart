import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:theatrical_plays/pages/user/ImageViewerScreen.dart';
import 'dart:convert';

class UserImagesSection extends StatelessWidget {
  final List<Map<String, dynamic>> userImages;
  final Future<void> Function() onImageUpdated; // Ενημερωμένη υπογραφή
  final Function(BuildContext, String) showSnackbarMessage;

  const UserImagesSection({
    Key? key,
    required this.userImages,
    required this.onImageUpdated,
    required this.showSnackbarMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;
    const int maxVisibleItems = 9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Φωτογραφίες Χρήστη",
          style: TextStyle(fontSize: 18, color: colors.primaryText),
        ),
        SizedBox(height: 10),
        if (userImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: userImages.length > maxVisibleItems
                ? maxVisibleItems
                : userImages.length,
            itemBuilder: (context, index) {
              final image = userImages[index];
              String imageUrl = image['url'] ?? "";
              bool isBase64Image =
                  !imageUrl.startsWith("http") && imageUrl.isNotEmpty;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewerScreen(
                        images: userImages,
                        initialIndex: index,
                        onProfileSet: (imageId) async {
                          bool success =
                              await UserService.updateProfilePhoto(imageId);
                          if (success) {
                            userImages
                                .forEach((img) => img['isProfile'] = false);
                            userImages[index]['isProfile'] = true;
                            await onImageUpdated(); // Σωστή χρήση με await
                            showSnackbarMessage(
                                context, "✅ Η φωτογραφία ορίστηκε ως προφίλ!");
                          } else {
                            showSnackbarMessage(context,
                                "❌ Αποτυχία ορισμού φωτογραφίας προφίλ!");
                          }
                        },
                        onDelete: (imageId) async {
                          bool success =
                              await UserService.deleteUserImage(imageId);
                          if (success) {
                            userImages
                                .removeWhere((img) => img['id'] == imageId);
                            await onImageUpdated(); // Σωστή χρήση με await
                            showSnackbarMessage(
                                context, "✅ Η εικόνα διαγράφηκε!");
                            return true;
                          } else {
                            showSnackbarMessage(
                                context, "❌ Αποτυχία διαγραφής εικόνας!");
                            return false;
                          }
                        },
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isBase64Image
                      ? Image.memory(
                          base64Decode(imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("❌ Failed to load Base64 image: $error");
                            return Icon(Icons.error, color: Colors.red);
                          },
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print("❌ Failed to load image: $imageUrl");
                            return Icon(Icons.error, color: Colors.red);
                          },
                        ),
                ),
              );
            },
          )
        else
          Center(
            child: Text(
              "Δεν υπάρχουν φωτογραφίες",
              style: TextStyle(color: Colors.white),
            ),
          ),
        if (userImages.length > maxVisibleItems)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewerScreen(
                        images: userImages,
                        initialIndex: 0,
                        onProfileSet: (imageId) async {
                          bool success =
                              await UserService.updateProfilePhoto(imageId);
                          if (success) {
                            userImages
                                .forEach((img) => img['isProfile'] = false);
                            userImages.firstWhere((img) => img['id'] == imageId,
                                orElse: () => {})['isProfile'] = true;
                            await onImageUpdated(); // Σωστή χρήση με await
                            showSnackbarMessage(
                                context, "✅ Η φωτογραφία ορίστηκε ως προφίλ!");
                          } else {
                            showSnackbarMessage(context,
                                "❌ Αποτυχία ορισμού φωτογραφίας προφίλ!");
                          }
                        },
                        onDelete: (imageId) async {
                          bool success =
                              await UserService.deleteUserImage(imageId);
                          if (success) {
                            userImages
                                .removeWhere((img) => img['id'] == imageId);
                            await onImageUpdated(); // Σωστή χρήση με await
                            showSnackbarMessage(
                                context, "✅ Η εικόνα διαγράφηκε!");
                            return true;
                          } else {
                            showSnackbarMessage(
                                context, "❌ Αποτυχία διαγραφής εικόνας!");
                            return false;
                          }
                        },
                      ),
                    ),
                  );
                },
                child: Text(
                  "Δες περισσότερες",
                  style: TextStyle(color: colors.accent, fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
