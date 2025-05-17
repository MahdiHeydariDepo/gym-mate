import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gymmate/custom_widgets/buttom_navbar.dart';

class ViewRoutinePage extends StatefulWidget {
  final String routineId;

  const ViewRoutinePage({Key? key, required this.routineId}) : super(key: key);

  @override
  State<ViewRoutinePage> createState() => _ViewRoutinePageState();
}

class _ViewRoutinePageState extends State<ViewRoutinePage> {
  String routineTitle = '';
  List<Map<String, dynamic>> exercises = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchRoutineData();
  }

  Future<void> fetchRoutineData() async {
    final url = Uri.parse('https://your-api.com/api/routines/${widget.routineId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          routineTitle = data['title'] ?? 'Untitled';
          exercises = List<Map<String, dynamic>>.from(data['exercises'] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load routine');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      debugPrint('Error fetching routine: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Back',
            style: TextStyle(color: Color(0xFFEB5E28), fontSize: 16),
          ),
        ),
        title: const Text(
          'View Routine',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF252422),
        actions: [
          TextButton(
            onPressed: () {
              // Future Edit functionality
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: Color(0xFFEB5E28), fontSize: 16),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEB5E28)))
          : hasError
              ? const Center(child: Text('Error loading routine', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Routine Title',
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                      Text(
                        routineTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEB5E28),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Exercises',
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ...exercises.map((exercise) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    exercise['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFFEB5E28),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: const [
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Set',
                                      style: TextStyle(color: Colors.white38),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Weight',
                                      style: TextStyle(color: Colors.white38),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Reps',
                                      style: TextStyle(color: Colors.white38),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...List<Map<String, dynamic>>.from(exercise['sets'] ?? []).map((set) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 12, 12, 12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: Text(
                                          '${set['set']}',
                                          style: const TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Center(
                                        child: Text(
                                          '${set['weight']}',
                                          style: const TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Center(
                                        child: Text(
                                          '${set['reps']}',
                                          style: const TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 24),
                          ],
                        );
                      }).toList(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
      bottomNavigationBar: MyBottomNavBar(currentIndex: 0),
    );
  }
}
