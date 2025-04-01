import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:theatrical_plays/pages/home/LoadingHomeScreen.dart';
import 'package:theatrical_plays/pages/home/login_signup.dart';
import 'package:theatrical_plays/pages/theaters/LoadingTheaters.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:theatrical_plays/pages/actors/LoadingActors.dart';
import 'package:theatrical_plays/pages/movies/LoadingMovies.dart';
import 'package:theatrical_plays/pages/user/UserProfileScreen.dart';
import 'package:theatrical_plays/using/globals.dart';
import 'package:theatrical_plays/pages/user/PurchaseCreditsScreen.dart';
import 'package:theatrical_plays/pages/user/ClaimsRequestsScreen.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  static _HomeState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeState>();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SnakeShape snakeShape = SnakeShape.indicator;
  int _selectedItemPosition = 0;
  String? userRole;
  bool _isLoading = true;

  List<Widget> get screens {
    List<Widget> baseScreens = [
      LoadingHomeScreen(),
      LoadingActors(),
      LoadingMovies(),
      LoadingTheaters(),
    ];
    if (userRole?.toLowerCase() == 'admin' ||
        userRole?.toLowerCase() == 'claimsmanager') {
      baseScreens.add(ClaimsRequestsScreen());
    }
    return baseScreens;
  }

  final PageController controller = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  void _loadUserRole() async {
    final profile = await UserService.fetchUserProfile();
    print("🧠 Detected role: ${profile?['role']}");
    setState(() {
      userRole = profile?['role'];
      _isLoading = false; // Τέλος φόρτωσης
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          "Theatrical Analytics",
          style: TextStyle(color: colors.accent),
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
                } else if (value == "claims") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClaimsRequestsScreen()),
                  );
                }
              },
              color: colors.background,
              itemBuilder: (BuildContext context) {
                final List<PopupMenuEntry<String>> items = [
                  PopupMenuItem(
                    value: "credits",
                    child: Row(
                      children: [
                        Icon(Icons.euro, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        FutureBuilder<Map<String, dynamic>?>(
                          future: UserService.fetchUserProfile(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text("...",
                                  style: TextStyle(color: colors.primaryText));
                            }
                            double credits = snapshot.data?['credits'] ?? 0.0;
                            return Text(
                              "Credits: ${credits.toStringAsFixed(2)} €",
                              style: TextStyle(
                                  color: colors.primaryText, fontSize: 16),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "profile",
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.blue),
                      title: Text("Προφίλ",
                          style: TextStyle(color: colors.primaryText)),
                    ),
                  ),
                ];

                if (userRole?.toLowerCase().replaceAll(' ', '') == 'admin' ||
                    userRole?.toLowerCase().replaceAll(' ', '') ==
                        'claimsmanager') {
                  items.add(
                    PopupMenuItem(
                      value: "claims",
                      child: ListTile(
                        leading: Icon(Icons.assignment_turned_in_outlined,
                            color: Colors.green),
                        title: Text("Claim Requests",
                            style: TextStyle(color: colors.primaryText)),
                      ),
                    ),
                  );
                }

                items.add(
                  PopupMenuItem(
                    value: "logout",
                    child: ListTile(
                      leading: Icon(Icons.exit_to_app, color: Colors.red),
                      title: Text("Αποσύνδεση",
                          style: TextStyle(color: colors.primaryText)),
                    ),
                  ),
                );

                return items;
              },
              child: FutureBuilder<Map<String, dynamic>?>(
                future: UserService.fetchUserProfile(),
                builder: (context, snapshot) {
                  String? profileImageUrl;
                  if (snapshot.hasData) {
                    List<dynamic> userImages =
                        snapshot.data?['userImages'] ?? [];
                    Map<String, dynamic>? profileImage = userImages.firstWhere(
                      (image) => image['isProfile'] == true,
                      orElse: () => null,
                    );
                    profileImageUrl = profileImage != null
                        ? profileImage['url']
                        : snapshot.data?['profilePhoto']?['imageLocation'];
                  }
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: profileImageUrl != null &&
                            profileImageUrl.isNotEmpty
                        ? (profileImageUrl.startsWith('http')
                            ? NetworkImage(profileImageUrl)
                            : MemoryImage(base64Decode(profileImageUrl))
                                as ImageProvider)
                        : NetworkImage(
                            "https://www.gravatar.com/avatar/placeholder?d=mp"),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SnakeNavigationBar.color(
        height: 60,
        backgroundColor: colors.background,
        snakeShape: snakeShape,
        snakeViewColor: colors.accent,
        selectedItemColor:
            snakeShape == SnakeShape.indicator ? colors.accent : null,
        unselectedItemColor: colors.iconColor,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        currentIndex: _selectedItemPosition,
        onTap: (index) {
          setState(() {
            _selectedItemPosition = index;
            controller.jumpToPage(index);
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Actors'),
          BottomNavigationBarItem(
              icon: Icon(Icons.movie_outlined), label: 'Movies'),
          BottomNavigationBarItem(
              icon: Icon(Icons.theaters_outlined), label: 'Theaters'),
          if (userRole?.toLowerCase() == 'admin' ||
              userRole?.toLowerCase() == 'claimsmanager')
            BottomNavigationBarItem(
                icon: Icon(Icons.assignment_turned_in_outlined),
                label: 'Claims'),
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
          title: Text(
              "\u0391\u03c0\u03bf\u03c3\u03cd\u03bd\u03b4\u03b5\u03c3\u03b7"),
          content: Text(
              "\u0395\u03af\u03c3\u03c4\u03b5 \u03c3\u03af\u03b3\u03bf\u03c5\u03c1\u03bf\u03c2 \u03cc\u03c4\u03b9 \u03b8\u03ad\u03bb\u03b5\u03c4\u03b5 \u03bd\u03b1 \u03b1\u03c0\u03bf\u03c3\u03c5\u03bd\u03b4\u03b5\u03b8\u03b5\u03af\u03c4\u03b5;"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("\u0391\u03ba\u03cd\u03c1\u03c9\u03c3\u03b7"),
            ),
            TextButton(
              onPressed: () {
                logout();
              },
              child: Text(
                  "\u0391\u03c0\u03bf\u03c3\u03cd\u03bd\u03b4\u03b5\u03c3\u03b7",
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void logout() {
    globalAccessToken = null;
    AuthorizationStore.deleteAllValuesFromStore();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginSignupScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
