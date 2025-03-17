import 'package:flutter/material.dart';
import 'package:theatrical_plays/pages/home/login_signup.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 🔹 Διαβάζει την αποθηκευμένη ρύθμιση Light/Dark Mode
  bool isDarkMode = await getThemePreference();

  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  MyApp({required this.isDarkMode});

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void setThemeMode(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = isDark;
    });
    await prefs.setBool("themeMode", isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: MyColors.light.accent,
        scaffoldBackgroundColor: MyColors.light.background,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: MyColors.dark.accent,
        scaffoldBackgroundColor: MyColors.dark.background,
      ),
      home: LoginSignupScreen(),
    );
  }
}

// 🔹 Αποθήκευση προτίμησης χρήστη για Light/Dark Mode
Future<void> setThemePreference(bool isDarkMode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("themeMode", isDarkMode);
}

// 🔹 Φόρτωση της αποθηκευμένης προτίμησης Theme
Future<bool> getThemePreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("themeMode") ?? false;
}
