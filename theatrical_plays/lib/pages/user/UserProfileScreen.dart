import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isPhoneVerified = false;
  String userRole = "";
  String phoneNumber = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    var data = await UserService.fetchUserProfile();
    if (mounted) {
      setState(() {
        userData = data;
        isLoading = false;
        isPhoneVerified = data?["phoneVerified"] ?? false;
        userRole = data?["role"] ?? "Χωρίς ρόλο";
        phoneNumber = data?["phoneNumber"] ?? "";
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Προφίλ Χρήστη', style: TextStyle(color: MyColors().cyan)),
        backgroundColor: MyColors().black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColors().cyan),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: MyColors().black,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: MyColors().cyan))
          : userData == null
              ? Center(
                  child: Text(
                    "⚠️ Σφάλμα φόρτωσης προφίλ",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : Padding(
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
                      Text(userData?["email"] ?? "Δεν υπάρχει email",
                          style: TextStyle(fontSize: 22, color: Colors.white)),
                      SizedBox(height: 5),
                      Text("Ρόλος: $userRole",
                          style:
                              TextStyle(fontSize: 18, color: MyColors().gray)),
                      SizedBox(height: 10),

                      /// ✅ Προσθήκη των Credits του χρήστη
                      Text(
                        "Credits: ${userData?["balance"] != null ? "${userData?["balance"].toStringAsFixed(2)}" : "N/A"}",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

                      /// ✅ Αν ΔΕΝ υπάρχει αριθμός τηλεφώνου, δείξε μήνυμα και κουμπί
                      if (phoneNumber.isEmpty)
                        Column(
                          children: [
                            Text(
                              "⚠️ Δεν έχετε καταχωρήσει αριθμό τηλεφώνου!",
                              style:
                                  TextStyle(color: Colors.orange, fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: showPhoneRegistrationDialog,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors().cyan),
                              child: Text("Καταχώρηση Τηλεφώνου"),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),

                      /// ✅ Αν το τηλέφωνο ΔΕΝ είναι επιβεβαιωμένο, δείξε μήνυμα
                      if (phoneNumber.isNotEmpty && !isPhoneVerified)
                        Column(
                          children: [
                            Text(
                              "⚠️ Το τηλέφωνό σας δεν είναι επιβεβαιωμένο!",
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed:
                                  showPhoneVerificationDialog, // ✅ Ανοίγει το popup OTP
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors().cyan),
                              child: Text("Επιβεβαίωση Τηλεφώνου"),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),

                      Divider(color: MyColors().gray),

                      ListTile(
                        leading: Icon(Icons.person, color: MyColors().cyan),
                        title: Text(
                          "Επεξεργασία Προφίλ",
                          style: TextStyle(
                              color:
                                  isPhoneVerified ? Colors.white : Colors.grey),
                        ),
                        onTap: isPhoneVerified
                            ? () {
                                print("✏️ Επεξεργασία προφίλ...");
                                // Άνοιξε την οθόνη επεξεργασίας προφίλ εδώ
                              }
                            : null, // ✅ Αν δεν είναι verified, δεν κάνει τίποτα
                      ),

                      ListTile(
                        leading: Icon(Icons.lock, color: MyColors().cyan),
                        title: Text("Αλλαγή Κωδικού",
                            style: TextStyle(color: Colors.white)),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Icon(Icons.exit_to_app, color: Colors.red),
                        title: Text("Αποσύνδεση",
                            style: TextStyle(color: Colors.white)),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
    );
  }
}
