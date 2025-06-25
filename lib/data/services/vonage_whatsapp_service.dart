import 'dart:convert';
import 'package:http/http.dart' as http;

class VonageWhatsAppService {
  static const String apiKey = '10b45ad4'; // Your Vonage API Key
  static const String apiSecret = 'TTeKa5bSrNNd3wDe'; // Your Vonage API Secret
  static const String vonageNumber =
      '14157386102'; // Vonage Sandbox Number (without the plus sign)

  // The recipient number is dynamic
  static Future<void> sendPdfLinkToWhatsApp(
      String recipientNumber, String pdfUrl) async {
    String recipientNumbers = '201015063716';
    final url =
        Uri.parse('https://api.nexmo.com/v0.1/messages'); // Correct endpoint

    print("vonageNumber $vonageNumber");
    print("reccccc number $recipientNumbers");
    final body = {
      "from": {
        "type": "whatsapp",
        "number": vonageNumber
      }, // Correct sender number
      "to": {
        "type": "whatsapp",
        "number": recipientNumber
      }, // Dynamic recipient
      "message": {
        "content": {
          "type": "text", // Message type is text
          "text": "📄 Your PDF report is ready: $pdfUrl"
        }
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 202) {
      print('Vonage Error: ${response.statusCode}');
      print(response.body);
      throw Exception('Failed to send WhatsApp message via Vonage');
    } else {
      print('✅ WhatsApp message sent via Vonage!');
    }
  }
}
