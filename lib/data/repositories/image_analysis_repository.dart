import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageAnalysisRepository extends GetxController{
  static ImageAnalysisRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  //final repo = Get.put(ImageAnalysisRepository());

  Future<String> uploadImage({required String path, required XFile image}) async{
    try{
      final ref = FirebaseStorage.instance.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      return await ref.getDownloadURL();
    }catch (e){
      print("FIREBASE STORAGE ERROR: $e");
      rethrow;
    }
    }
  }

