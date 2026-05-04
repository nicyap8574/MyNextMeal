import 'package:flutter/material.dart';

import '../../screens/home.dart';
import '../../screens/user_profile.dart';
import '../../utils/constants/colors.dart';
import '../../utils/helpers/helper_functions.dart';

class AppNavigationBar extends StatefulWidget {
  const AppNavigationBar({super.key});

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {
  int selectedIndex = 0;

  final List<Widget> pages = const[
    Home(),
    UserProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(

      //appBar
      appBar: AppBar(),
      backgroundColor: dark ? AppColors.darkBackground : AppColors.lightBackground,
      body: pages[selectedIndex],

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index){
          setState((){
            selectedIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle),
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
