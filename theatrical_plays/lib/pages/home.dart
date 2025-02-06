import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:theatrical_plays/pages/home/LoadingHomeScreen.dart';
import 'package:theatrical_plays/pages/home/login_signup.dart';

import 'package:theatrical_plays/pages/theaters/LoadingTheaters.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/MyColors.dart';

import 'actors/LoadingActors.dart';
import 'movies/LoadingMovies.dart';
import 'user/UserProfileScreen.dart';

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
        title: Text(
          'Theatrical analytics',
          style: TextStyle(color: MyColors().cyan),
        ),
        backgroundColor: MyColors().black,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: <Widget>[
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
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: "profile",
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.blue),
                    title: Text("Προφίλ"),
                  ),
                ),
                PopupMenuItem(
                  value: "logout",
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app, color: Colors.red),
                    title: Text("Αποσύνδεση"),
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[800], // Placeholder background
                backgroundImage: NetworkImage(
                  "https://www.gravatar.com/avatar/placeholder?d=mp", // Φόρτωσε εικόνα χρήστη (προσωρινή)
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
    AuthorizationStore.deleteAllValuesFromStore();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginSignupScreen()),
      (Route<dynamic> route) => false, // Αφαιρεί όλα τα προηγούμενα routes
    );
  }
}
