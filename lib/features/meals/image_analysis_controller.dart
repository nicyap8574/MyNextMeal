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
import 'package:mynextmeal/screens/meal_history_page.dart';
import 'package:permission_handler/permission_handler.dart';
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

  final mealNameController = TextEditingController();
  final sentimentController = TextEditingController();
  bool _hasSetMealName = false;
  bool _hasSetCarbs = false;
  bool _hasSetProtein = false;
  bool _hasSetFats = false;
  bool _hasSetCategory = false;

  bool _hasEditedMealName = false;
  bool _hasEditedCarbs = false;
  bool _hasEditedProtein = false;
  bool _hasEditedFats = false;
  bool _hasEditedCategory = false;

  var carbsMacro = ''.obs;
  var proteinMacro = ''.obs;
  var fatMacro = ''.obs;
  var category = ''.obs;

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

      final user = _auth.currentUser;

      //text prompt
      final prompt = TextPart("Analyze this meal image. Identify the ingredients and estimate the macronutrient composition (carbs, protein, fat as low/medium/high) and give an overall meal healthiness (unhealthy/moderate/healthy) and confidence level (low/medium/high) and give category of meal (fried/healthy/spicy). Provide a brief summary of the meal's nutritional profile. For anything you're unsure about, just state ""Unknown"".");

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

  //Map<String,dynamic> --> every key is a String, every value is dynamic
  Future<void> saveMealRecord(Map<String, dynamic> json, String imageUrl, BuildContext context) async{
    final user = _auth.currentUser;
    final nutrients = json['nutrients'] as List<dynamic>;
    final meal = nutrients[0] as Map<String,dynamic>;

    //Save edited meal name
    if(originalMealName != mealNameController.text){
      _hasEditedMealName = true;
      meal['meal_name'] = mealNameController.text;
    }

    if(originalCarbsCount != carbsMacro){
      _hasEditedCarbs = true;
      meal['carbs_macro'] = carbsMacro.value;
    }

    if(originalProteinCount != proteinMacro){
      _hasEditedProtein = true;
      meal['protein_macro'] = proteinMacro.value;
    }

    if(originalFatsCount != fatMacro){
      _hasEditedFats = true;
      meal['fats_macro'] = fatMacro.value;
    }

    if(originalCategory != category){
      _hasEditedCategory = true;
      meal['category'] = category.value;
    }

    SentimentResult? sentiment;

    try{
      final sentimentText = sentimentController.text.trim();
      if(sentimentText.isNotEmpty){
        sentiment = await sentimentAnalysis.analyse(sentimentText, apiToken: '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');
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