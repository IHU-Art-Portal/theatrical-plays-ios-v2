import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:theatrical_plays/pages/user/EditProfileScreen.dart';
import 'package:theatrical_plays/pages/user/UserImagesSection.dart';
import 'package:theatrical_plays/pages/user/ImageUploadHandler.dart';
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String userRole = "";
  String userEmail = "";
  double userCredits = 0.0;
  String facebookUrl = "";
  String instagramUrl = "";
  String youtubeUrl = "";
  bool is2FAEnabled = false;
  List<Map<String, dynamic>> userImages = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    var data = await UserService.fetchUserProfile();

    if (data != null) {
      setState(() {
        userData = data;
        isLoading = false;
        facebookUrl = data["facebookUrl"] ?? "";
        instagramUrl = data["instagramUrl"] ?? "";
        youtubeUrl = data["youtubeUrl"] ?? "";
        is2FAEnabled = data["twoFactorEnabled"] ?? false;
        userEmail = data["email"] ?? "Δεν υπάρχει email";
        userRole = data["role"] ?? "Χωρίς ρόλο";
        userCredits = data["credits"] ?? 0.0;

        if (data["userImages"] != null && data["userImages"].isNotEmpty) {
          userImages = List<Map<String, dynamic>>.from(
            data["userImages"].map((image) {
              String imageUrl = image["imageLocation"] ?? "";
              String imageId = image["id"]?.toString() ?? "";
              return {
                "url": imageUrl,
                "label": image["label"] ?? "",
                "id": imageId,
                "isProfile": (image["id"]?.toString() ?? "") ==
                    (data["profilePhoto"]?["id"]?.toString() ?? ""),
              };
            }),
          );
        } else {
          userImages = [];
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showSnackbarMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget buildProfileScreen() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    Map<String, dynamic>? profileImage = userImages.firstWhere(
      (image) => image['isProfile'] == true,
      orElse: () => <String, dynamic>{},
    );
    if (profileImage.isEmpty) profileImage = null;

    final imageUploadHandler = ImageUploadHandler(
      context: context,
      showSnackbarMessage: showSnackbarMessage,
      onImageUploaded: fetchUserData, // Ταιριάζει με Future<void>
    );

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: profileImage != null
                ? (profileImage['url'].startsWith('http')
                    ? NetworkImage(profileImage['url']) as ImageProvider<Object>
                    : MemoryImage(base64Decode(profileImage['url']))
                        as ImageProvider<Object>)
                : NetworkImage(userData?["profilePictureUrl"] ??
                        "https://www.gravatar.com/avatar/placeholder?d=mp")
                    as ImageProvider<Object>,
          ),
          SizedBox(height: 20),
          Text(
            userData?["email"] ?? "Δεν υπάρχει email",
            style: TextStyle(fontSize: 22, color: colors.primaryText),
          ),
          SizedBox(height: 5),
          Text(
            "Ρόλος: $userRole",
            style: TextStyle(fontSize: 18, color: colors.secondaryText),
          ),
          SizedBox(height: 10),
          Text(
            "Credits: ${userCredits.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 18,
                color: colors.accent,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Divider(color: colors.secondaryText),
          SizedBox(height: 20),
          buildSocialMediaRow(),
          SizedBox(height: 20),
          UserImagesSection(
            userImages: userImages,
            onImageUpdated: fetchUserData, // Ταιριάζει με Future<void>
            showSnackbarMessage: showSnackbarMessage,
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: imageUploadHandler.showUploadOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Ανέβασε Φωτογραφία",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          buildProfileActions(),
        ],
      ),
    );
  }

  Widget buildSocialMediaRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSocialButton("Facebook", facebookUrl, Icons.facebook, Colors.blue),
        SizedBox(width: 20),
        buildSocialButton(
            "Instagram", instagramUrl, Icons.camera_alt, Colors.pink),
        SizedBox(width: 20),
        buildSocialButton(
            "YouTube", youtubeUrl, Icons.play_circle_fill, Colors.red),
      ],
    );
  }

  Widget buildSocialButton(
      String platform, String url, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 30),
          onPressed: url.isNotEmpty
              ? () => openURL(url)
              : () => showAddSocialDialog(context, platform),
        ),
        SizedBox(height: 5),
        Text(
          url.isNotEmpty ? "Προφίλ $platform" : "Δεν έχει προστεθεί",
          style: TextStyle(
              color: url.isNotEmpty ? colors.primaryText : Colors.red,
              fontSize: 12),
        ),
      ],
    );
  }

  void showAddSocialDialog(BuildContext context, String platform) {
    TextEditingController linkController = TextEditingController();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colors.background,
          title: Text("Προσθήκη $platform Προφίλ",
              style: TextStyle(color: colors.accent)),
          content: TextField(
            controller: linkController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: "Εισάγετε το URL",
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.accent)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.accent)),
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
                if (linkController.text.isNotEmpty) {
                  setState(() {
                    if (platform == "Facebook") {
                      facebookUrl = linkController.text;
                    } else if (platform == "Instagram") {
                      instagramUrl = linkController.text;
                    } else if (platform == "YouTube") {
                      youtubeUrl = linkController.text;
                    }
                  });
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: colors.accent),
              child: Text("Αποθήκευση"),
            ),
          ],
        );
      },
    );
  }

  Widget buildProfileActions() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.person, color: colors.accent),
          title: Text("Επεξεργασία Προφίλ",
              style: TextStyle(color: colors.primaryText)),
          onTap: () async {
            final updatedData = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  facebookUrl: facebookUrl,
                  instagramUrl: instagramUrl,
                  youtubeUrl: youtubeUrl,
                  is2FAEnabled: is2FAEnabled,
                ),
              ),
            );
            if (updatedData != null) {
              setState(() {
                facebookUrl = updatedData["facebookUrl"] ?? facebookUrl;
                instagramUrl = updatedData["instagramUrl"] ?? instagramUrl;
                youtubeUrl = updatedData["youtubeUrl"] ?? youtubeUrl;
                is2FAEnabled = updatedData["twoFactorEnabled"] ?? is2FAEnabled;
              });
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.lock, color: colors.accent),
          title: Text("Αλλαγή Κωδικού",
              style: TextStyle(color: colors.primaryText)),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app, color: Colors.red),
          title:
              Text("Αποσύνδεση", style: TextStyle(color: colors.primaryText)),
          onTap: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Scaffold(
      appBar: AppBar(
        title: Text('Προφίλ Χρήστη', style: TextStyle(color: colors.accent)),
        backgroundColor: colors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: colors.background,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: colors.accent))
          : (userData == null)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 50),
                      SizedBox(height: 10),
                      Text(
                        "⚠️ Σφάλμα φόρτωσης προφίλ!",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchUserData,
                        child: Text("Δοκιμή ξανά"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colors.accent),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(child: buildProfileScreen()),
    );
  }
}

void openURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {}
}
