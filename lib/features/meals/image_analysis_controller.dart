import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mynextmeal/features/meals/meal_history_controller.dart';
import 'package:mynextmeal/features/meals/sentiment_analysis.dart';
import 'package:mynextmeal/features/user/user_profile_controller.dart';
import 'package:mynextmeal/screens/image_analysis.dart';
import 'package:mynextmeal/screens/meal_history_page.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../env.dart';
import '../../utils/helpers/helper_functions.dart';
import '../../utils/popups/loaders.dart';
import '../../services/gemini_controller.dart';

class ImageAnalysisController{
  final gemini = GeminiController();
  final sentimentAnalysis = SentimentAnalysis();

  late RxString response = "".obs;
  final RxString imageUrl = "".obs;
  final Rxn<String> errorMessage = Rxn<String>();
  final RxBool isLoading = false.obs;
  final ImagePicker picker = ImagePicker();
  final Rxn<XFile> foodImage = Rxn<XFile>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final deviceStorage = GetStorage();
  String originalMealName = "";
  String originalCarbsCount = "";
  String originalProteinCount = "";
  String originalFatsCount = "";
  String originalCategory = "";
  String userTextInput = "";

  final mealNameController = TextEditingController();
  final sentimentController = TextEditingController();
  bool _hasSetMealName = false;
  bool _hasSetCarbs = false;
  bool _hasSetProtein = false;
  bool _hasSetFats = false;
  bool _hasSetCategory = false;

  var carbsMacro = ''.obs;
  var proteinMacro = ''.obs;
  var fatMacro = ''.obs;
  var category = ''.obs;
  var briefSummary = ''.obs;

  final RxList<String> ingredients = <String>[].obs;
  final RxBool isSummaryLoading = false.obs;

  final macroOptions = ['Low','Medium','High','Unknown'];
  final categoryOptions = ['Fried','Grilled','Steamed','Vegetarian','Healthy','Spicy','Fast Food','Dessert','Unknown'];

  Future<String> uploadImage({required String path, required XFile image}) async{
    try{
      final storageRef = FirebaseStorage.instance.ref(path);
      final imageRef = storageRef.child(image.name);
      await imageRef.putFile(File(image.path));
      return await imageRef.getDownloadURL();
    }catch (e){
      print("FIREBASE STORAGE ERROR: $e");
      throw e;
    }
  }

