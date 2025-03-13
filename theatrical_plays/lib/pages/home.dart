import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:theatrical_plays/pages/home/LoadingHomeScreen.dart';
import 'package:theatrical_plays/pages/home/login_signup.dart';

import 'package:theatrical_plays/pages/theaters/LoadingTheaters.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';

import 'actors/LoadingActors.dart';
import 'movies/LoadingMovies.dart';
import 'user/UserProfileScreen.dart';
import 'package:theatrical_plays/using/globals.dart';
import 'package:theatrical_plays/pages/user/PurchaseCreditsScreen.dart';

class Home extends StatefulWidget {
  static _HomeState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeState>();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Snake bottom nav bar options initialization
  SnakeShape snakeShape = SnakeShape.indicator;
  int _selectedItemPosition = 0;
  double userCredits = 0.0;

  // Bottom nav bar screens
  final List<Widget> screens = [
    LoadingHomeScreen(),
    LoadingActors(),
    LoadingMovies(),
    LoadingTheaters()
  ];

  final PageController controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar options and colors
      appBar: AppBar(
        backgroundColor: MyColors().black,
        elevation: 0,
        title: Text(
          "Theatrical Analytics",
          style: TextStyle(color: MyColors().cyan),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "profile") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProfileScreen()),
                  );
                } else if (value == "logout") {
                  confirmLogout();
                } else if (value == "credits") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PurchaseCreditsScreen()),
                  );
                }
              },
              color: MyColors().black, // ✅ Μαύρο background στο μενού
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: "credits",
                  child: Row(
                    children: [
                      Icon(Icons.euro, color: Colors.yellow, size: 20),
                      SizedBox(width: 8),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: UserService.fetchUserProfile(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Loading...",
                                style: TextStyle(color: Colors.white));
                          } else if (snapshot.hasError ||
                              snapshot.data == null) {
                            return Text("Error",
                                style: TextStyle(color: Colors.red));
                          } else {
                            double credits = snapshot.data?['credits'] ?? 0.0;
                            return Text(
                              "Credits: ${credits.toStringAsFixed(2)} €",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "profile",
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.blue),
                    title:
                        Text("Προφίλ", style: TextStyle(color: Colors.white)),
                  ),
                ),
                PopupMenuItem(
                  value: "logout",
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app, color: Colors.red),
                    title: Text("Αποσύνδεση",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[800],
                backgroundImage: NetworkImage(
                  "https://www.gravatar.com/avatar/placeholder?d=mp",
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom navigation bar size, colors, and snake shape
      bottomNavigationBar: SnakeNavigationBar.color(
        height: 60,
        backgroundColor: MyColors().black,
        snakeShape: snakeShape,
        snakeViewColor: MyColors().cyan,
        selectedItemColor:
            snakeShape == SnakeShape.indicator ? MyColors().cyan : null,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        currentIndex: _selectedItemPosition,
        onTap: (index) {
          setState(() {
            _selectedItemPosition = index;
            controller.jumpToPage(index);
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Actors'),
          BottomNavigationBarItem(
              icon: Icon(Icons.movie_outlined), label: 'Movies'),
          BottomNavigationBarItem(
              icon: Icon(Icons.theaters_outlined), label: 'Theaters')
        ],
        selectedLabelStyle: const TextStyle(fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
      ),
      body: PageView(
        controller: controller,
        children: screens,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index) {
          setState(() {
            _selectedItemPosition = index;
          });
        },
      ),
    );
  }

  void setBottomNav(String page) {
    int? index;
    if (page == 'Actors') {
      index = 1;
    } else if (page == 'Movies') {
      index = 2;
    } else if (page == 'Theaters') {
      index = 3;
    }

    if (index != null) {
      setState(() {
        _selectedItemPosition = index!;
        controller.jumpToPage(index);
      });
    }
  }

  void confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Αποσύνδεση"),
          content: Text("Είστε σίγουρος ότι θέλετε να αποσυνδεθείτε;"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ακύρωση και κλείσιμο διαλόγου
              },
              child: Text("Ακύρωση"),
            ),
            TextButton(
              onPressed: () {
                logout(); // Κλήση της πραγματικής μεθόδου logout
              },
              child: Text("Αποσύνδεση", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void logout() {
    globalAccessToken = null; // Διαγραφή του token
    AuthorizationStore.deleteAllValuesFromStore();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginSignupScreen()),
      (Route<dynamic> route) => false, // Αφαιρεί όλα τα προηγούμενα routes
    );
  }
}
