import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:http/http.dart' as http;
import 'Constants.dart';
import 'globals.dart'; // Πρόσβαση στο globalAccessToken

class VenueService {
  /// Κλήση για διεκδίκηση χώρου
  static Future<bool> claimVenue(int venueId) async {
    final uri = Uri.parse(
        "http://${Constants().hostName}/api/venues/claim-venue/$venueId/");
    final token = globalAccessToken;

    print('🪪 Token used: $token');

    final response = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print('🔄 Status Code: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      _showNotification("Το αίτημα εγκρίθηκε αυτόματα ✅");
      return true;
    } else {
      _showNotification(
          "Αποτυχία αιτήματος ❌ - Κωδικός: ${response.statusCode}");
      return false;
    }
  }

  /// Κλήση για ενημέρωση στοιχείων χώρου
  static Future<bool> updateVenue(
      int venueId, String title, String address) async {
    final uri =
        Uri.parse("http://${Constants().hostName}/api/venues/update/$venueId");
    final token = globalAccessToken;

    print('🪪 Token used: $token');
    print('✏️ Ενημέρωση Venue με Title: $title, Address: $address');

    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "title": title,
        "address": address,
      }),
    );

    print('🔄 Status Code: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      _showNotification("Το venue ενημερώθηκε επιτυχώς ✅");
      return true;
    } else {
      _showNotification(
          "Αποτυχία ενημέρωσης ❌ - Κωδικός: ${response.statusCode}");
      return false;
    }
  }

  /// Εμφάνιση Notification
  static void _showNotification(String message) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        channelKey: 'basic_channel',
        title: 'Διαχείριση Χώρου',
        body: message,
      ),
    );
  }
}
