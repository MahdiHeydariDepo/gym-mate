import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gymmate/calendar_screen.dart';
import 'package:gymmate/custom_widgets/buttom_navbar.dart';
import 'package:gymmate/edit_profile_screen.dart';
import 'package:gymmate/measurments_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/UsersApi/get-profile'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildProfileImage(String? base64String) {
  if (base64String == null || base64String.isEmpty) {
    return const CircleAvatar(
      radius: 50,
      backgroundColor: Color.fromARGB(255, 235, 94, 40),
      child: Icon(Icons.person_2_outlined, size: 80, color: Colors.white),
    );
  }

  try {
    // حذف prefix مثل data:image/png;base64,
    final cleanedBase64 = base64String.split(',').last;
    Uint8List bytes = base64Decode(cleanedBase64);

    return CircleAvatar(
      radius: 50,
      backgroundImage: MemoryImage(bytes),
      backgroundColor: Colors.transparent,
    );
  } catch (e) {
    print('Error decoding image: $e');
    return const CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey,
      child: Icon(Icons.image_not_supported, size: 60, color: Colors.white),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(child: Text("Failed to load profile", style: TextStyle(color: Colors.white)))
          : buildProfileBody(),
      bottomNavigationBar: MyBottomNavBar(currentIndex: 1),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      toolbarHeight: 80,
      leadingWidth: 80,
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
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          },
          child: const Text(
            'Edit Profile',
            style: TextStyle(
              color: Color.fromARGB(255, 235, 94, 40),
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProfileBody() {
    final String fullName = "${userData!['name']} ${userData!['lastName']}";
    final String email = userData!['userName'];
    final String? imageBase64 = userData!['imageBase64'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Row(
            children: [
              buildProfileImage(userData!['imageBase64']),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),

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
                  icon: const Icon(Icons.accessibility,
                      color: Colors.white, size: 30),
                  label: const Text('BMI calculator', style: TextStyle(fontSize: 18)),
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
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Log out"),
                        content: const Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.remove('jwtToken');
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    (route) => false,
                              );
                            },
                            child: const Text("Log Out"),
                          ),
                        ],
                      ),
                    );
                  },

                  icon: const Icon(Icons.logout, color: Colors.white, size: 30),
                  label: const Text('Logout', style: TextStyle(fontSize: 18)),
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
    );
  }
}
