import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class UserProfileScreen extends StatelessWidget {
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  "https://www.gravatar.com/avatar/placeholder?d=mp",
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Όνομα Χρήστη",
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "email@example.com",
              style: TextStyle(fontSize: 16, color: Colors.white70),
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
              title:
                  Text("Αλλαγή Κωδικού", style: TextStyle(color: Colors.white)),
              onTap: () {
                // TODO: Προσθήκη αλλαγής κωδικού
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text("Αποσύνδεση", style: TextStyle(color: Colors.white)),
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
