import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';

class EditProfileScreen extends StatefulWidget {
  final String facebookUrl;
  final String instagramUrl;
  final String youtubeUrl;

  EditProfileScreen({
    required this.facebookUrl,
    required this.instagramUrl,
    required this.youtubeUrl,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController facebookController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();

  bool isEditingFacebook = false;
  bool isEditingInstagram = false;
  bool isEditingYouTube = false;
  String profilePictureUrl = "";

  @override
  void initState() {
    super.initState();
    facebookController.text = widget.facebookUrl;
    instagramController.text = widget.instagramUrl;
    youtubeController.text = widget.youtubeUrl;
  }

  void saveProfile() async {
    bool success = true;

    if (facebookController.text.isNotEmpty) {
      success = await UserService.updateSocialMedia(
          "facebook", facebookController.text);
    }
    if (instagramController.text.isNotEmpty) {
      success = await UserService.updateSocialMedia(
          "instagram", instagramController.text);
    }
    if (youtubeController.text.isNotEmpty) {
      success = await UserService.updateSocialMedia(
          "youtube", youtubeController.text);
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Το προφίλ ενημερώθηκε!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Αποτυχία ενημέρωσης προφίλ!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Επεξεργασία Προφίλ",
            style: TextStyle(color: MyColors().cyan)),
        backgroundColor: MyColors().black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColors().cyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: MyColors().black,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildSocialField("Facebook", facebookController, widget.facebookUrl,
                isEditingFacebook, () {
              setState(() => isEditingFacebook = !isEditingFacebook);
            }),
            SizedBox(height: 10),
            buildSocialField("Instagram", instagramController,
                widget.instagramUrl, isEditingInstagram, () {
              setState(() => isEditingInstagram = !isEditingInstagram);
            }),
            SizedBox(height: 10),
            buildSocialField("YouTube", youtubeController, widget.youtubeUrl,
                isEditingYouTube, () {
              setState(() => isEditingYouTube = !isEditingYouTube);
            }),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(backgroundColor: MyColors().cyan),
              child: Text("Αποθήκευση", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Αν το social δεν έχει URL, δείχνει `"Δεν έχει προστεθεί"`
  Widget buildSocialField(String label, TextEditingController controller,
      String existingUrl, bool isEditing, VoidCallback onEditToggle) {
    return Row(
      children: [
        Expanded(
          child: isEditing
              ? TextField(
                  controller: controller,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "$label URL",
                    labelStyle: TextStyle(color: MyColors().cyan),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyColors().cyan),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyColors().cyan),
                    ),
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      existingUrl.isNotEmpty
                          ? Icons.check_circle
                          : Icons.warning,
                      color:
                          existingUrl.isNotEmpty ? Colors.green : Colors.orange,
                    ),
                    SizedBox(width: 10),
                    Text(
                      existingUrl.isNotEmpty
                          ? "$label συνδεδεμένο"
                          : "Δεν έχει προστεθεί $label",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.edit, color: MyColors().cyan),
                      onPressed: onEditToggle,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
