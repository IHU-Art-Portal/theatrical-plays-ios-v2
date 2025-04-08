import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:flutter/cupertino.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class ImageUploadHandler {
  final picker = ImagePicker();
  final Future<void> Function() onImageUploaded;
  final BuildContext context;

  ImageUploadHandler({
    required this.context,
    required this.onImageUploaded,
  });

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File selectedImage = File(pickedFile.path);
      print("📤 Επιλέχθηκε εικόνα: ${selectedImage.path}");
      _showPreviewDialog(selectedImage, null);
    } else {
      print("❌ Δεν επιλέχθηκε καμία εικόνα");
    }
  }

  void showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.grey[900],
      builder: (BuildContext dialogContext) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.white),
              title: Text("Επιλογή από Βιβλιοθήκη",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(dialogContext);
                pickImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.link, color: Colors.white),
              title: Text("Εισαγωγή μέσω URL",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(dialogContext);
                _showUrlInputDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showUrlInputDialog() {
    TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text("Εισαγωγή URL εικόνας",
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: urlController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: "URL Εικόνας",
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)),
            ),
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Ακύρωση", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                String imageUrl = urlController.text.trim();
                if (imageUrl.isNotEmpty &&
                    (imageUrl.startsWith("http") ||
                        imageUrl.startsWith("https"))) {
                  Navigator.pop(dialogContext);
                  _showPreviewDialog(null, imageUrl);
                } else {
                  await AwesomeNotifications().createNotification(
                    content: NotificationContent(
                      id: DateTime.now()
                          .millisecondsSinceEpoch
                          .remainder(100000),
                      channelKey: 'basic_channel',
                      title: 'Σφάλμα',
                      body: 'Μη έγκυρο URL!',
                      notificationLayout: NotificationLayout.Default,
                      color: Colors.red,
                    ),
                  );
                }
              },
              child: Text("Συνέχεια"),
            ),
          ],
        );
      },
    );
  }

  void _showPreviewDialog(File? imageFile, String? imageUrl) {
    TextEditingController labelController = TextEditingController();
    bool isProfile = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter dialogSetState) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              title: Text("Προεπισκόπηση και Label",
                  style: TextStyle(color: Colors.white)),
              content: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.6,
                  maxWidth: MediaQuery.of(dialogContext).size.width * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          child: imageFile != null
                              ? Image.file(imageFile, fit: BoxFit.cover)
                              : Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                        child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error, color: Colors.red);
                                  },
                                ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: labelController,
                          decoration: InputDecoration(
                            labelText: "Label",
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue)),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Ορισμός ως Φωτογραφία Προφίλ",
                                style: TextStyle(color: Colors.white)),
                            CupertinoSwitch(
                              value: isProfile,
                              onChanged: (value) {
                                dialogSetState(() {
                                  isProfile = value;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text("Ακύρωση", style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String label = labelController.text.trim();
                    if (label.isEmpty) {
                      await AwesomeNotifications().createNotification(
                        content: NotificationContent(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .remainder(100000),
                          channelKey: 'basic_channel',
                          title: 'Σφάλμα',
                          body: 'Παρακαλώ εισάγετε ένα label!',
                          notificationLayout: NotificationLayout.Default,
                          color: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext); // Κλείνουμε το dialog πρώτα

                    // Ανέβασμα της εικόνας
                    bool success = await UserService.uploadUserPhoto(
                      imageFile: imageFile,
                      imageUrl: imageUrl,
                      label: label,
                      isProfile: isProfile,
                    );

                    if (success) {
                      await AwesomeNotifications().createNotification(
                        content: NotificationContent(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .remainder(100000),
                          channelKey: 'basic_channel',
                          title: 'Επιτυχία!',
                          body: 'Η εικόνα προστέθηκε στην βιβλιοθήκη σας!',
                          notificationLayout: NotificationLayout.Default,
                        ),
                      );
                      await onImageUploaded(); // Ενημερώνει τη λίστα userImages
                      if (isProfile) {
                        // Βρίσκουμε το ID της τελευταίας εικόνας μετά το fetch
                        await onImageUploaded(); // Εξασφαλίζει ότι τα δεδομένα είναι ενημερωμένα
                        Map<String, dynamic>? latestImage =
                            await _getLatestImageId();
                        if (latestImage != null && latestImage['id'] != null) {
                          bool profileSuccess =
                              await UserService.updateProfilePhoto(
                                  latestImage['id']);
                          if (profileSuccess) {
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
                        } else {
                          await AwesomeNotifications().createNotification(
                            content: NotificationContent(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .remainder(100000),
                              channelKey: 'basic_channel',
                              title: 'Σφάλμα',
                              body: 'Δεν βρέθηκε ID για την τελευταία εικόνα!',
                              notificationLayout: NotificationLayout.Default,
                              color: Colors.red,
                            ),
                          );
                        }
                      }
                    } else {
                      await AwesomeNotifications().createNotification(
                        content: NotificationContent(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .remainder(100000),
                          channelKey: 'basic_channel',
                          title: 'Σφάλμα',
                          body: 'Αποτυχία αποστολής εικόνας!',
                          notificationLayout: NotificationLayout.Default,
                          color: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text("Ανέβασμα"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Βοηθητική μέθοδος για να πάρουμε το ID της τελευταίας εικόνας
  Future<Map<String, dynamic>?> _getLatestImageId() async {
    Map<String, dynamic>? profileData = await UserService.fetchUserProfile();
    if (profileData != null && profileData['userImages'] != null) {
      List<dynamic> images = profileData['userImages'];
      if (images.isNotEmpty) {
        return images.last as Map<String, dynamic>;
      }
    }
    return null;
  }
}
