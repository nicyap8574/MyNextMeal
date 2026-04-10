import 'package:firebase_ai/firebase_ai.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class ImageAnalysisRepository {
  final model = FirebaseAI.googleAI().generativeModel(model: 'gemini-3.1-flash-lite-preview');
  static ImageAnalysisRepository get instance => Get.find();

  static String response = "";


  Future<void> generateText() async{
    final prompt = [Content.text("Write a story about a magic backpack.")];

    final result = await model.generateContent(prompt);

    response = result.text!;
  }

}