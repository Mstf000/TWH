import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String serviceId = 'service_9ses61a';
  static const String templateId = 'template_owjm0du';
  static const String publicKey = 'wO1HCdSgF9dfu1oE2';

  static Future<void> sendSummaryEmail({
    required String name,
    required String email,
    required String message,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'name': name,
          'email': email,
          'message': message,
          'time': DateTime.now().toString(),
        },
      }),
    );

    if (response.statusCode != 200) {
      print("response.body: zzzzzzzzzzs ${response.body} ");
      throw Exception('Failed to send email: ${response.body}');
    }
  }
}
