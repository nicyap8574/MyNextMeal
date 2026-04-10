import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:image_picker/image_picker.dart';

class ImageAnalysisRepository {

  //JSON format
  static final jsonSchema = Schema.object(
      properties: {
        'nutrients': Schema.array(
            items: Schema.object(
                properties: {
                  'meal_name': Schema.string(),
                  'detected_ingredients': Schema.array(
                    items: Schema.string(),
                  ),
                  'carbs_macro': Schema.enumString(enumValues: ['Low', 'Medium', 'High', 'Unknown']),
                  'protein_macro': Schema.enumString(enumValues: ['Low', 'Medium', 'High', 'Unknown']),
                  'fats_macro': Schema.enumString(enumValues: ['Low', 'Medium', 'High', 'Unknown']),
                  'meal_healthiness': Schema.enumString(enumValues: ['Unhealthy', 'Moderate', 'Healthy', 'Unknown']),
                  'confidence_level': Schema.enumString(enumValues: ['Low', 'Medium', 'High']),
                  'brief_summary': Schema.string(),
                }
            )
        )
      }
  );

  //Initialise the Gemini Developer API backend
  final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.1-flash-lite-preview',
      generationConfig: GenerationConfig(
          responseMimeType: 'application/json', responseSchema: jsonSchema));

  static ImageAnalysisRepository get instance => Get.find();

  late RxString response = "".obs;
  final RxBool isLoading = false.obs;
  final ImagePicker picker = ImagePicker();
  final Rxn<File> foodImage = Rxn<File>();

  Future<void> pickImage() async{
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if(image!=null){
      File file = File(image.path);
      foodImage.value = file;
      await analyseFoodImage(file);
    }
  }

  Future<void> analyseFoodImage(File file) async{
    try{
      isLoading.value = true;
      //text prompt
      final prompt = TextPart("Analyze this meal image. Identify the ingredients and estimate the macronutrient composition (carbs, protein, fat as low/medium/high) and give an overall meal healthiness (unhealthy/moderate/healthy) and confidence level (low/medium/high). Provide a brief summary of the meal's nutritional profile. For anything you're unsure about, just state ""Unknown"".");

      //image
      final image = await file.readAsBytes();
      final imagePart = InlineDataPart('image/jpeg', image);

      //generate text output
      final result = await model.generateContent([
        Content.multi([prompt,imagePart])
      ]);

      response.value = result.text!;
    }catch(e){
      response.value = "An error has occurred. Please try again.";
    }finally{
      isLoading.value = false;
    }
  }

}