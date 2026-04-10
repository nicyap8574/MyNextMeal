import 'package:firebase_ai/firebase_ai.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class ImageAnalysisRepository {

  //Initialise the Gemini Developer API backend
  final model = FirebaseAI.googleAI().generativeModel(model: 'gemini-3.1-flash-lite-preview');
  static ImageAnalysisRepository get instance => Get.find();

  final RxString response = "".obs;
  final RxBool isLoading = false.obs;


  Future<void> generateText() async{
    try{
      isLoading.value = true;
      final prompt = [Content.text("Write a story about a magic backpack. Keep it to 30 words.")];
      final result = await model.generateContent(prompt);
      response.value = result.text!;
    }catch(e){
      response.value = "An error has occurred. Please try again.";
    }finally{
      isLoading.value = false;
    }

  }

}