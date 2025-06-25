import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class TwilioWhatsAppService {
  static const String accountSid =
      'AC3b43f51512ba94919e868bf686b41128'; // Your Twilio Account SID
  static const String authToken =
      '54da265673eb05b29e56c57d222b595d'; // Your Twilio Auth Token
  static const String fromNumber =
      'whatsapp:+14155238886'; // Twilio Sandbox WhatsApp Number

  static final _basicAuth =
      'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}';

  static Future<void> sendWhatsAppMessage(
      String toNumber, String pdfUrl) async {
    final uri = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': _basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'From': fromNumber,
        'To': toNumber,
        'Body': '📄 Your Wellness Report is ready! Download it here: $pdfUrl',
      },
    );

    if (response.statusCode != 201) {
      print('❌ Twilio Error Code: ${response.statusCode}');
      print('❌ Twilio Error Body: ${response.body}');
      throw Exception('Failed to send WhatsApp message');
    } else {
      print('✅ WhatsApp message sent successfully!');
    }
  }
}
