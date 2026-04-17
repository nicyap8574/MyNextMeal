import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/repositories/image_analysis_repository.dart';

class ImageAnalysisController{

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
      // model: 'gemini-2.5-flash-lite',
      generationConfig: GenerationConfig(
          responseMimeType: 'application/json', responseSchema: jsonSchema));

  late RxString response = "".obs;
  final RxBool isLoading = false.obs;
  final ImagePicker picker = ImagePicker();
  final Rxn<XFile> foodImage = Rxn<XFile>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final repo = Get.put(ImageAnalysisRepository());

  Future<void> pickImage() async{
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if(image!=null){
      // File file = File(image.path);
      foodImage.value = image;
      await analyseFoodImage(image);
    }
  }

  Future<void> analyseFoodImage(XFile file) async{
    try{
      isLoading.value = true;
      final user = _auth.currentUser;


      //text prompt
      final prompt = TextPart("Analyze this meal image. Identify the ingredients and estimate the macronutrient composition (carbs, protein, fat as low/medium/high) and give an overall meal healthiness (unhealthy/moderate/healthy) and confidence level (low/medium/high). Provide a brief summary of the meal's nutritional profile. For anything you're unsure about, just state ""Unknown"".");

      //image
      final image = await file.readAsBytes();
      final imagePart = InlineDataPart('image/jpeg', image);


      final imageUrl = await repo.uploadImage(
        path: 'meal_images/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}',
        image: file,
      );

      //generate text output
      final result = await model.generateContent([
        Content.multi([prompt,imagePart])
      ]);

      if(result.text!.contains("error") || result.text!.contains("Overloaded")){
        response.value = "AI is currently busy. Please try again later.";
        return;
      }

      response.value = result.text!;

      try{
        //change into appropriate format to be understood
        final data = jsonDecode(response.value) as Map<String,dynamic>;
        await saveMealRecord(data, imageUrl);
      }catch (e){
        response.value = "Response is unable to be generated. Please try again later.";
      }
    }catch(e){
      response.value = "An error has occurred. Please try again.";
    }finally{
      isLoading.value = false;
    }
  }

  //Map<String,dynamic> --> every key is a String, every value is dynamic
  Future<void> saveMealRecord(Map<String, dynamic> json, String imageUrl) async{
    final user = _auth.currentUser;

    await _db.collection('meals').add({
      'analysis': json,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'user': user!.uid,
    });
  }
}