import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;

  OpenAIService(this.apiKey);

  Future<String?> rateImage(File imageFile) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "model": "gpt-4-vision-preview",
      "messages": [
        {
          "role": "user",
          "content": [
            {"type": "text", "text": "Rate this photo from 1 to 10 and explain why."},
            {"type": "image_url", "image_url": {"url": "data:image/jpeg;base64,$base64Image"}}
          ]
        }
      ],
      "max_tokens": 300
    });

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print('OpenAI API error: ${response.body}');
      return null;
    }
  }
}
