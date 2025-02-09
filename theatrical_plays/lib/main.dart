import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:theatrical_plays/pages/home/login_signup.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/globals.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Απαραίτητο για async main
  await dotenv.load(fileName: ".env"); // ✅ Φορτώνει το .env αρχείο
  await dotenv.load(fileName: ".env");
  runApp(MaterialApp(
    home: globalAccessToken == null
        ? LoginSignupScreen()
        : AnimatedSplashScreen(
            splash: Container(
              child: Center(
                child: Column(
                  children: [
                    Text("Theatrical",
                        style: TextStyle(
                          color: MyColors().cyan,
                          fontSize: 30,
                          fontStyle: FontStyle.italic,
                        )),
                    Text(
                      "Plays V2",
                      style: TextStyle(
                        color: MyColors().cyan,
                        fontSize: 30,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  ],
                ),
              ),
            ),
            duration: 3000,
            backgroundColor: MyColors().black,
            splashTransition: SplashTransition.fadeTransition,
            nextScreen: LoginSignupScreen()),
  ));
}
