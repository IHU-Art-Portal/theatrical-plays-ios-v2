import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theatrical_plays/main.dart';

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
  bool isDarkMode = false;
  // String phoneNumber = ""; // ✅ Κρατάει τον αριθμό τηλεφώνου του χρήστη
  bool phoneVerified = false; // ✅ Δείχνει αν το τηλέφωνο είναι verified
  double balance = 0.0; // ✅ Διατηρούμε το υπόλοιπο του χρήστη
  String phoneNumber = "";
  final TextEditingController phoneController = TextEditingController();

  Future<void> loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode =
          prefs.getBool("themeMode") ?? false; // 🔹 Default: Light Mode
    });
  }

  Future<void> toggleTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = value;
    });
    await prefs.setBool("themeMode", value); // ✅ Αποθήκευση επιλογής
  }

  @override
  void initState() {
    super.initState();
    is2FAEnabled = widget.is2FAEnabled; // ✅ Φόρτωση αρχικής τιμής
    loadThemePreference(); // 🔹 Φόρτωση προτίμησης theme κατά την εκκίνηση
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
        phoneController.text = profileData["phoneNumber"] ??
            ""; // ✅ Αντίστοιχη ανάθεση για το phoneController
        phoneVerified =
            profileData["phoneVerified"] ?? false; // ✅ Φόρτωση από το API
        balance = profileData["credits"] ?? 0.0;

        // ✅ Ανάθεση σωστής τιμής στο phoneNumber με ISO code
        phoneNumber = profileData["phoneNumber"] ?? "";
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
    final theme = Theme.of(context);
    final colors =
        theme.brightness == Brightness.dark ? MyColors.dark : MyColors.light;

    return Scaffold(
      appBar: AppBar(
        title:
            Text("Επεξεργασία Προφίλ", style: TextStyle(color: colors.accent)),
        backgroundColor: colors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: colors.background,
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
              style: ElevatedButton.styleFrom(backgroundColor: colors.accent),
              child: Text("Αποθήκευση", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white54),

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Two-Step Security",
                  style: TextStyle(color: colors.primaryText, fontSize: 16),
                ),
                CupertinoSwitch(
                  value: is2FAEnabled,
                  activeColor: Colors.green,
                  onChanged: (bool value) {
                    setState(() {
                      is2FAEnabled = value;
                    });

                    if (value) {
                      enable2FA();
                    } else {
                      disable2FA();
                    }
                  },
                ),
              ],
            ),

            SizedBox(height: 10),

            // ✅ Διορθωμένο Dark Mode Switch
            FutureBuilder<bool>(
              future: getThemePreference(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                bool isDarkMode = snapshot.data ?? false;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dark Mode",
                      style: TextStyle(color: colors.primaryText, fontSize: 16),
                    ),
                    CupertinoSwitch(
                      value: isDarkMode,
                      activeColor: Colors.green,
                      onChanged: (bool value) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool("themeMode", value);

                        // ✅ Ανανέωση της εφαρμογής
                        MyApp.of(context)?.setThemeMode(value);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Αν το social δεν έχει URL, δείχνει `"Δεν έχει προστεθεί"`
  Widget buildSocialField(String label, TextEditingController controller,
      bool isEditing, VoidCallback onEditToggle) {
    String existingUrl =
        controller.text.trim(); // ✅ Διαβάζουμε το URL από το controller
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Row(
      children: [
        Expanded(
          child: isEditing
              ? TextField(
                  controller: controller,
                  style: TextStyle(color: colors.primaryText),
                  decoration: InputDecoration(
                    labelText: "$label URL",
                    labelStyle: TextStyle(color: colors.accent),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors.accent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors.accent),
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
                      style: TextStyle(color: colors.primaryText, fontSize: 16),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.edit, color: colors.accent),
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            phoneController.text.isEmpty
                ? "Προσθήκη τηλεφώνου"
                : "Επεξεργασία τηλεφώνου",
            style: TextStyle(
                color: colors.primaryText), // ✅ Κείμενο τίτλου σε μαύρο
          ),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(
                color: Colors.black), // ✅ Το κείμενο του input είναι μαύρο
            decoration: InputDecoration(
              labelText: "Αριθμός τηλεφώνου",
              labelStyle:
                  TextStyle(color: colors.primaryText), // ✅ Label σε μαύρο
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.accent),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.accent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ακύρωση",
                  style: TextStyle(
                      color: colors.primaryText)), // ✅ Μαύρο κείμενο στο κουμπί
            ),
            ElevatedButton(
              onPressed: () async {
                String formattedPhone = phoneController.text.trim();

                if (formattedPhone.isNotEmpty) {
                  bool success =
                      await UserService.registerPhoneNumber(formattedPhone);
                  if (success) {
                    setState(() {
                      phoneNumber = formattedPhone;
                      phoneController.text = formattedPhone; // ✅ UI ενημέρωση
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
                  Navigator.pop(context);
                }
              },
              child: Text("Αποθήκευση",
                  style: TextStyle(color: colors.primaryText)),
            ),
          ],
        );
      },
    );
  }

  void promptForPhoneVerification() {
    if (balance < 10) {
      // Έλεγχος αν υπάρχουν αρκετά credits
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Δεν έχετε αρκετά credits για την επιβεβαίωση!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Επιβεβαίωση Χρέωσης"),
          content: Text(
              "Αυτή η ενέργεια θα αφαιρέσει 10 credits από το υπόλοιπό σας. Θέλετε να συνεχίσετε;"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ακύρωση"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                print("📤 Κλήση API: request-verification-phone-number...");

                bool success = await UserService.requestPhoneVerification();

                if (success) {
                  print("✅ Το API κάλεστηκε επιτυχώς και ο κωδικός στάλθηκε!");
                  showOtpPrompt();
                } else {
                  print("❌ Αποτυχία αποστολής OTP μέσω API!");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("❌ Αποτυχία αποστολής OTP!"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text("Ναι, συνέχισε"),
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
        phoneController.text = ""; // ✅ Καθαρίζουμε το UI
        phoneNumber = ""; // ✅ Μηδενίζουμε το αντικείμενο PhoneNumber
        phoneVerified = false; // ✅ Μηδενίζουμε το phoneVerified
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

  void showOtpPrompt() {
    TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Εισαγωγή OTP Κωδικού"),
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
                      balance -= 10; // Αφαίρεση 10 credits
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("✅ Το τηλέφωνο επιβεβαιώθηκε!"),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("❌ Λάθος OTP! Προσπαθήστε ξανά."),
                        backgroundColor: Colors.red,
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
}
