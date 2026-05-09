import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../common/styles/spacing_styles.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_functions.dart';

class IndividualMeal extends StatelessWidget {
  final String mealId;
  final String imageUrl;
  const IndividualMeal(this.mealId, this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    print(mealId);
    print(imageUrl);

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Meal Details"),
      ),

      body: SingleChildScrollView(
        child: Padding(
            padding: AppSpacingStyle.paddingWithAppBarHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.network(imageUrl),
              ],
            )
        )
      ),
    );
  }
}
