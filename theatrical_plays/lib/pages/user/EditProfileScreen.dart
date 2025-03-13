import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';

class EditProfileScreen extends StatefulWidget {
  final String facebookUrl;
  final String instagramUrl;
  final String youtubeUrl;
  final bool is2FAEnabled; // ✅ Δηλώνουμε σωστά το is2FAEnabled

  EditProfileScreen({
    required this.facebookUrl,
    required this.instagramUrl,
    required this.youtubeUrl,
    required this.is2FAEnabled, // ✅ Πρέπει να περνάει από το UserProfileScreen
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
  bool is2FAEnabled = false;
  String phoneNumber = ""; // ✅ Κρατάει τον αριθμό τηλεφώνου του χρήστη
  bool phoneVerified = false; // ✅ Δείχνει αν το τηλέφωνο είναι verified
  double balance = 0.0; // ✅ Διατηρούμε το υπόλοιπο του χρήστη

  @override
  void initState() {
    super.initState();
    is2FAEnabled = widget.is2FAEnabled; // ✅ Φόρτωση αρχικής τιμής
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    var profileData = await UserService.fetchUserProfile();

    if (profileData != null) {
      setState(() {
        facebookController.text = profileData["facebookUrl"] ?? "";
        instagramController.text = profileData["instagramUrl"] ?? "";
        youtubeController.text = profileData["youtubeUrl"] ?? "";
        is2FAEnabled = profileData["twoFactorEnabled"] ?? false;
        phoneNumber = profileData["phoneNumber"] ?? ""; // ✅ Φόρτωση τηλεφώνου
        phoneVerified = profileData["phoneVerified"] ??
            false; // ✅ Έλεγχος επιβεβαίωσης τηλεφώνου
      });
    }
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
      fetchUserProfile(); // 🔹 Φόρτωση των νέων δεδομένων από το API

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Το προφίλ ενημερώθηκε!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, {
        "facebookUrl": facebookController.text,
        "instagramUrl": instagramController.text,
        "youtubeUrl": youtubeController.text,
        "twoFactorEnabled": is2FAEnabled, // ✅ Επιστρέφουμε το 2FA status
      });
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
            buildSocialField("Facebook", facebookController, isEditingFacebook,
                () {
              setState(() => isEditingFacebook = !isEditingFacebook);
            }),
            SizedBox(height: 10),
            buildSocialField(
                "Instagram", instagramController, isEditingInstagram, () {
              setState(() => isEditingInstagram = !isEditingInstagram);
            }),
            SizedBox(height: 10),
            buildSocialField("YouTube", youtubeController, isEditingYouTube,
                () {
              setState(() => isEditingYouTube = !isEditingYouTube);
            }),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(backgroundColor: MyColors().cyan),
              child: Text("Αποθήκευση", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white54), // 🔹 Διαχωριστική γραμμή

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      phoneNumber.isNotEmpty
                          ? Icons.check_circle
                          : Icons.warning,
                      color:
                          phoneNumber.isNotEmpty ? Colors.green : Colors.orange,
                    ),
                    SizedBox(width: 10),
                    Text(
                      phoneNumber.isNotEmpty
                          ? "Τηλέφωνο: $phoneNumber"
                          : "Δεν έχει προστεθεί τηλέφωνο",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: MyColors().cyan),
                      onPressed:
                          promptForPhoneNumber, // ✅ Προσθήκη ή επεξεργασία τηλεφώνου
                    ),
                    if (phoneNumber
                        .isNotEmpty) // ✅ Διαγραφή αν υπάρχει τηλέφωνο
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: handleDeletePhoneNumber,
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 10),
            if (phoneNumber.isNotEmpty && !phoneVerified) ...[
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 10),
                      Text(
                        "Δεν έχει επιβεβαιωθεί",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: promptForPhoneVerification,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: Text("Επιβεβαίωση",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],

            SizedBox(
                height: 10), // ✅ Πρόσθεσε απόσταση πριν το Two-Step Security

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Two-Step Security",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Switch(
                  value: is2FAEnabled, // ✅ Το UI ενημερώνεται σωστά
                  activeColor: Colors.green,
                  onChanged: (bool value) {
                    setState(() {
                      is2FAEnabled =
                          value; // 🔹 Αλλαγή τιμής στο UI πριν καλέσουμε το API
                    });

                    if (value) {
                      enable2FA();
                    } else {
                      disable2FA();
                    }
                  },
                ),
              ],
            ), // ✅ Κλείνουμε το Row σωστά
          ],
        ), // ✅ Κλείνουμε το Column σωστά
      ),
    );
  }

  /// ✅ Αν το social δεν έχει URL, δείχνει `"Δεν έχει προστεθεί"`
  Widget buildSocialField(String label, TextEditingController controller,
      bool isEditing, VoidCallback onEditToggle) {
    String existingUrl =
        controller.text.trim(); // ✅ Διαβάζουμε το URL από το controller

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
                    if (existingUrl
                        .isNotEmpty) // ✅ Δείξε το κουμπί διαγραφής μόνο αν υπάρχει URL
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteSocialMedia(label.toLowerCase()),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  void deleteSocialMedia(String platform) async {
    bool success = await UserService.deleteSocialMedia(platform);

    if (success) {
      fetchUserProfile(); // 🔹 Ξαναφορτώνουμε τα social links από το API

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Το $platform διαγράφηκε!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Αποτυχία διαγραφής του $platform!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void enable2FA() async {
    bool success = await UserService.enable2FA();
    if (success) {
      fetchUserProfile(); // ✅ Ξαναφορτώνουμε τα δεδομένα από το API
    } else {
      setState(() {
        is2FAEnabled = false; // 🔹 Αν αποτύχει, το αφήνουμε απενεργοποιημένο
      });
    }
  }

  void disable2FA() async {
    bool success = await UserService.disable2FA();
    if (success) {
      fetchUserProfile(); // ✅ Ξαναφορτώνουμε τα δεδομένα από το API
    } else {
      setState(() {
        is2FAEnabled = true; // 🔹 Αν αποτύχει, το αφήνουμε ενεργοποιημένο
      });
    }
  }

  void promptForPhoneNumber() {
    TextEditingController phoneController = TextEditingController();
    phoneController.text = phoneNumber; // ✅ Αν υπάρχει τηλέφωνο, το εμφανίζουμε

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(phoneNumber.isEmpty
              ? "Προσθήκη τηλεφώνου"
              : "Επεξεργασία τηλεφώνου"),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: "Αριθμός τηλεφώνου"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ακύρωση"),
            ),
            ElevatedButton(
              onPressed: () async {
                String phone = phoneController.text.trim();
                if (phone.isNotEmpty && phone != phoneNumber) {
                  // ✅ Αλλαγή μόνο αν είναι νέο
                  bool success = await UserService.registerPhoneNumber(phone);
                  if (success) {
                    setState(() {
                      phoneNumber = phone; // ✅ Ενημέρωση UI με το νέο τηλέφωνο
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("✅ Το τηλέφωνο αποθηκεύτηκε!"),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("❌ Αποτυχία αποθήκευσης τηλεφώνου!"),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  Navigator.pop(context); // ✅ Αν δεν αλλάχθηκε, απλά κλείνουμε
                }
              },
              child: Text("Αποθήκευση"),
            ),
          ],
        );
      },
    );
  }

  void promptForPhoneVerification() {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Επιβεβαίωση τηλεφώνου"),
          content: TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Κωδικός OTP"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ακύρωση"),
            ),
            ElevatedButton(
              onPressed: () async {
                String code = codeController.text.trim();
                if (code.isNotEmpty) {
                  bool success =
                      await UserService.confirmPhoneVerification(code);
                  if (success) {
                    setState(() {
                      phoneVerified = true;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("✅ Το τηλέφωνο επιβεβαιώθηκε!"),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: Text("Επιβεβαίωση"),
            ),
          ],
        );
      },
    );
  }

  void handleDeletePhoneNumber() async {
    bool success = await UserService.deletePhoneNumber();

    if (success) {
      setState(() {
        phoneNumber = ""; // ✅ Καθαρίζουμε το UI
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Το τηλέφωνο διαγράφηκε!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Αποτυχία διαγραφής τηλεφώνου!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
