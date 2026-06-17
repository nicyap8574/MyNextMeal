import 'dart:convert';

import 'package:http/http.dart' as http;

class SentimentResult {
  final String label;
  final double score;
  final String rawText;

  SentimentResult({
    required this.label,
    required this.score,
    required this.rawText,
  });
}

class SentimentAnalysis {
  static const modelUrl = "https://router.huggingface.co/hf-inference/models/cardiffnlp/twitter-roberta-base-sentiment-latest";

  Future<SentimentResult?> analyse(String text, {required String apiToken}) async {
    final response = await http.post(
      Uri.parse(modelUrl),
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': text,
        'options': {'wait_for_model': true},
      }),
    );

    if(response.statusCode != 200){
      throw Exception("Sentiment API failed: ${response.statusCode} ${response.body}");
    }

    final decoded = jsonDecode(response.body);

    final List<dynamic> predictions = decoded[0];
    predictions.sort((a,b) => (b['score'] as num).compareTo(a['score'] as num));
    final top = predictions.first;

    return SentimentResult(
      label: top['label'] as String,
      score: (top['score'] as num).toDouble(),
      rawText: text,
    );
  }
}