import 'package:flutter/material.dart';


class MyBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const MyBottomNavBar({super.key, required this.currentIndex});

  void _onTabTapped(BuildContext context, int index) {
   // if (index == currentIndex) return; // already on this page, do nothing

    if (index == 0) {
     Navigator.pushReplacementNamed(context, '/workout');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 90,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: const Color.fromARGB(255, 37, 36, 34),
        selectedItemColor: const Color.fromARGB(255, 235, 94, 40),
        unselectedItemColor: Colors.white,
        onTap: (index) => _onTabTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
