import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/repositories/image_analysis_repository.dart';
import '../../utils/helpers/helper_functions.dart';
import '../../utils/popups/loaders.dart';
import 'gemini_controller.dart';

class ImageAnalysisController{
  final gemini = GeminiController();


  late RxString response = "".obs;
  final RxBool isLoading = false.obs;
  final ImagePicker picker = ImagePicker();
  final Rxn<XFile> foodImage = Rxn<XFile>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final repo = Get.put(ImageAnalysisRepository());

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
        await analyseFoodImage(image);
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
      final user = _auth.currentUser;

      //text prompt
      final prompt = TextPart("Analyze this meal image. Identify the ingredients and estimate the macronutrient composition (carbs, protein, fat as low/medium/high) and give an overall meal healthiness (unhealthy/moderate/healthy) and confidence level (low/medium/high). Provide a brief summary of the meal's nutritional profile. For anything you're unsure about, just state ""Unknown"".");

      //image
      final image = await file.readAsBytes();
      final imagePart = InlineDataPart('image/jpeg', image);

      //save image to Storage
      final imageUrl = await repo.uploadImage(
        path: 'meal_images/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}',
        image: file,
      );

      //generate text output
      final result = await gemini.analysisModel.generateContent([
        Content.multi([prompt,imagePart])
      ]);

      if(result.text!.contains("error") || result.text!.contains("Overloaded")){
        response.value = "AI is currently busy. Please try again later.";
        return;
      }

      response.value = result.text!;

    }catch(e){
      response.value = "An error has occurred. Please try again.";
    }finally{
      isLoading.value = false;
    }
  }

  //Map<String,dynamic> --> every key is a String, every value is dynamic
  Future<void> saveMealRecord(Map<String, dynamic> json, String imageUrl, BuildContext context) async{
    final user = _auth.currentUser;

    try{
      await _db.collection('meals').add({
        'analysis': json,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'user': user!.uid,
      });

      AppLoaders.showSnackBar(context, "Meal Saved Successfully");
    }catch(e){
      print("Error saving meal: $e");
    }
  }
}