  Future<bool> validateImage(XFile file) async{
    try{
      isLoading.value = true;
      errorMessage.value = null;

      final prompt = TextPart("Identify if this image contains food");

      final image = await file.readAsBytes();
      final imagePart = InlineDataPart('image/jpeg', image);

      //generate text output
      final result = await gemini.validationModel.generateContent([
        Content.multi([prompt,imagePart])
      ]);

      final text = result.text ?? '';

      if(text.isEmpty){
        errorMessage.value = "Failed to analyse the image";
        return false;
      }

      final data = jsonDecode(text);
      final bool isFood = data['is_food'] ?? false;
      final double confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;

      if(!isFood || confidence < 0.7){
        errorMessage.value = "The uploaded image is not recognised as a food item";

        Get.dialog(
          AlertDialog(
            title: Text("Invalid Image"),
            content: Text("The uploaded image is not recognised as a food item"),
            actions:[
              TextButton(
                onPressed: () => Get.close(2),
                child: Text("OK"),
              ),
            ],
          ),
        );

        return false;
      }

      return true;
    }catch(e){
      print("Validation error: $e");
      errorMessage.value = "An error occurred";
      return false;
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> deleteImage({required String imageUrl}) async{
    try{
      final imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await imageRef.delete();
    }catch (e){
      print("FIREBASE STORAGE ERROR: $e");
      throw e;
    }
  }

  Future<bool> pickImage() async{
    Permission permission;

    //storage permission depending on Android version
    if(Platform.isAndroid){
      if(await AppHelperFunctions.isAndroid13OrAbove()){
        permission = Permission.photos;
      }else{
        permission = Permission.storage;
      }

    var status = await permission.request();

    if(status.isGranted){
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if(image!=null){
        foodImage.value = image;

        _hasSetMealName = false;
        mealNameController.clear();
        sentimentController.clear();
        ingredients.clear();
        briefSummary.value = '';

        analyseFoodImage(image);
        return true;
        }
    }
    }else{
      print("Storage Permission Denied");
      return false;
    }

    return false;
  }

  Future<void> analyseFoodImage(XFile file) async{
    try{
      isLoading.value = true;
      errorMessage.value = null;

      //Reset all variables
      _hasSetMealName = false;
      _hasSetCarbs = false;
      _hasSetProtein = false;
      _hasSetFats = false;
      _hasSetCategory = false;
      carbsMacro.value = '';
      proteinMacro.value = '';
      fatMacro.value = '';
      category.value = '';
      mealNameController.clear();
      sentimentController.clear();
      briefSummary.value = '';
      ingredients.clear();
      foodImage.value = null;
      imageUrl.value = "";
      userTextInput = "";

      final isValid = await validateImage(file);

      if(!isValid){
        return;
      }

      foodImage.value = file;
      isLoading.value = true;

      final user = _auth.currentUser;

      //text prompt
      final prompt = TextPart("""
        Analyze this meal image. 
        - Identify the ingredients and estimate the macronutrient composition (carbs, protein, fat as low/medium/high) 
        - Give an overall meal healthiness (unhealthy/moderate/healthy) 
        - Give confidence level (low/medium/high)
        - Give category of meal (fried/healthy/spicy). 
        - Provide a 1-line macro explanation describing the balance of carbs, protein, and fats. Must directly reference carbs, protein, and/or fats. Focus on balance (e.g. high carbs, low protein, moderate fat)
        For anything you're unsure about, just state "Unknown".
      """);

      //image
      final image = await file.readAsBytes();
      final imagePart = InlineDataPart('image/jpeg', image);

      //save image to Storage
      imageUrl.value = await uploadImage(
        path: 'meal_images/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}',
        image: file,
      );

      //generate text output
      final result = await gemini.analysisModel.generateContent([
        Content.multi([prompt,imagePart])
      ]);

      final text = result.text ?? '';

      if(text.contains("error") || text.contains("Overloaded")){
        errorMessage.value = "AI is currently busy. Please try again later.";
        response.value = '';
        return;
      }

      response.value = text;

      //add detected meal name to mealNameController.text (so that will be editable later)
      try{
        final data = jsonDecode(text);
        final nutrients = data['nutrients'] as List<dynamic>;
        final meal = nutrients[0] as Map<String,dynamic>;

        originalMealName = meal['meal_name'] ?? '';
        originalCarbsCount = meal['carbs_macro'] ?? '';
        originalProteinCount = meal['protein_macro'] ?? '';
        originalFatsCount = meal['fats_macro'] ?? '';
        originalCategory = meal['category'] ?? '';

        meal['manual_text_input'] = "";

        //initial Gemini result
        final briefSummaryOriginal = meal['brief_summary'] ?? '';
        briefSummary.value = briefSummaryOriginal;

        if(!_hasSetMealName){
          mealNameController.text = originalMealName;
          _hasSetMealName = true;
        }
        if(!_hasSetCarbs){
          carbsMacro.value = originalCarbsCount;
          _hasSetCarbs = true;
        }
        if(!_hasSetProtein){
          proteinMacro.value = originalProteinCount;
          _hasSetProtein = true;
        }
        if(!_hasSetFats){
          fatMacro.value = originalFatsCount;
          _hasSetFats = true;
        }
        if(!_hasSetCategory){
          category.value = originalCategory;
          _hasSetCategory = true;
        }

        final List<dynamic> detectedIngredients = meal['detected_ingredients'] ?? [];
        ingredients.assignAll(detectedIngredients.cast<String>());

        briefSummary.value = meal['brief_summary'] ?? '';

      }catch(e){
        print(e);
      }

      errorMessage.value = null;

    }catch(e){
      errorMessage.value = "An error has occurred. Please try again.";
      response.value = '';
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> analyseFoodText({required String mealDetails}) async{
    try{
      isLoading.value = true;
      errorMessage.value = null;

      //Reset all variables
      _hasSetMealName = false;
      _hasSetCarbs = false;
      _hasSetProtein = false;
      _hasSetFats = false;
      _hasSetCategory = false;
      carbsMacro.value = '';
      proteinMacro.value = '';
      fatMacro.value = '';
      category.value = '';
      mealNameController.clear();
      sentimentController.clear();
      briefSummary.value = '';
      ingredients.clear();
      foodImage.value = null;
      imageUrl.value = "";
      userTextInput = mealDetails;

      //text prompt
      final prompt = TextPart("""
        Analyze this meal description: $mealDetails
        - Identify the ingredients and estimate the macronutrient composition (carbs, protein, fat as low/medium/high) 
        - Give an overall meal healthiness (unhealthy/moderate/healthy) 
        - Give confidence level (low/medium/high)
        - Give category of meal (fried/healthy/spicy). 
        - Provide a 1-line macro explanation describing the balance of carbs, protein, and fats. Must directly reference carbs, protein, and/or fats. Focus on balance (e.g. high carbs, low protein, moderate fat)
        For anything you're unsure about, just state "Unknown".
      """);

      final result = await gemini.analysisModel.generateContent([
        Content.text(prompt.text)
      ]);

      final text = result.text ?? '';

      if(text.contains("error") || text.contains("Overloaded")){
        errorMessage.value = "AI is currently busy. Please try again later.";
        response.value = '';
        return;
      }

      response.value = text;

      try{
        final data = jsonDecode(text);
        final nutrients = data['nutrients'] as List<dynamic>;
        final meal = nutrients[0] as Map<String,dynamic>;

        originalMealName = meal['meal_name'] ?? '';
        originalCarbsCount = meal['carbs_macro'] ?? '';
        originalProteinCount = meal['protein_macro'] ?? '';
        originalFatsCount = meal['fats_macro'] ?? '';
        originalCategory = meal['category'] ?? '';

        //initial Gemini result
        final briefSummaryOriginal = meal['brief_summary'] ?? '';
        briefSummary.value = briefSummaryOriginal;

        if(!_hasSetMealName){
          mealNameController.text = originalMealName;
          _hasSetMealName = true;
        }
        if(!_hasSetCarbs){
          carbsMacro.value = originalCarbsCount;
          _hasSetCarbs = true;
        }
        if(!_hasSetProtein){
          proteinMacro.value = originalProteinCount;
          _hasSetProtein = true;
        }
        if(!_hasSetFats){
          fatMacro.value = originalFatsCount;
          _hasSetFats = true;
        }
        if(!_hasSetCategory){
          category.value = originalCategory;
          _hasSetCategory = true;
        }

        final List<dynamic> detectedIngredients = meal['detected_ingredients'] ?? [];
        ingredients.assignAll(detectedIngredients.cast<String>());

        briefSummary.value = meal['brief_summary'] ?? '';

      }catch(e){
        print(e);
      }

      errorMessage.value = null;
    }catch(e){
      errorMessage.value = "An error has occurred. Please try again.";
      response.value = '';
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> regenerateMealSummary() async{

    try{
      isSummaryLoading.value = true;
      errorMessage.value = null;

      final mealName = mealNameController.text;
      final currentIngredients = ingredients.join(', ');
      final carbs = carbsMacro.value;
      final protein = proteinMacro.value;
      final fats = fatMacro.value;

      //text prompt
      final prompt = TextPart("""
        Meal Name: $mealName
        Ingredients: $currentIngredients
        Carbs Macro: $carbs
        Protein Macro: $protein
        Fats Macro: $fats
    
        Based on the provided food details, provide a 1-line macro explanation describing the balance of carbs, protein, and fats. Must directly reference carbs, protein, and/or fats. Focus on balance (e.g. high carbs, low protein, moderate fat)
        For anything you're unsure about, just state "Unknown".
      """);

      final result = await gemini.summaryModel.generateContent([Content.text(prompt.text)]);
      final text = result.text ?? '';

      if(text.isEmpty || text.contains("error")){
        errorMessage.value = "Failed to regenerate summary";
        return;
      }

      final data = jsonDecode(text);
      if(data['brief_summary'] != null){
        briefSummary.value = data['brief_summary'];
      }

    }catch(e){
      print(e);
      errorMessage.value = "An error occurred during regeneration.";
    }finally{
      isSummaryLoading.value = false;
    }
  }

  //Map<String,dynamic> --> every key is a String, every value is dynamic
  Future<void> saveMealRecord(Map<String, dynamic> json, String imageUrl, String mealDetails, BuildContext context) async{
    final user = _auth.currentUser;
    final nutrients = json['nutrients'] as List<dynamic>;
    final meal = nutrients[0] as Map<String,dynamic>;

    //Save edited meal name
    if(originalMealName != mealNameController.text){
      meal['meal_name'] = mealNameController.text;
    }

    if(originalCarbsCount != carbsMacro.value){
      meal['carbs_macro'] = carbsMacro.value;
    }

    if(originalProteinCount != proteinMacro.value){
      meal['protein_macro'] = proteinMacro.value;
    }

    if(originalFatsCount != fatMacro.value){
      meal['fats_macro'] = fatMacro.value;
    }

    if(originalCategory != category.value){
      meal['category'] = category.value;
    }

    //Save updated ingredients list
    meal['detected_ingredients'] = ingredients.toList();

    //Save updated summary
    meal['brief_summary'] = briefSummary.value;

    meal['manual_text_input'] = userTextInput;

    SentimentResult? sentiment;

    try{
      final sentimentText = sentimentController.text.trim();
      if(sentimentText.isNotEmpty){
        sentiment = await sentimentAnalysis.analyse(sentimentText, apiToken: Env.hf_apiKey);
      }else if(sentimentText.isEmpty){
        sentimentText == "No sentiment provided.";
      }

      await _db.collection('meals').add({
        'analysis': json,
        'sentiment': sentimentController.text,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'user': user!.uid,
        if(sentiment != null) ...{
          'sentimentText': sentiment.rawText,
          'sentimentLabel': sentiment.label,
          'sentimentScore': sentiment.score,
        }
      });

      final userRef = await _db.collection('users').doc(user!.uid);
      final categoryValue = (meal['category'] ?? 'unknown').toLowerCase();
      final sentimentLabel = (sentiment?.label ?? 'neutral').toLowerCase();

      await userRef.set({
        // 'categoryStats.$categoryValue.$sentimentLabel': FieldValue.increment(1),
        "categoryStats":{
          categoryValue: {
            sentimentLabel: FieldValue.increment(1),
          },
        },
      }, SetOptions(merge: true));
      //SetOptions - don't overwrite document

      // Invalidate user profile cache so that preferred/avoided categories recalculate immediately
      UserProfileController.instance.clearCache();

      AppLoaders.showSnackBar(context, "Meal Saved Successfully");
    }catch(e){
      print("Error saving meal: $e");
    }finally{
            Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const MealHistoryPage(),
        ),
        (route)=> route.isFirst,
      );
    }
  }
}