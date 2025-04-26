import 'package:flutter/material.dart';
import 'package:gymmate/custom_widgets/buttom_navbar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // TODO: Save profile data to backend (ASP.NET)
    final name = _nameController.text;
    final lastName = _lastNameController.text;
    final email = _emailController.text;

    print('Saving: $name $lastName $email');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 36, 34),
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color.fromARGB(255, 235, 94, 40),
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color.fromARGB(255, 235, 94, 40),
                child: Icon(Icons.person_2_outlined, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // TODO: Change profile picture logic
                },
                child: const Text(
                  'Change Picture',
                  style: TextStyle(
                    color: Color.fromARGB(255, 235, 94, 40),
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextFieldRow('Name', _nameController, 'User Name'),
              const Divider(color: Colors.white24),
              _buildTextFieldRow('Last Name', _lastNameController, 'User Last Name'),
              const Divider(color: Colors.white24),
              _buildTextFieldRow('Email', _emailController, 'User Email Address'),
              const Divider(color: Colors.white24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(currentIndex: 1)
    );
  }

  Widget _buildTextFieldRow(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
