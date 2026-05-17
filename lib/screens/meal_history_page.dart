import 'package:flutter/material.dart';
import 'meal_history.dart';

class MealHistoryPage extends StatelessWidget {
  const MealHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meal History")),
      body: const MealHistory(),
    );
  }
}
