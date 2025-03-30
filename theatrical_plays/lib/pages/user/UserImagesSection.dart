import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:theatrical_plays/pages/user/ImageViewerScreen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:convert';

class UserImagesSection extends StatelessWidget {
  final List<Map<String, dynamic>> userImages;
  final Future<void> Function() onImageUpdated; // Ενημερωμένη υπογραφή

  const UserImagesSection({
    Key? key,
    required this.userImages,
    required this.onImageUpdated,
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
                            await onImageUpdated();
                            await AwesomeNotifications().createNotification(
                              content: NotificationContent(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .remainder(100000),
                                channelKey: 'basic_channel',
                                title: 'Επιτυχία!',
                                body: 'Η φωτογραφία ορίστηκε ως προφίλ!',
                                notificationLayout: NotificationLayout.Default,
                              ),
                            );
                          } else {
                            await AwesomeNotifications().createNotification(
                              content: NotificationContent(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .remainder(100000),
                                channelKey: 'basic_channel',
                                title: 'Σφάλμα',
                                body: 'Αποτυχία ορισμού φωτογραφίας προφίλ!',
                                notificationLayout: NotificationLayout.Default,
                                color: Colors.red,
                              ),
                            );
                          }
                        },
                        onDelete: (imageId) async {
                          bool success =
                              await UserService.deleteUserImage(imageId);
                          if (success) {
                            userImages
                                .removeWhere((img) => img['id'] == imageId);
                            await onImageUpdated();
                            await AwesomeNotifications().createNotification(
                              content: NotificationContent(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .remainder(100000),
                                channelKey: 'basic_channel',
                                title: 'Επιτυχία!',
                                body: 'Η εικόνα διαγράφηκε!',
                                notificationLayout: NotificationLayout.Default,
                              ),
                            );
                            return true;
                          } else {
                            await AwesomeNotifications().createNotification(
                              content: NotificationContent(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .remainder(100000),
                                channelKey: 'basic_channel',
                                title: 'Σφάλμα',
                                body: 'Αποτυχία διαγραφής εικόνας!',
                                notificationLayout: NotificationLayout.Default,
                                color: Colors.red,
                              ),
                            );
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
                            await onImageUpdated();
                            await AwesomeNotifications().createNotification(
                              content: NotificationContent(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .remainder(100000),
                                channelKey: 'basic_channel',
                                title: 'Επιτυχία!',
                                body: 'Η φωτογραφία ορίστηκε ως προφίλ!',
                                notificationLayout: NotificationLayout.Default,
                              ),
                            );
                          } else {
                            await AwesomeNotifications().createNotification(
                              content: NotificationContent(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .remainder(100000),
                                channelKey: 'basic_channel',
                                title: 'Σφάλμα',
                                body: 'Αποτυχία ορισμού φωτογραφίας προφίλ!',
                                notificationLayout: NotificationLayout.Default,
                                color: Colors.red,
                              ),
                            );
                          }
                        },
                        onDelete: (imageId) async {
                          bool success =
                              await UserService.deleteUserImage(imageId);
                          if (success) {
                            userImages
                                .removeWhere((img) => img['id'] == imageId);
                            await onImageUpdated();
                            await AwesomeNotifications().createNotification(
                              content: NotificationContent(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .remainder(100000),
                                channelKey: 'basic_channel',
                                title: 'Επιτυχία!',
                                body: 'Η εικόνα διαγράφηκε!',
                                notificationLayout: NotificationLayout.Default,
                              ),
                            );
                            return true;
                          } else {
                            await AwesomeNotifications().createNotification(
                              content: NotificationContent(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .remainder(100000),
                                channelKey: 'basic_channel',
                                title: 'Σφάλμα',
                                body: 'Αποτυχία διαγραφής εικόνας!',
                                notificationLayout: NotificationLayout.Default,
                                color: Colors.red,
                              ),
                            );
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
