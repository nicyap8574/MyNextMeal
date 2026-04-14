import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../data/repositories/authentication_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  Rx<UserModel> user = UserModel.empty().obs; //observing user
  final userRepository = Get.put(UserRepository());
  final _auth = FirebaseAuth.instance;


  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  //Fetch user record
  Future<void> fetchUserRecord() async{
    try{
      final user = await userRepository.fetchUserDetails();
      this.user(user);
    }catch(e){
      print("Error fetching user record: $e");
    }
  }

  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
    AuthenticationRepository.instance.screenRedirect();
  }
}
