import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:theatrical_plays/pages/home/LoginScreen.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int selectedRole = 1; // Default role

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
                    'Create a new User',
                    style: TextStyle(fontSize: 20, color: MyColors().cyan),
                  )),
              // email Field
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  style: TextStyle(color: MyColors().cyan),
                  controller: emailController,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: MyColors().cyan),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: MyColors().cyan)),
                      labelText: 'E-mail',
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: MyColors().cyan))),
                  cursorColor: MyColors().cyan,
                ),
              ),
              // Password Field
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  style: TextStyle(color: MyColors().cyan),
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: MyColors().cyan),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: MyColors().cyan)),
                      labelText: 'Password',
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: MyColors().cyan))),
                  cursorColor: MyColors().cyan,
                ),
              ),
              // DropDown Menu for Role Selection
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: DropdownButtonFormField<int>(
                  value: selectedRole,
                  dropdownColor: MyColors().black,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyColors().cyan),
                    ),
                    labelText: 'Select Role',
                    labelStyle: TextStyle(color: MyColors().cyan),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(color: MyColors().cyan),
                    ),
                  ),
                  style: TextStyle(color: MyColors().cyan),
                  items: [
                    DropdownMenuItem<int>(
                        value: 1,
                        child: Text("Admin",
                            style: TextStyle(color: MyColors().cyan))),
                    DropdownMenuItem<int>(
                        value: 2,
                        child: Text("User",
                            style: TextStyle(color: MyColors().cyan))),
                    DropdownMenuItem<int>(
                        value: 3,
                        child: Text("Developer",
                            style: TextStyle(color: MyColors().cyan))),
                    DropdownMenuItem<int>(
                        value: 4,
                        child: Text("Claims Manager",
                            style: TextStyle(color: MyColors().cyan))),
                  ],
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedRole = newValue!;
                    });
                  },
                ),
              ),
              // Sign-in Button
              Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                            side: BorderSide(color: MyColors().cyan)),
                        backgroundColor: Colors.black,
                        textStyle: TextStyle(color: MyColors().cyan)),
                    child: Text(
                      'Sign up',
                      style: TextStyle(color: MyColors().cyan),
                    ),
                    onPressed: () {
                      doSignIn(emailController.text, passwordController.text,
                          selectedRole);
                    },
                  )),
              // Already Have an Account
              Row(
                children: <Widget>[
                  Text(
                    'Already have an account?',
                    style: TextStyle(color: MyColors().white),
                  ),
                  TextButton(
                    child: Text(
                      'Log in',
                      style: TextStyle(fontSize: 20, color: MyColors().cyan),
                    ),
                    onPressed: () {
                      Navigator.pop(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              )
            ],
          )),
    );
  }

  doSignIn(email, password, role) async {
    try {
      if (email.toString().isNotEmpty &&
          email != null &&
          password.toString().isNotEmpty &&
          password != null &&
          role != null) {
        Uri uri = Uri.parse("http://${Constants().hostName}/api/user/register");
        final json = jsonEncode(
            {"Email": "$email", "Password": "$password", "Role": role});
        Response response = await post(uri,
            headers: {
              "Accept": "application/json",
              "content-type": "application/json"
            },
            body: json);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Succesfull Sign in"),
            duration: Duration(seconds: 5), // Διάρκεια 5 δευτερόλεπτα
          ));
          Navigator.pop(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        } else {
          print(response.statusCode);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Not valid credentials"),
              duration: Duration(seconds: 5); // Διάρκεια 5 δευτερόλεπτα));
        }
        print("Response body: ${response.body}");
      } else {
        print("Empty Field");
      }
    } on Exception {
      print('error to sign in');
    }
  }
}
