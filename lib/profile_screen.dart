import 'package:flutter/material.dart';
import 'package:gymmate/calendar_screen.dart';
import 'package:gymmate/custom_widgets/buttom_navbar.dart';
import 'package:gymmate/edit_profile_screen.dart';
import 'package:gymmate/measurments_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 80, // Makes the AppBar taller
        leadingWidth: 80, // Allow more horizontal space for the logo
        backgroundColor: const Color.fromARGB(255, 37, 36, 34),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            'assets/images/logo-small.png',
            height: 170,
            width: 170,
            fit: BoxFit.contain,
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                color: Color.fromARGB(255, 235, 94, 40),
                // fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color.fromARGB(255, 235, 94, 40),
                  child: Icon(
                    Icons.person_2_outlined,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'User Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'User Email Address',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Workouts',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    Text(
                      '7',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MeasurementsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.accessibility,
                      color: Colors.white,
                      size: 30,
                    ),
                    label: const Text(
                      'Measures',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalendarScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 30,
                    ),
                    label: const Text(
                      'Calendar',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(currentIndex: 1),
    );
  }
}
