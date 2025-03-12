import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:theatrical_plays/pages/user/EditProfileScreen.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isPhoneVerified = false;
  String userRole = "";
  String userEmail = "";
  double userCredits = 0.0;
  String phoneNumber = "";
  String facebookUrl = "";
  String instagramUrl = "";
  String youtubeUrl = "";
  bool is2FAEnabled = false; // ✅ Δημιουργούμε τη μεταβλητή

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

        // ✅ Νέα πεδία
        userEmail = data["email"] ?? "Δεν υπάρχει email";
        userRole = data["role"] ?? "Χωρίς ρόλο";
        userCredits = data["credits"] ?? 0.0;
        phoneNumber = data["phoneNumber"] ?? "";
        isPhoneVerified = data["phoneVerified"] ?? false; // ✅ ΠΡΟΣΘΗΚΗ
      });

      print("✅ User Data updated successfully: $userData");
    } else {
      setState(() {
        isLoading = false;
      });

      print("❌ Failed to load user data!");
    }
  }

  void showPhoneVerificationDialog() {
    TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyColors().black,
          title: Text("Επιβεβαίωση Τηλεφώνου",
              style: TextStyle(color: MyColors().cyan)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Εισαγωγή OTP",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyColors().cyan)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyColors().cyan)),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ακύρωση", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (otpController.text.isEmpty) {
                  print("❌ Παρακαλώ εισάγετε τον κωδικό OTP!");
                  return;
                }

                bool success = await UserService.confirmPhoneVerification(
                    otpController.text);
                if (success) {
                  print("✅ Ο αριθμός τηλεφώνου επιβεβαιώθηκε!");
                  setState(() {
                    isPhoneVerified = true;
                  });
                  fetchUserData(); // Ανανεώνει τα δεδομένα χρήστη
                  Navigator.pop(context);
                } else {
                  print("❌ Αποτυχία επιβεβαίωσης τηλεφώνου!");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: MyColors().cyan),
              child: Text("Επιβεβαίωση"),
            ),
          ],
        );
      },
    );
  }

  /// ✅ Μέθοδος για εισαγωγή αριθμού τηλεφώνου
  void showPhoneRegistrationDialog() {
    TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyColors().black,
          title: Text("Καταχώρηση Τηλεφώνου",
              style: TextStyle(color: MyColors().cyan)),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: "Αριθμός τηλεφώνου",
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyColors().cyan)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyColors().cyan)),
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
                if (phoneController.text.isEmpty) {
                  print("❌ Δεν έχετε εισάγει αριθμό τηλεφώνου!");
                  return;
                }

                bool success =
                    await UserService.registerPhoneNumber(phoneController.text);
                if (success) {
                  print("✅ Ο αριθμός τηλεφώνου καταχωρήθηκε!");
                  fetchUserData(); // Ανανεώνει τα δεδομένα του χρήστη
                  Navigator.pop(context);
                } else {
                  print("❌ Αποτυχία καταχώρησης τηλεφώνου!");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: MyColors().cyan),
              child: Text("Καταχώρηση"),
            ),
          ],
        );
      },
    );
  }

  Widget buildProfileScreen() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              userData?["profilePictureUrl"] ??
                  "https://www.gravatar.com/avatar/placeholder?d=mp",
            ),
          ),
          SizedBox(height: 20),
          Text(
            userData?["email"] ?? "Δεν υπάρχει email",
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(
            "Ρόλος: $userRole",
            style: TextStyle(fontSize: 18, color: MyColors().gray),
          ),
          SizedBox(height: 10),

          /// ✅ Προσθήκη των Credits του χρήστη
          Text(
            "Credits: ${userCredits.toStringAsFixed(2)}", // ✅ Χρήση της μεταβλητής που φορτώσαμε από το API
            style: TextStyle(
                fontSize: 18,
                color: Colors.yellow,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // ✅ Social Media Icons με έλεγχο αν υπάρχει URL
          buildSocialMediaRow(),

          SizedBox(height: 20),

          /// ✅ Αν ΔΕΝ υπάρχει αριθμός τηλεφώνου, δείξε μήνυμα και κουμπί
          if (phoneNumber.isEmpty) buildPhoneRegistration(),

          /// ✅ Αν το τηλέφωνο ΔΕΝ είναι επιβεβαιωμένο, δείξε μήνυμα
          if (phoneNumber.isNotEmpty && !isPhoneVerified)
            buildPhoneVerification(),

          Divider(color: MyColors().gray),

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
              color: url.isNotEmpty ? Colors.white : Colors.red, fontSize: 12),
        ),
      ],
    );
  }

  Widget buildPhoneRegistration() {
    return Column(
      children: [
        Text(
          "⚠️ Δεν έχετε καταχωρήσει αριθμό τηλεφώνου!",
          style: TextStyle(color: Colors.orange, fontSize: 16),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: showPhoneRegistrationDialog,
          style: ElevatedButton.styleFrom(backgroundColor: MyColors().cyan),
          child: Text("Καταχώρηση Τηλεφώνου"),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildPhoneVerification() {
    return Column(
      children: [
        Text(
          "⚠️ Το τηλέφωνό σας δεν είναι επιβεβαιωμένο!",
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: showPhoneVerificationDialog,
          style: ElevatedButton.styleFrom(backgroundColor: MyColors().cyan),
          child: Text("Επιβεβαίωση Τηλεφώνου"),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildProfileActions() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.person, color: MyColors().cyan),
          title:
              Text("Επεξεργασία Προφίλ", style: TextStyle(color: Colors.white)),
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
          leading: Icon(Icons.lock, color: MyColors().cyan),
          title: Text("Αλλαγή Κωδικού", style: TextStyle(color: Colors.white)),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app, color: Colors.red),
          title: Text("Αποσύνδεση", style: TextStyle(color: Colors.white)),
          onTap: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Προφίλ Χρήστη', style: TextStyle(color: MyColors().cyan)),
        backgroundColor: MyColors().black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColors().cyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: MyColors().black,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: MyColors().cyan))
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
                            backgroundColor: MyColors().cyan),
                      ),
                    ],
                  ),
                )
              : buildProfileScreen(),
    );
  }

  void showAddSocialDialog(String platform) {
    TextEditingController linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyColors().black,
          title: Text("Προσθήκη $platform Προφίλ",
              style: TextStyle(color: MyColors().cyan)),
          content: TextField(
            controller: linkController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: "Εισάγετε το URL",
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyColors().cyan)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: MyColors().cyan)),
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
              style: ElevatedButton.styleFrom(backgroundColor: MyColors().cyan),
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
}
