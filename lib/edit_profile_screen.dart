import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
  Uint8List? _imageBytes; // For Base64 image

  @override
  void initState() {
    super.initState();
    _loadTokenAndProfile();
  }

  Future<void> _loadTokenAndProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token != null) {
      _loadProfileData();
    } else {
      print('Token not found');
    }
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    print('Token: $token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/UsersApi/get-profile'),
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _nameController.text = data['name'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _emailController.text = data['userName'] ?? '';

        final imageBase64 = data['imageBase64'];
        if (imageBase64 != null && imageBase64.isNotEmpty) {
          final base64Str = imageBase64.split(',').last;
          _imageBytes = base64Decode(base64Str);
        }
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
        _imageBytes = null; // Reset loaded Base64 image if new image is picked
      });
    }
  }

  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    if (token == null) return;

    final uri = Uri.parse('http://10.0.2.2:5000/api/UsersApi/Update-profile');
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['UserName'] = _emailController.text;
    request.fields['Name'] = _nameController.text;
    request.fields['LastName'] = _lastNameController.text;

    if (_selectedImageFile != null) {
      final bytes = await _selectedImageFile!.readAsBytes();
      final base64Image = 'data:image/png;base64,' + base64Encode(bytes);
      request.fields['ImageBase64'] = base64Image;
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
                    : (_imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : null),
                child: (_selectedImageFile == null && _imageBytes == null)
                    ? const Icon(
                        Icons.person_2_outlined,
                        size: 80,
                        color: Colors.white,
                      )
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

  Widget _buildTextFieldRow(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
