import 'package:flutter/material.dart';
import 'package:gymmate/add_exercise_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:gymmate/custom_widgets/buttom_navbar.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<dynamic> routines = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRoutines();
  }

  Future<void> fetchRoutines() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-api.com/api/routines'), // Replace with actual endpoint
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          routines = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load routines');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
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
          'Workout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Routines',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddExercisePage(),
                        ),
                      );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'New Routine',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  //side: const BorderSide(color: Colors.white24, width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color:Color.fromARGB(255, 235, 94, 40),))
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Color.fromARGB(255, 235, 94, 40),),
                          ),
                        )
                      : routines.isEmpty
                          ? const Center(
                              child: Text(
                                'No routines found.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              itemCount: routines.length,
                              itemBuilder: (context, index) {
                                final routine = routines[index];
                                return Card(
                                  color: Colors.grey[900],
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      routine['title'] ?? 'Untitled Routine',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 235, 94, 40),),
                                    onTap: () {
                                      // TODO: Navigate to routine detail
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(currentIndex: 0),
    );
  }
}