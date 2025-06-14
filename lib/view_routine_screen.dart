import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gymmate/custom_widgets/buttom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_routine_screen.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null || token.isEmpty) {
      debugPrint('No JWT token found.');
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    final url = Uri.parse('http://10.0.2.2:5000/Routine/GetRoutine?id=${widget.routineId}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          routineTitle = data['name'] ?? 'Untitled';
          exercises = List<Map<String, dynamic>>.from(data['exercises'] ?? []);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load routine');
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> deleteRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("توکن پیدا نشد")));
      return;
    }

    final url = Uri.parse('http://10.0.2.2:5000/Routine/DeleteRoutine?id=${widget.routineId}');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("روتین با موفقیت حذف شد")),
          );
          Navigator.pop(context, 'deleted');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("حذف با خطا مواجه شد")),
        );
      }
    } catch (e) {
      debugPrint('Error deleting routine: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطا در اتصال به سرور")),
      );
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
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFEB5E28)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditRoutinePage(
                    routineId: widget.routineId,
                    routineTitle: routineTitle,
                    routineExercises: exercises,
                    selectedExercises: exercises,
                  ),
                ),
              );

              if (result == 'updated') {
                fetchRoutineData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("delete Routinu"),
                  content: const Text("Are you sure?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancell"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        deleteRoutine();
                      },
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEB5E28)))
          : hasError
              ? const Center(child: Text('خطا در بارگذاری روتین', style: TextStyle(color: Colors.white)))
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
                                    exercise['name'] ?? '',
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
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 12, 12, 12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text('Sets', style: TextStyle(color: Colors.white38)),
                                        const SizedBox(height: 4),
                                        Text('${exercise['sets']}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text('Weight', style: TextStyle(color: Colors.white38)),
                                        const SizedBox(height: 4),
                                        Text('${exercise['weight']}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text('Reps', style: TextStyle(color: Colors.white38)),
                                        const SizedBox(height: 4),
                                        Text('${exercise['reps']}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
