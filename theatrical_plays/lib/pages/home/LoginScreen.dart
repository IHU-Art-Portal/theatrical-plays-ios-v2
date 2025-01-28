import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:theatrical_plays/pages/Home.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:http/http.dart' as http; // Προσθήκη του http package
import 'dart:convert'; // Προσθήκη του json package για την κωδικοποίηση JSON
import 'SignInScreen.dart';

String? globalAccessToken;

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Theatrical analytics',
          style: TextStyle(color: MyColors().cyan),
        ),
        backgroundColor: MyColors().black,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: MyColors().black,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Text(
                'Log in to your account',
                style: TextStyle(fontSize: 20, color: MyColors().cyan),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                style: TextStyle(color: MyColors().cyan),
                controller: emailController,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: MyColors().cyan),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors().cyan),
                  ),
                  labelText: 'e-mail',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: MyColors().cyan),
                  ),
                ),
                cursorColor: MyColors().cyan,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                style: TextStyle(color: MyColors().cyan),
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: MyColors().cyan),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors().cyan),
                  ),
                  labelText: 'Password',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: MyColors().cyan),
                  ),
                ),
                cursorColor: MyColors().cyan,
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors().gray,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(color: MyColors().cyan),
                  ),
                  textStyle: TextStyle(color: MyColors().cyan),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(color: MyColors().cyan),
                ),
                onPressed: () {
                  doLogin(emailController.text, passwordController.text);
                },
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  'Don\'t have account?',
                  style: TextStyle(color: MyColors().white),
                ),
                TextButton(
                  child: Text(
                    'Sign up',
                    style: TextStyle(fontSize: 20, color: MyColors().cyan),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> doLogin(String email, String password) async {
    try {
      Uri uri = Uri.parse("http://${Constants().hostName}/api/user/login");

      //Δημιουργό το body request
      Map<String, String> loginData = {
        "Email": email,
        "Password": password,
      };

      // Στέλνουμε το αίτημα με POST μέθοδο
      http.Response response = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: json.encode(loginData), // Στέλνουμε τα δεδομένα σε JSON μορφή
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        // Παίρνουμε το access_token
        String? accessToken = responseData['data']?['access_token'];
        if (accessToken != null && accessToken.isNotEmpty) {
          print("Login successful. Access Token: $accessToken");

          // Αποθηκεύουμε το access_token
          await AuthorizationStore.writeToStore('authorization', accessToken);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Wrong credentials",
            textAlign: TextAlign.center,
          ),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Error logging in. Check your internet connection and VPN.",
          textAlign: TextAlign.center,
        ),
      ));
    }
  }
}
