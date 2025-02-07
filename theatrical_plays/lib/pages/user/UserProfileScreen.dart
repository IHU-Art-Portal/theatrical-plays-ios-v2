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

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    var data = await UserService.fetchUserProfile();
    print("📢 Απάντηση από API: $data"); // ✅ Εκτυπώνουμε τα δεδομένα για έλεγχο
    if (mounted) {
      setState(() {
        userData = data;
        isLoading = false;
      });
    }
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
          ? Center(
              child: CircularProgressIndicator(color: MyColors().cyan),
            )
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

                      // ✅ Προσθήκη Balance (Χωρίς Coin Icon)
                      Text(
                        "Credits: ${userData?["balance"] != null ? "${userData?["balance"].toStringAsFixed(2)}" : "N/A"}",
                        style: TextStyle(
                            fontSize: 18,
                            color: MyColors().cyan,
                            fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: 20),
                      Divider(color: MyColors().gray),
                      ListTile(
                        leading: Icon(Icons.person, color: MyColors().cyan),
                        title: Text("Επεξεργασία Προφίλ",
                            style: TextStyle(color: Colors.white)),
                        onTap: () {
                          // TODO: Προσθήκη λειτουργίας επεξεργασίας προφίλ
                        },
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
