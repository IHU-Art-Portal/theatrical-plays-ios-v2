import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/globals.dart';

class UserService {
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    print("📤 Fetching user profile...");

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
        print("✅ User Info Loaded: ${jsonData['data']}");

        return {
          "facebookUrl": jsonData['data']["facebook"] ?? "",
          "instagramUrl": jsonData['data']["instagram"] ?? "",
          "youtubeUrl": jsonData['data']["youtube"] ?? "",
          "twoFactorEnabled": jsonData['data']["_2FA_enabled"] ?? false,
          "email": jsonData['data']["email"] ?? "Δεν υπάρχει email",
          "role": jsonData['data']["role"] ?? "Χωρίς ρόλο",
          "credits": jsonData['data']["balance"] ?? 0.0,
          "phoneNumber": jsonData['data']["phoneNumber"] ?? "",
          "phoneVerified":
              jsonData['data']["phoneVerified"] ?? false, // ✅ Προσθήκη
        };
      } else {
        print("❌ Σφάλμα στο API: ${response.statusCode}");
        print("📩 API Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Σφάλμα κατά την ανάκτηση του προφίλ: $e");
      return null;
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

  /// ✅ **Ενημέρωση Social Media URL**
  static Future<bool> updateSocialMedia(String platform, String url) async {
    try {
      if (globalAccessToken == null) {
        print("❌ Δεν υπάρχει αποθηκευμένο token.");
        return false;
      }

      // ✅ Διορθωμένο: Το link περνάει ως Query Parameter και όχι στο body!
      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/User/@/$platform?link=${Uri.encodeComponent(url)}");

      print("📤 Request προς API:");
      print("🔹 URL: $uri");

      http.Response response = await http.put(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print("✅ Το $platform ενημερώθηκε επιτυχώς!");
        return true;
      } else {
        print("❌ Σφάλμα ενημέρωσης του $platform: ${response.statusCode}");
        print("📩 API Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα κατά την ενημέρωση του $platform: $e");
      return false;
    }
  }

  static Future<bool> deleteSocialMedia(String platform) async {
    try {
      if (globalAccessToken == null) {
        print("❌ Δεν υπάρχει αποθηκευμένο token.");
        return false;
      }

      Uri uri =
          Uri.parse("http://${Constants().hostName}/api/User/@/$platform");

      print("📤 Διαγραφή social media:");
      print("🔹 URL: $uri");
      print("🔹 Authorization: Bearer $globalAccessToken");

      http.Response response = await http.delete(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken", // ✅ Authentication
          "Content-Type": "application/json", // ✅ Explicit Content-Type
          "Accept": "application/json", // ✅ Ensure JSON response format
        },
      );

      print("📩 Response Code: ${response.statusCode}");
      print("📩 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Το $platform διαγράφηκε επιτυχώς!");
        return true;
      } else {
        print("❌ Σφάλμα διαγραφής του $platform: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα κατά τη διαγραφή του $platform: $e");
      return false;
    }
  }

  static Future<bool> enable2FA() async {
    if (globalAccessToken == null) {
      print("❌ Δεν υπάρχει αποθηκευμένο JWT Token!");
      return false;
    }

    Uri uri = Uri.parse("http://${Constants().hostName}/api/User/enable2fa");

    http.Response response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $globalAccessToken",
        "Content-Type": "application/json",
      },
    );

    print(
        "📩 API Response: ${response.body}"); // ✅ Εκτυπώνουμε την απάντηση του API

    if (response.statusCode == 200) {
      print("✅ Two-Step Security ενεργοποιήθηκε!");
      return true;
    } else {
      print("❌ Σφάλμα ενεργοποίησης 2FA: ${response.statusCode}");
      print(
          "📩 API Error Message: ${response.body}"); // 🔹 Εκτύπωση μηνύματος λάθους
      return false;
    }
  }

  static Future<bool> disable2FA() async {
    try {
      Uri uri = Uri.parse("http://${Constants().hostName}/api/User/disable2fa");

      http.Response response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print("✅ Two-Step Security απενεργοποιήθηκε!");
        return true;
      } else {
        print("❌ Σφάλμα απενεργοποίησης 2FA: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα κατά την απενεργοποίηση του 2FA: $e");
      return false;
    }
  }
}
