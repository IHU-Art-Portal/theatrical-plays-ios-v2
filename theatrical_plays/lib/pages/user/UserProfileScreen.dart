import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:theatrical_plays/services/twilio_service.dart';
import 'dart:math';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isPhoneVerified = true; // ✅ Έλεγχος αν το τηλέφωνο είναι επιβεβαιωμένο
  String phoneNumber = ""; // ✅ Τηλέφωνο χρήστη για επιβεβαίωση
  String otpSent = ""; // ✅ Αποθηκεύουμε το OTP για έλεγχο

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    var data = await UserService.fetchUserProfile();
    print("📢 Απάντηση από API: $data");

    if (mounted) {
      setState(() {
        userData = data;
        isLoading = false;
        isPhoneVerified = data?["phoneVerified"] ??
            false; // ✅ Έλεγχος αν έχει επιβεβαιώσει το κινητό
        phoneNumber =
            data?["phoneNumber"] ?? ""; // ✅ Αποθηκεύουμε το τηλέφωνο του χρήστη
      });
    }
  }

  Future<void> sendOtpVerification() async {
    String otp = (100000 + Random().nextInt(900000))
        .toString(); // ✅ Δημιουργία 6ψήφιου OTP
    setState(() {
      otpSent = otp; // ✅ Αποθηκεύουμε το OTP
    });

    bool success = await TwilioService.sendOtp(phoneNumber, otp);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("📲 Ο κωδικός OTP στάλθηκε στο $phoneNumber"),
        backgroundColor: Colors.green,
      ));
      _showOtpDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ Αποτυχία αποστολής OTP."),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showOtpDialog() {
    TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Εισαγωγή OTP"),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Εισαγάγετε το OTP"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (otpController.text == otpSent) {
                  setState(() {
                    isPhoneVerified = true; // ✅ Ενημέρωση κατάστασης
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("✅ Το τηλέφωνο επιβεβαιώθηκε επιτυχώς!"),
                    backgroundColor: Colors.green,
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("❌ Λάθος OTP, δοκιμάστε ξανά."),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text("Επιβεβαίωση"),
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
        title: Text(
          'Προφίλ Χρήστη',
          style: TextStyle(color: MyColors().cyan),
        ),
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
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            userData?["profilePictureUrl"] ??
                                "https://www.gravatar.com/avatar/placeholder?d=mp",
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        userData?["email"] ?? "Δεν υπάρχει email",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Credits: ${userData?["balance"] != null ? "${userData?["balance"].toStringAsFixed(2)}" : "N/A"}",
                        style: TextStyle(
                            fontSize: 18,
                            color: MyColors().cyan,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

                      // ✅ Αν δεν έχει επιβεβαιώσει το τηλέφωνο, εμφανίζουμε ειδοποίηση
                      if (!isPhoneVerified)
                        Column(
                          children: [
                            Text(
                              "⚠️ Το τηλέφωνό σας δεν είναι επιβεβαιωμένο!",
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: sendOtpVerification,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors().cyan),
                              child: Text("Επιβεβαίωση Τηλεφώνου"),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),

                      Divider(color: MyColors().gray),

                      // ✅ Αν το τηλέφωνο δεν είναι επιβεβαιωμένο, απενεργοποιούμε τις επιλογές
                      ListTile(
                        leading: Icon(Icons.person, color: MyColors().cyan),
                        title: Text("Επεξεργασία Προφίλ",
                            style: TextStyle(
                                color: isPhoneVerified
                                    ? Colors.white
                                    : Colors.grey)),
                        onTap: isPhoneVerified
                            ? () {
                                // TODO: Προσθήκη λειτουργίας επεξεργασίας προφίλ
                              }
                            : null,
                      ),
                      ListTile(
                        leading: Icon(Icons.lock, color: MyColors().cyan),
                        title: Text("Αλλαγή Κωδικού",
                            style: TextStyle(color: Colors.white)),
                        onTap: () {
                          // TODO: Προσθήκη αλλαγής κωδικού
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.exit_to_app, color: Colors.red),
                        title: Text("Αποσύνδεση",
                            style: TextStyle(color: Colors.white)),
                        onTap: () {
                          // TODO: Προσθήκη logout
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
