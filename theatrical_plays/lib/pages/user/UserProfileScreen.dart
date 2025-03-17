import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:theatrical_plays/pages/user/EditProfileScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _image;
  String _uploadedImageUrl = "";
  // int? userId;
  List<Map<String, dynamic>> userImages =
      []; // Λίστα για τις φωτογραφίες του χρήστη

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    print("📤 Fetching user profile...");

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

        // Έλεγχος και σωστή αποθήκευση των φωτογραφιών του χρήστη
        if (data["userImages"] != null && data["userImages"].isNotEmpty) {
          userImages = List<Map<String, dynamic>>.from(
            data["userImages"].map((image) {
              return {
                "url": image["imageLocation"] ?? "",
                "label": image["label"] ?? "",
                "isProfile":
                    image["id"] == data["profilePhoto"]?["id"] ?? false,
              };
            }),
          );
        } else {
          userImages = []; // Αν δεν υπάρχουν εικόνες, η λίστα παραμένει άδεια
        }
      });

      print("✅ User Data updated successfully: $userData");
      print("User Images: $userImages");
    } else {
      setState(() {
        isLoading = false;
      });
      print("❌ Failed to load user data!");
    }
  }

  Widget buildProfileScreen() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _image == null
                ? NetworkImage(userData?["profilePictureUrl"] ??
                    "https://www.gravatar.com/avatar/placeholder?d=mp")
                : FileImage(_image!) as ImageProvider,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                _pickImage, // Καλούμε την μέθοδο για να επιλέξουμε φωτογραφία
            child: Text('Ανέβασε Φωτογραφία'),
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
            "Credits: ${userCredits.toStringAsFixed(2)}", // Χρήση της μεταβλητής που φορτώσαμε από το API
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
          // Ενότητα για τις φωτογραφίες του χρήστη
          buildUserImagesSection(colors),
          buildProfileActions(),
        ],
      ),
    );
  }

  Widget buildUserImagesSection(MyColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Φωτογραφίες Χρήστη",
          style: TextStyle(fontSize: 18, color: colors.primaryText),
        ),
        SizedBox(height: 10),
        if (userImages.isNotEmpty)
          for (var image in userImages)
            Column(
              children: [
                image['isProfile']
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            _image = File(image['url']);
                          });
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(image['url']),
                        ),
                      )
                    : Image.network(image['url']),
                SizedBox(height: 5),
                Text(image['label']),
                SizedBox(height: 20),
              ],
            )
        else
          Center(child: Text("Δεν υπάρχουν φωτογραφίες")),
      ],
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
              : () => showSnackbarMessage("Δεν έχεις προσθέσει $platform!"),
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

            // ✅ Αν υπάρχουν αλλαγές, ενημερώνουμε τα δεδομένα
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
                        onPressed: fetchUserData, // ✅ Δοκιμή ξανά
                        child: Text("Δοκιμή ξανά"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colors.accent),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  // Προσθήκη SingleChildScrollView
                  child: buildProfileScreen(),
                ),
    );
  }

  void showAddSocialDialog(String platform) {
    TextEditingController linkController = TextEditingController();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              onPressed: () => Navigator.pop(context),
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
                  Navigator.pop(context);
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

  void openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("❌ Δεν μπόρεσε να ανοίξει το link: $url");
    }
  }

  void showSnackbarMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Μέθοδος για την επιλογή εικόνας
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Ανέβασε την εικόνα
      String uploadedUrl = await UserService.uploadUserPhoto(_image!);

      if (uploadedUrl.isNotEmpty) {
        setState(() {
          _uploadedImageUrl =
              uploadedUrl; // Αποθηκεύουμε το URL της εικόνας που ανέβηκε
        });
        print("✅ Η εικόνα ανέβηκε επιτυχώς στο $uploadedUrl");
      } else {
        print("❌ Σφάλμα στο ανέβασμα εικόνας");
      }
    } else {
      print('Δεν επιλέχθηκε καμία εικόνα');
    }
  }

  Widget buildPhotoGallerySection(MyColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Φωτογραφίες Προφίλ",
          style: TextStyle(fontSize: 18, color: colors.primaryText),
        ),
        SizedBox(height: 10),
        // Προεπισκόπηση φωτογραφιών
        _image == null
            ? Center(child: Text("Δεν έχουν προστεθεί φωτογραφίες"))
            : Image.file(_image!), // Εμφανίζει την τοπική εικόνα που επιλέχθηκε

        SizedBox(height: 10),
        // Κουμπί για ανέβασμα φωτογραφίας
        ElevatedButton(
          onPressed: _pickImage, // Επιλογή εικόνας
          child: Text("Ανέβασμα Νέας Φωτογραφίας"),
          style: ElevatedButton.styleFrom(backgroundColor: colors.accent),
        ),
      ],
    );
  }
}
