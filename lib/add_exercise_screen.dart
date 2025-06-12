import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gymmate/creat_routine_screen.dart'; // Make sure this import points to your actual routine screen
import 'package:gymmate/custom_widgets/buttom_navbar.dart';

class AddExercisePage extends StatefulWidget {
  final String? routineTitle;
  final List<Map<String, dynamic>>? preselectedExercises;
  final bool isEditing;
  final int? routineId;

  const AddExercisePage({
    Key? key,
    this.routineTitle,
    this.preselectedExercises,
    this.isEditing = false,
    this.routineId,
  }) : super(key: key);

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> allExercises = [];
  TextEditingController _routineTitleController = TextEditingController();
  final List<String> selectedMuscles = [];
  final List<Map<String, dynamic>> selectedExercises = [];

  @override
  void initState() {
    super.initState();
    fetchExercises();
    if (widget.preselectedExercises != null) {
      selectedExercises.addAll(widget.preselectedExercises!);
    }

    if (widget.routineTitle != null) {
      _routineTitleController.text = widget.routineTitle!;
    }
  }

  Future<void> fetchExercises() async {
    final url = Uri.parse('http://10.0.2.2:5000/Routine/GetExercises');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Map<String, String>> exercises = data.map<Map<String, String>>((item) {
          return {
            'exerciseId': item['exerciseId']?.toString() ?? '', // 🔧 اصلاح کلید
            'name': item['name'] ?? '',
            'muscle': item['muscleGroupName'] ?? '',
            'image': item['exerImgBase64'] ?? '',
            'description': item['description'] ?? '',
          };
        }).toList();

        // 🐞 Debug Log:
        for (var e in exercises) {
          print('Fetched Exercise → ID: ${e['exerciseId']}, Name: ${e['name']}');
        }

        setState(() {
          allExercises = exercises;
        });
      } else {
        print('Failed to fetch exercises: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exercises: $e');
    }
  }




  @override
  void dispose() {
    _routineTitleController.dispose();
    super.dispose();
  }

  void _openFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2A27),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final List<String> muscleGroups = [
          'All Muscles',
          'Chest',
          'Lats',
          'Shoulders',
          'Upper Back',
          'Triceps',
        ];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Muscle Group',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 12),
              ...muscleGroups.map((muscle) {
                return ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.white),
                  title: Text(
                    muscle,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      if (muscle == 'All Muscles') {
                        selectedMuscles.clear();
                      } else {
                        if (!selectedMuscles.contains(muscle)) {
                          selectedMuscles.add(muscle);
                        }
                      }
                    });
                    Navigator.pop(context);
                  },

                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, String>> get filteredExercises {
    return allExercises.where((exercise) {
      final matchesSearch = exercise['name']!.toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      final matchesMuscle =
          selectedMuscles.isEmpty ||
          selectedMuscles.contains(exercise['muscle']);
      return matchesSearch && matchesMuscle;
    }).toList();
  }


  Widget buildBase64Image(String base64String) {
    if (base64String.isEmpty) {
      return const Icon(Icons.image, color: Colors.grey);
    }
    try {
      Uint8List bytes = base64Decode(base64String);
      return Image.memory(bytes, width: 48, height: 48, fit: BoxFit.cover);
    } catch (e) {
      return const Icon(Icons.broken_image, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF252422),
        title: const Text(
          'Add Exercise',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        toolbarHeight: 80,
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color.fromARGB(255, 235, 94, 40),
              fontSize: 18,
            ),
          ),
        ),
        actions: [], // Save button removed
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _routineTitleController,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: 'Routine title',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[900],
                      hintText: 'Search exercise',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _openFilterDialog,
                  child: const Text(
                    'All Muscles',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children:
                  selectedMuscles.map((muscle) {
                    return Chip(
                      backgroundColor: const Color(0xFFEB5E28),
                      label: Text(
                        muscle,
                        style: const TextStyle(color: Colors.white),
                      ),
                      deleteIcon: const Icon(Icons.close, color: Colors.white),
                      onDeleted: () {
                        setState(() => selectedMuscles.remove(muscle));
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = filteredExercises[index];
                  final isSelected = selectedExercises.any(
                    (e) => e['name'] == exercise['name'],
                  );
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedExercises.removeWhere(
                            (e) => e['name'] == exercise['name'],
                          );
                        } else {
                          selectedExercises.add(exercise);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey[800],
                                child: ClipOval(
                                  child: buildBase64Image(exercise['image'] ?? ''),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEB5E28),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          exercise['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          exercise['muscle']!,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEB5E28),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (widget.isEditing) {
                    // EDIT FLOW: return selected exercises back to EditRoutinePage
                    Navigator.pop(context, selectedExercises);
                  } else {
                    // CREATE FLOW: move forward to CreateRoutinePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => CreateRoutinePage(
                              selectedExercises: selectedExercises.toList(),
                              routineTitle: _routineTitleController.text.trim(),
                            ),
                      ),
                    );
                  }
                },
                child: Text(
                  'Add ${selectedExercises.length} exercise${selectedExercises.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(currentIndex: 0),
    );
  }
}
