import 'package:flutter/material.dart';

import '../../screens/home.dart';
import '../../screens/user_profile.dart';

class AppNavigationBar extends StatefulWidget {
  const AppNavigationBar({super.key});

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {
  int currentPageIndex = 0;

  final List<Widget> pages = const[
    Home(),
    UserProfile(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: pages[currentPageIndex],

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index){
          setState((){
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
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
