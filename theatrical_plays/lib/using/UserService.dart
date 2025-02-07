import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/globals.dart';

class UserService {
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      // 🔹 Έλεγχος αν υπάρχει token στη global μεταβλητή
      if (globalAccessToken == null) {
        print(
            "❌ Δεν υπάρχει αποθηκευμένο token. Ο χρήστης μπορεί να είναι αποσυνδεδεμένος.");
        return null;
      }

      Uri uri = Uri.parse("http://${Constants().hostName}/api/user/info");

      http.Response response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization":
              "Bearer $globalAccessToken" // ✅ Χρήση του global token
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
}
