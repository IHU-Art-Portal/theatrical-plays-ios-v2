import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/pages/Home.dart';
import 'package:theatrical_plays/using/globals.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class LoginSignupScreen extends StatefulWidget {
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

int? selectedRole;

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isSignupScreen = true;
  bool isRememberMe = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    Colors.black87,
                    Colors.black54
                  ] // Σκοτεινό Gradient για Dark Mode
                : [
                    Colors.blue.shade900,
                    Colors.red.shade700
                  ], // Φωτεινό Gradient για Light Mode
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 90),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: RichText(
                    text: TextSpan(
                      text: "Welcome to",
                      style: TextStyle(
                        fontSize: 25,
                        letterSpacing: 2,
                        color: colors.accent,
                      ),
                      children: [
                        TextSpan(
                          text: isSignupScreen ? " Theatrical Plays" : " Back,",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: colors.accent,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    isSignupScreen
                        ? "Signup to Continue"
                        : "Signin to Continue",
                    style: TextStyle(
                        letterSpacing: 1, color: colors.secondaryText),
                  ),
                ),
              ],
            ),

            // Κεντρικό Box για Login/Signup
            Positioned(
              top: 200,
              left: 20,
              right: 20,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 700),
                curve: Curves.bounceInOut,
                height: isSignupScreen ? 275 : 250,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isSignupScreen = false;
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: !isSignupScreen
                                        ? colors.accent
                                        : colors.secondaryText,
                                  ),
                                ),
                                if (!isSignupScreen)
                                  Container(
                                    margin: EdgeInsets.only(top: 3),
                                    height: 2,
                                    width: 55,
                                    color: colors.accent,
                                  )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isSignupScreen = true;
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  "SIGNUP",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSignupScreen
                                        ? colors.accent
                                        : colors.secondaryText,
                                  ),
                                ),
                                if (isSignupScreen)
                                  Container(
                                    margin: EdgeInsets.only(top: 3),
                                    height: 2,
                                    width: 55,
                                    color: colors.accent,
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                      if (isSignupScreen) buildSignupSection(),
                      if (!isSignupScreen) buildSigninSection()
                    ],
                  ),
                ),
              ),
            ),

            // ✅ Επαναφορά του κουμπιού με το βέλος
            buildBottomHalfContainer(false),
          ],
        ),
      ),
    );
  }

  Container buildSigninSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              prefixIcon: Icon(MaterialCommunityIcons.email_outline,
                  color: colors.iconColor),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.secondaryText),
                borderRadius: BorderRadius.all(Radius.circular(35.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.accent),
                borderRadius: BorderRadius.all(Radius.circular(35.0)),
              ),
              contentPadding: EdgeInsets.all(10),
              hintText: "Email",
              hintStyle: TextStyle(fontSize: 14, color: colors.secondaryText),
            ),
            style: TextStyle(color: colors.primaryText),
          ),
          SizedBox(height: 10),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              prefixIcon: Icon(MaterialCommunityIcons.lock_outline,
                  color: colors.iconColor),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.secondaryText),
                borderRadius: BorderRadius.all(Radius.circular(35.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.accent),
                borderRadius: BorderRadius.all(Radius.circular(35.0)),
              ),
              contentPadding: EdgeInsets.all(10),
              hintText: "Password",
              hintStyle: TextStyle(fontSize: 14, color: colors.secondaryText),
            ),
            style: TextStyle(color: colors.primaryText),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isRememberMe,
                    activeColor: colors.accent,
                    onChanged: (value) {
                      setState(() {
                        isRememberMe = !isRememberMe;
                      });
                    },
                  ),
                  Text("Remember me",
                      style:
                          TextStyle(fontSize: 12, color: colors.secondaryText))
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text("Forgot Password?",
                    style: TextStyle(fontSize: 12, color: colors.accent)),
              )
            ],
          )
        ],
      ),
    );
  }

  Container buildSignupSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              prefixIcon: Icon(MaterialCommunityIcons.email_outline,
                  color: colors.iconColor),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.secondaryText),
                borderRadius: BorderRadius.all(Radius.circular(35.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.secondaryText),
                borderRadius: BorderRadius.all(Radius.circular(35.0)),
              ),
              contentPadding: EdgeInsets.all(10),
              hintText: "Email",
              hintStyle: TextStyle(fontSize: 14, color: colors.secondaryText),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              prefixIcon: Icon(MaterialCommunityIcons.lock_outline,
                  color: colors.iconColor),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.secondaryText),
                borderRadius: BorderRadius.all(Radius.circular(35.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.secondaryText),
                borderRadius: BorderRadius.all(Radius.circular(35.0)),
              ),
              contentPadding: EdgeInsets.all(10),
              hintText: "Password",
              hintStyle: TextStyle(fontSize: 14, color: colors.secondaryText),
            ),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: selectedRole,
            dropdownColor: colors.background,
            decoration: InputDecoration(
              prefixIcon: Icon(MaterialCommunityIcons.account_outline,
                  color: colors.iconColor),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.secondaryText),
                borderRadius: BorderRadius.all(Radius.circular(35.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.secondaryText),
                borderRadius: BorderRadius.all(Radius.circular(35.0)),
              ),
              contentPadding: EdgeInsets.all(10),
              labelText: 'Select Role',
              labelStyle: TextStyle(fontSize: 14, color: colors.secondaryText),
            ),
            style: TextStyle(color: colors.secondaryText),
            items: [
              DropdownMenuItem<int>(
                  value: 1,
                  child: Text("Admin",
                      style: TextStyle(color: colors.secondaryText))),
              DropdownMenuItem<int>(
                  value: 2,
                  child: Text("User",
                      style: TextStyle(color: colors.secondaryText))),
              DropdownMenuItem<int>(
                  value: 3,
                  child: Text("Developer",
                      style: TextStyle(color: colors.secondaryText))),
              DropdownMenuItem<int>(
                  value: 4,
                  child: Text("Claims Manager",
                      style: TextStyle(color: colors.secondaryText))),
            ],
            onChanged: (int? newValue) {
              setState(() {
                selectedRole = newValue!;
              });
            },
          ),
          SizedBox(height: 10),
          // ElevatedButton(
          //   onPressed: () {

          //     doSignUp(
          //         emailController.text, passwordController.text, selectedRole);
          //   },
          //   child: Text("Sign Up"),
          // ),
        ],
      ),
    );
  }

  TextButton buildTextButton(
      IconData icon, String title, Color backgroundColor) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(width: 1, color: Colors.grey),
          minimumSize: Size(145, 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: backgroundColor),
      child: Row(
        children: [
          Icon(
            icon,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            title,
          )
        ],
      ),
    );
  }

  Widget buildBottomHalfContainer(bool showShadow) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 700),
      curve: Curves.bounceInOut,
      top: isSignupScreen ? 435 : 405,
      right: 0,
      left: 0,
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (isSignupScreen) {
              doSignUp(
                  emailController.text, passwordController.text, selectedRole);
            } else {
              doLogin(
                  emailController.text.trim(), passwordController.text.trim());
            }
          },
          child: Container(
            height: 90,
            width: 90,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                if (showShadow)
                  BoxShadow(
                    color: Colors.black.withOpacity(.3),
                    spreadRadius: 1.5,
                    blurRadius: 10,
                  )
              ],
            ),
            child: !showShadow
                ? Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.blue[200]!, Colors.red[400]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(.3),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1))
                        ]),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  )
                : Center(),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(IconData icon, String hintText, bool isPassword,
      bool isEmail, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: colors.iconColor,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.secondaryText),
            borderRadius: BorderRadius.all(Radius.circular(35.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.secondaryText),
            borderRadius: BorderRadius.all(Radius.circular(35.0)),
          ),
          contentPadding: EdgeInsets.all(10),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: colors.secondaryText),
        ),
      ),
    );
  }

  doSignUp(String email, String password, int? role) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty && role != null) {
        Uri uri = Uri.parse("http://${Constants().hostName}/api/user/register");
        final json =
            jsonEncode({"Email": email, "Password": password, "Role": role});
        http.Response response = await http.post(uri,
            headers: {
              "Accept": "application/json",
              "content-type": "application/json"
            },
            body: json);
        if (response.statusCode == 200) {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: 10,
              channelKey: 'basic_channel',
              title: '🔔 Successful Sign Up!',
              body: 'Redirecting to Login...',
              notificationLayout: NotificationLayout.Default,
            ),
          );

          // Μετά από 2 δευτερόλεπτα, πηγαίνει στο login screen
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              isSignupScreen =
                  false; // Αλλάζουμε την κατάσταση για να εμφανιστεί το login
            });
          });
        } else {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: 10,
              channelKey: 'basic_channel',
              title: '⛔️ Λάθος στοιχεία',
              body: 'Παρακαλώ προσπαθήστε ξανά',
              notificationLayout: NotificationLayout.Default,
            ),
          );
        }
      } else {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: '⚠️ Όλα τα πεδία είναι απαραίτητα',
            body: 'Παρακαλώ προσπαθήστε ξανά',
            notificationLayout: NotificationLayout.Default,
          ),
        );
      }
    } catch (e) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          title: '⛔️ Πρόβλημα εγγραφής',
          body: 'Παρακαλώ προσπαθήστε ξανά',
          notificationLayout: NotificationLayout.Default,
        ),
      );
    }
  }

  void showAwesomeNotification(String body,
      {String title = '🔔 Ειδοποίηση',
      NotificationLayout layout = NotificationLayout.Default}) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: layout,
      ),
    );
  }

  Future<void> doLogin(String email, String password) async {
    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        showAwesomeNotification("All fields are required...",
            title: "❌ Login Failed");

        return;
      }

      Uri uri = Uri.parse("http://${Constants().hostName}/api/user/login");

      Map<String, String> loginData = {
        "Email": email,
        "Password": password,
      };

      http.Response response = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: json.encode(loginData),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        String? accessToken = responseData['data']?['access_token'];

        if (accessToken != null && accessToken.isNotEmpty) {
          print("✅ Login successful. Access Token: $accessToken");

          // Αποθήκευση του Token στη RAM
          globalAccessToken = accessToken;
          print("🔐 Token αποθηκεύτηκε: $globalAccessToken");

          showAwesomeNotification("Login Successful! Redirecting...",
              title: "✅ Success");

          // Μετάβαση στην κεντρική οθόνη
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          });
        } else {
          showAwesomeNotification("Login failed: No access token received",
              title: "❌ Login Failed");
        }
      }
      // 🔹 **Έλεγχος αν το API επιστρέψει 409 (2FA ενεργοποιημένο)**
      else if (response.statusCode == 409) {
        print("⚠️ 2FA Enabled! Requesting OTP Code...");
        showOtpDialog(email);
      } else if (response.statusCode == 401) {
        showAwesomeNotification("Wrong credentials, please try again",
            title: "❌ Login Failed");
      } else {
        showAwesomeNotification("Server error: ${response.statusCode}",
            title: "❌ Login Failed");
      }
    } catch (e) {
      showAwesomeNotification(" Error logging in. Check internet connection.",
          title: "❌ Login Failed");
    }
  }

  void showOtpDialog(String email) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors.background,
          title: Text("Εισαγωγή OTP Κωδικού",
              style: TextStyle(color: colors.accent)),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Εισάγετε τον κωδικό OTP",
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.accent)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colors.accent)),
            ),
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ακύρωση", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                String otpCode = otpController.text.trim();
                if (otpCode.isEmpty) {
                  showAwesomeNotification(" Παρακαλώ εισάγετε τον κωδικό OTP!",
                      title: "❌ Login Failed");
                  return;
                }

                bool success = await verify2FA(email, otpCode);
                if (success) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: colors.accent),
              child: Text("Επιβεβαίωση"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> verify2FA(String email, String otpCode) async {
    try {
      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/User/login/2fa/$otpCode");

      http.Response response = await http.post(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        String? accessToken = responseData['data']?['access_token'];

        if (accessToken != null && accessToken.isNotEmpty) {
          print("✅ 2FA Login successful. Access Token: $accessToken");

          // Αποθήκευση του Token
          globalAccessToken = accessToken;

          showAwesomeNotification("2FA Login Successful! Redirecting...",
              title: "✅ Success");

          // Μετάβαση στην κεντρική οθόνη
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          });

          return true;
        } else {
          showAwesomeNotification(" 2FA Login failed: No access token received",
              title: "❌ Login Failed");
          return false;
        }
      } else {
        showAwesomeNotification(
            "  2FA Login failed! Server error: ${response.statusCode}",
            title: "❌ Login Failed");
        return false;
      }
    } catch (e) {
      showAwesomeNotification("Error verifying 2FA. Check your connection.",
          title: "❌ Login Failed");
      return false;
    }
  }
}
