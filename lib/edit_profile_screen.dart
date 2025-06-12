import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gymmate/custom_widgets/buttom_navbar.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _selectedImageFile;
  String? _token;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadTokenAndProfile();
  }

  Future<void> _loadTokenAndProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _email = prefs.getString('email');

    if (_token != null && _email != null) {
      _loadProfileData();
    } else {
      print('Token or email not found');
    }
  }

  Future<void> _loadProfileData() async {
    final uri = Uri.parse('https://10.0.2.2:5000/api/UsersApi/GetProfile?email=$_email');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _nameController.text = data['name'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _emailController.text = data['userName'] ?? '';
      });
    } else {
      print('Failed to load profile: ${response.statusCode}');
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_token == null) return;

    final uri = Uri.parse('http://10.0.2.2:5000/api/UsersApi/UpdateProfile');

    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $_token'
      ..fields['UserName'] = _emailController.text
      ..fields['Name'] = _nameController.text
      ..fields['LastName'] = _lastNameController.text;

    if (_selectedImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('Image', _selectedImageFile!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Profile updated!');
      if (mounted) Navigator.pop(context);
    } else {
      final respStr = await response.stream.bytesToString();
      print('Update failed: ${response.statusCode} - $respStr');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
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
                backgroundImage: _selectedImageFile != null
                    ? FileImage(_selectedImageFile!)
                    : null,
                child: _selectedImageFile == null
                    ? const Icon(Icons.person_2_outlined, size: 80, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _pickImage,
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
      bottomNavigationBar: MyBottomNavBar(currentIndex: 1),
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
