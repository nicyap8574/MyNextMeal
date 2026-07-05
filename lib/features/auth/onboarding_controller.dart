import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import '../../screens/home.dart';

class OnboardingController extends GetxController{
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  void updatePageIndicator(index) => currentPageIndex.value = index;

  void dotNavigationClick(index){
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  void nextPage() {
    if(currentPageIndex.value == 5){
      Get.to(Home());
    }else{
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

}