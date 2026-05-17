import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageAnalysisRepository extends GetxController{
  static ImageAnalysisRepository get instance => Get.find();

  final deviceStorage = GetStorage();

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
}