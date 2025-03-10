import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/globals.dart';

class UserService {
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      if (globalAccessToken == null) {
        print("❌ Δεν υπάρχει αποθηκευμένο token.");
        return null;
      }

      Uri uri = Uri.parse("http://${Constants().hostName}/api/user/info");

      http.Response response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $globalAccessToken"
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData['data']; // 🔹 Επιστρέφουμε μόνο τα δεδομένα του χρήστη
      } else {
        print("❌ Σφάλμα στο API: ${response.statusCode}");
        print("📩 Απάντηση από API: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Σφάλμα κατά την ανάκτηση του προφίλ: $e");
      return null;
    }
  }

  static Future<bool> verifyPhoneNumber() async {
    try {
      if (globalAccessToken == null) {
        print("❌ Δεν υπάρχει αποθηκευμένο token.");
        return false;
      }

      Uri uri =
          Uri.parse("http://${Constants().hostName}/api/user/verify-phone");

      http.Response response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print("✅ Ο αριθμός τηλεφώνου επιβεβαιώθηκε επιτυχώς!");
        return true;
      } else {
        print("❌ Σφάλμα επιβεβαίωσης τηλεφώνου: ${response.statusCode}");
        print("📩 API Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα επιβεβαίωσης τηλεφώνου: $e");
      return false;
    }
  }

  static Future<bool> registerPhoneNumber(String phoneNumber) async {
    try {
      if (globalAccessToken == null) {
        print("❌ Δεν υπάρχει αποθηκευμένο token.");
        return false;
      }

      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/User/register/phoneNumber?phoneNumber=$phoneNumber");

      http.Response response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print("✅ Ο αριθμός τηλεφώνου καταχωρήθηκε επιτυχώς!");
        return true;
      } else {
        print("❌ Σφάλμα καταχώρησης αριθμού τηλεφώνου: ${response.statusCode}");
        print("📩 API Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα κατά την καταχώρηση τηλεφώνου: $e");
      return false;
    }
  }

  static Future<bool> confirmPhoneVerification(String verificationCode) async {
    try {
      if (globalAccessToken == null) {
        print("❌ Δεν υπάρχει αποθηκευμένο token.");
        return false;
      }

      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/user/confirm-verification-phone-number");

      http.Response response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "verificationCode": verificationCode, // ✅ Στέλνουμε τον κωδικό OTP
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Το τηλέφωνο επιβεβαιώθηκε επιτυχώς!");
        return true;
      } else {
        print("❌ Σφάλμα επιβεβαίωσης τηλεφώνου: ${response.statusCode}");
        print("📩 API Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα επιβεβαίωσης τηλεφώνου: $e");
      return false;
    }
  }
}
