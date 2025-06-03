import 'dart:convert';
import 'package:http/http.dart' as http;

class AISummaryService {
  final String _apiKey = 'AIzaSyCl9wlLOV3nc7lwnXXCesNr6t379pJRG1I';

  Future<String> generateSummary(Map<String, dynamic> formData) async {
    final prompt = _buildPrompt(formData);

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception("Failed to get summary: ${response.body}");
    }
  }

  String _buildPrompt(Map<String, dynamic> formData) {
    return '''
You are a professional wellness consultant specializing in therapeutic product recommendations and holistic lifestyle evaluations.

Your assignment is as follows:

1. Analyze the client data provided below to determine the **single most appropriate product category** for their needs from the following list:
   - Massage Chairs
   - Back Massage Devices
   - Foot Massage Devices
   - Wellness Tools
   - Fitness Products

2. Justify the selected category based on the client’s health profile, lifestyle habits, and physical needs.

3. Provide a **succinct wellness profile summary** that reflects the client’s routine, challenges, and areas of improvement.

4. Offer **2 to 3 targeted wellness recommendations** that are practical, easy to adopt, and relevant to the selected category.

5. Ensure your output is **professional, direct, and client-ready** with **no follow-up language** (e.g., avoid phrases like “let me know” or “we can explore further”).

6. Conclude with a **motivational statement** encouraging the client to take action toward improving their well-being.

Additionally, **translate the entire response into Arabic underneath**, preserving formality and professionalism.

Client Data (JSON):
${json.encode(formData)}
''';
  }
}
