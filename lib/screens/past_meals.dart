import 'package:flutter/material.dart';
import 'package:mynextmeal/common/styles/spacing_styles.dart';

class PastMeals extends StatelessWidget {
  const PastMeals({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(

          )
        )
      )
    );

  }
}
