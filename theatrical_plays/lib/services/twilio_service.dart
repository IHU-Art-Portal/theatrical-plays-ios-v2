import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TwilioService {
  static final String accountSid = dotenv.env['TWILIO_ACCOUNT_SID'] ?? "";
  static final String authToken = dotenv.env['TWILIO_AUTH_TOKEN'] ?? "";
  static final String messagingServiceSid =
      dotenv.env['TWILIO_MESSAGING_SID'] ?? "";

  static String formatPhoneNumber(String phone) {
    phone = phone.trim();
    if (!phone.startsWith("+")) {
      return "+30" + phone;
    }
    return phone;
  }

  static Future<bool> sendOtp(String phoneNumber, String otp) async {
    if (accountSid.isEmpty || authToken.isEmpty) {
      print("❌ Twilio API credentials are missing!");
      return false;
    }

    phoneNumber = formatPhoneNumber(phoneNumber);
    print("📨 Sending OTP to: $phoneNumber");

    final url = Uri.parse(
        "https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json");

    final response = await http.post(
      url,
      headers: {
        "Authorization":
            "Basic " + base64Encode(utf8.encode("$accountSid:$authToken")),
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: {
        "MessagingServiceSid": messagingServiceSid,
        "To": phoneNumber,
        "Body": "Your OTP code is: $otp"
      },
    );

    print("Twilio Response Code: ${response.statusCode}");
    print("Twilio Response Body: ${response.body}");

    return response.statusCode == 201 || response.statusCode == 200;
  }
}
