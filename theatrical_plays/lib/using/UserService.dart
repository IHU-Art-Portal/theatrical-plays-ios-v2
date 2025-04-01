import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/globals.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:theatrical_plays/models/AccountRequestDto.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';

class UserService {
  static String? lastResponseBody; // Για debugging
  static String? lastImageId; // Για αποθήκευση του τελευταίου ID εικόνας

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
        // print("✅ User Info Loaded: ${jsonData['data']}");

        // Προσθήκη ελέγχου για το userImages
        List<dynamic> images = jsonData['data']['userImages'] ?? [];

        // print("📷 Found ${images.length} images!"); // Debugging
        // images.forEach((img) => print("📸 Image URL: ${img['imageLocation']}"));

        return {
          "userId": jsonData['data']["id"] ?? "",
          "facebookUrl": jsonData['data']["facebook"] ?? "",
          "instagramUrl": jsonData['data']["instagram"] ?? "",
          "youtubeUrl": jsonData['data']["youtube"] ?? "",
          "twoFactorEnabled": jsonData['data']["_2FA_enabled"] ?? false,
          "email": jsonData['data']["email"] ?? "Δεν υπάρχει email",
          "role": jsonData['data']["role"] ?? "Χωρίς ρόλο",
          "credits": jsonData['data']["balance"] ?? 0.0,
          "phoneNumber": jsonData['data']["phoneNumber"] ?? "",
          "phoneVerified": jsonData['data']["phoneVerified"] ?? false,
          "userImages": images, // ✅ Επιστρέφουμε τις φωτογραφίες του χρήστη
          "profilePhoto": jsonData['data']["profilePhoto"] ?? {},
          "username": jsonData['data']["username"] ?? "",
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

      // Ελέγχουμε το τρέχον προφίλ για να δούμε το υπάρχον τηλέφωνο
      var profileData = await fetchUserProfile();
      // print("📋 Τρέχοντα δεδομένα προφίλ: $profileData");
      if (profileData != null) {
        String? existingPhone = profileData["phoneNumber"];
        bool isVerified = profileData["phoneVerified"] ?? false;
        // print("📞 Υπάρχον τηλέφωνο: $existingPhone, Επαληθευμένο: $isVerified");
      }

      // ✅ Χρησιμοποιούμε query parameter αντί για body
      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/User/register/phoneNumber?phoneNumber=${Uri.encodeComponent(phoneNumber)}");

      http.Response response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Content-Type": "application/json",
        },
      );

      lastResponseBody = response.body; // Αποθήκευση για debugging
      // print(
      //     "📩 API Response: ${response.body}, Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Ο αριθμός τηλεφώνου καταχωρήθηκε επιτυχώς!");
        return true;
      } else if (response.statusCode == 400) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData["errorCode"] == "BadRequest" &&
            responseData["message"] == "User already has a registered number") {
          print(
              "❌ Ο χρήστης έχει ήδη καταχωρημένο τηλέφωνο, αν και τα δεδομένα δείχνουν NULL. Ελέγξτε το backend.");
          return false;
        } else {
          print(
              "❌ Σφάλμα καταχώρισης αριθμού τηλεφώνου: ${response.statusCode}");
          return false;
        }
      } else {
        print("❌ Σφάλμα καταχώρισης αριθμού τηλεφώνου: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα κατά την καταχώριση τηλεφώνου: $e");
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
          "http://${Constants().hostName}/api/user/confirm-verification-phone-number?verificationCode=${Uri.encodeComponent(verificationCode)}");

      http.Response response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Content-Type": "application/json",
        },
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

  static Future<bool> requestPhoneVerification() async {
    try {
      if (globalAccessToken == null) {
        print("❌ Δεν υπάρχει αποθηκευμένο token.");
        return false;
      }

      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/User/request-verification-phone-number");

      http.Response response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print("✅ Ο κωδικός επιβεβαίωσης στάλθηκε στο κινητό!");
        return true;
      } else {
        print(
            "❌ Σφάλμα αποστολής κωδικού επιβεβαίωσης: ${response.statusCode}");
        print("📩 API Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα κατά την αποστολή κωδικού επιβεβαίωσης: $e");
      return false;
    }
  }

  static Future<bool> deletePhoneNumber() async {
    try {
      if (globalAccessToken == null) {
        print("❌ Δεν υπάρχει αποθηκευμένο token.");
        return false;
      }

      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/User/remove/phoneNumber");

      http.Response response = await http.delete(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print("✅ Το τηλέφωνο διαγράφηκε επιτυχώς!");
        return true;
      } else {
        print("❌ Σφάλμα διαγραφής τηλεφώνου: ${response.statusCode}");
        print("📩 API Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα κατά τη διαγραφή του τηλεφώνου: $e");
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

  static String createCheckoutSession(int credits, double price) {
    return "http://${Constants().hostName}/api/Stripe/create-checkout-session?creditAmount=$credits&price=$price";
  }

  static Future<bool> uploadUserPhoto({
    File? imageFile,
    String? imageUrl,
    required String label,
    bool isProfile = false,
  }) async {
    try {
      if (globalAccessToken == null) {
        print("❌ Δεν υπάρχει αποθηκευμένο token.");
        return false;
      }

      Uri uri =
          Uri.parse("http://${Constants().hostName}/api/User/UploadPhoto");

      String? base64Image;
      if (imageFile != null) {
        List<int> imageBytes = await imageFile.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      Map<String, dynamic> body = {
        "photo": base64Image ?? imageUrl,
        "label": label,
        "isProfile": isProfile,
      };

      print("📤 Αποστολή δεδομένων: ${jsonEncode(body)}");

      var response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: jsonEncode(body),
      );

      lastResponseBody = response.body; // Αποθήκευση για debugging
      print(
          "📩 API Response: ${response.body}, Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Εικόνα αποθηκεύτηκε στο backend!");
        // Δεν χρειαζόμαστε το ID εδώ, το fetchUserProfile θα το φέρει
        return true;
      } else {
        print("❌ Αποτυχία αποστολής εικόνας: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα αποστολής εικόνας: $e");
      return false;
    }
  }

  static Future<bool> updateProfilePhoto(String imageId) async {
    try {
      if (globalAccessToken == null) {
        print("❌ Δεν υπάρχει αποθηκευμένο token.");
        return false;
      }

      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/User/Set/Profile-Photo");
      Map<String, dynamic> body = {"imageId": imageId};

      print("📤 Requesting profile photo update with imageId: $imageId");
      print("🔹 Full URI: $uri");
      print("🔹 Body: ${jsonEncode(body)}");

      http.Response response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Accept": "text/plain",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      lastResponseBody = response.body;
      print(
          "📩 Profile Update Response: ${response.body}, Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Η φωτογραφία ορίστηκε ως προφίλ!");
        return true;
      } else {
        print("❌ Σφάλμα ορισμού φωτογραφίας προφίλ: ${response.statusCode}");
        print("📩 Λεπτομέρειες σφάλματος: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα κατά τον ορισμό φωτογραφίας προφίλ: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUserImages(int userId) async {
    try {
      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/User/Images?userId=$userId");

      http.Response response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $globalAccessToken",
        },
      );

      if (response.statusCode == 200) {
        // Parse the response
        List<dynamic> jsonData = jsonDecode(response.body);

        // Map the data to a list of images
        List<Map<String, dynamic>> userImages = jsonData.map((image) {
          return {
            "url": image["url"] ?? "",
            "label": image["label"] ?? "",
            "isProfile": image["isProfile"] ?? false,
          };
        }).toList();

        return userImages;
      } else {
        print("❌ Failed to load user images: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching user images: $e");
      return [];
    }
  }

  static Future<bool> deleteUserImage(String imageId) async {
    try {
      if (globalAccessToken == null) {
        print("❌ Δεν υπάρχει αποθηκευμένο token.");
        return false;
      }

      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/User/Remove/Image/$imageId");

      http.Response response = await http.delete(
        uri,
        headers: {
          "Authorization": "Bearer $globalAccessToken",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print("✅ Η εικόνα διαγράφηκε επιτυχώς!");
        return true;
      } else {
        print("❌ Σφάλμα διαγραφής εικόνας: ${response.statusCode}");
        print("📩 API Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Σφάλμα κατά τη διαγραφή εικόνας: $e");
      return false;
    }
  }

  static Future<List<AccountRequestDto>> getAllClaims() async {
    try {
      final token = globalAccessToken;

      if (token == null) {
        throw Exception("❌ Δεν υπάρχει διαθέσιμο JWT token.");
      }

      final uri = Uri.parse(
          "http://${Constants().hostName}/api/AccountRequests/ClaimsManagers");

      final res = await http.get(uri, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      print("📩 Claims API responded with status ${res.statusCode}");
      print("📩 Body: ${res.body}");

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final List<dynamic> data = json['data']; // <-- παίρνουμε το "data"
        return data.map((e) => AccountRequestDto.fromJson(e)).toList();
      } else {
        throw Exception("Failed to fetch claims (${res.statusCode})");
      }
    } catch (e) {
      print("❌ Exception in getAllClaims(): $e");
      rethrow;
    }
  }

  static Future<bool> updateUsername(String username) async {
    if (globalAccessToken == null) return false;

    final uri = Uri.parse(
        "http://${Constants().hostName}/api/User/Update/Username/$username");

    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $globalAccessToken",
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> approveClaim(int requestId) async {
    final uri = Uri.parse(
        "http://${Constants().hostName}/api/AccountRequests/Approve/$requestId");
    final res = await http.get(uri, headers: {
      "Authorization": "Bearer $globalAccessToken",
    });
    return res.statusCode == 200;
  }

  static Future<bool> rejectClaim(int requestId) async {
    final uri = Uri.parse(
        "http://${Constants().hostName}/api/AccountRequests/Reject/$requestId");
    final res = await http.get(uri, headers: {
      "Authorization": "Bearer $globalAccessToken",
    });
    return res.statusCode == 200;
  }
}
