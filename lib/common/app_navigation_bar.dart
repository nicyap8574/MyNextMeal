import 'package:flutter/material.dart';
import '../screens/home.dart';
import '../screens/meal_history.dart';
import '../screens/user_profile.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_functions.dart';

class AppNavigationBar extends StatefulWidget {
  const AppNavigationBar({super.key});

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {
  int selectedIndex = 0;

  final List<Widget> pages = const[
    Home(),
    MealHistory(),
    UserProfile(),
  ];

  final List<String?> appBarTitle = const[
    null,
    "Meal History",
    "My Profile",
  ];

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: appBarTitle[selectedIndex]==null ? null : Text(appBarTitle[selectedIndex]!),
      ),
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      body: pages[selectedIndex],

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Get.to(() => const ImageAnalysis()),
      //   backgroundColor: Color(0xFF226147),
      //   foregroundColor: AppColors.celadon100,
      //   child: const Icon(Icons.add),
      // ),

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index){
          setState((){
            selectedIndex = index;
          });
        },
        selectedIndex: selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: AppColors.celadon100),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history, color: AppColors.celadon100),
            icon: Icon(Icons.history_outlined),
            label: 'History',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle, color: AppColors.celadon100),
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
