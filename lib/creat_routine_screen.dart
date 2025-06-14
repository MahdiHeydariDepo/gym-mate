import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gymmate/add_exercise_screen.dart';
import 'package:gymmate/custom_widgets/buttom_navbar.dart';
import 'package:gymmate/workout_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CreateRoutinePage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedExercises;
  final String routineTitle;

  const CreateRoutinePage({
    Key? key,
    required this.selectedExercises,
    required this.routineTitle,
  }) : super(key: key);

  @override
  State<CreateRoutinePage> createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends State<CreateRoutinePage> {
  final Map<String, List<Map<String, dynamic>>> exerciseSets = {};
  late TextEditingController _routineTitleController;

  @override
  void initState() {
    super.initState();
    _routineTitleController = TextEditingController(text: widget.routineTitle);
    for (var exercise in widget.selectedExercises) {
      exerciseSets[exercise['name']!] = [
        {'set': 1, 'reps': 0, 'weight': 0},
      ];
    }
  }

  void addSet(String exerciseName) {
    final sets = exerciseSets[exerciseName]!;
    final newSet = {'set': sets.length + 1, 'reps': 0, 'weight': 0};
    setState(() => sets.add(newSet));
  }

  void updateValue(String exerciseName, int index, String field, int change) {
    setState(() {
      exerciseSets[exerciseName]![index][field] += change;
      if (exerciseSets[exerciseName]![index][field] < 0) {
        exerciseSets[exerciseName]![index][field] = 0;
      }
    });
  }

  Widget buildBase64Image(String base64String) {
    try {
      Uint8List bytes = base64Decode(base64String);
      return Image.memory(bytes, width: 48, height: 48, fit: BoxFit.cover);
    } catch (e) {
      return const Icon(Icons.image_not_supported, color: Colors.grey);
    }
  }

  Future<void> saveRoutine() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    for (var exercise in widget.selectedExercises) {
      print('Selected exercise: ${exercise['name']} with id ${exercise['id']}');
    }

    if (token == null) {
      _showErrorDialog("Token not found. Please login again.");
      return;
    }

    final String title = _routineTitleController.text.trim();
    if (title.isEmpty) {
      _showErrorDialog("Please enter a routine title.");
      return;
    }

    final exercises = <Map<String, dynamic>>[];

    for (var exercise in widget.selectedExercises) {
      final name = exercise['name']!;
      final id = int.tryParse(
        (exercise['exerciseId'] ?? exercise['id'] ?? '0').toString(),
      );

      if (id == 0) {
        print('⚠️ Invalid exerciseId for $name: $id');
        continue;
      }

      final sets = exerciseSets[name] ?? [];

      for (var set in sets) {
        exercises.add({
          'exerciseId': id,
          'name': name,
          'set': set['set'],
          'reps': set['reps'],
          'weight': set['weight'],
        });
      }
    }

    final payload = {'name': title, 'exercises': exercises};

    try {
      print("Sending payload:");
      print(jsonEncode(payload));

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/Routine/AddRoutine'),
        headers: {
          'Content-Type': 'application/json-patch+json', // ← اصلاح شده
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Routine saved successfully!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => WorkoutScreen()),
                  );
                },
              ),
            ],
          ),
        );

      } else {
        _showErrorDialog(
          "Failed to save routine (${response.statusCode})\n\n${response.body}",
        );
      }
    } catch (e) {
      _showErrorDialog("Error occurred while saving routine: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
          for (var exercise in widget.selectedExercises) {
        final name = exercise['name'];
        if (!exerciseSets.containsKey(name)) {
          exerciseSets[name] = [
            {'set': 1, 'reps': 0, 'weight': 0},
          ];
        }
      }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leadingWidth: 120,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFFEB5E28)),
          ),
        ),
        title: const Text(
          'Create Routine',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF252422),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("Confirm Save"),
                      content: const Text(
                        "Are you sure you want to save this routine?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop(); // close confirmation dialog
                            saveRoutine(); // then save
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEB5E28),
                          ),
                          child: const Text("Save"),
                        ),
                      ],
                    ),
              );
            },

            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFEB5E28)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Routine title',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white24),
            TextField(
              controller: _routineTitleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter routine name...',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 20),
            
            
            ...exerciseSets.entries.map((entry) {
              final exerciseName = entry.key;
              final sets = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white24,
                        child: buildBase64Image(
                          widget.selectedExercises.firstWhere(
                                (ex) => ex['name'] == exerciseName,
                                orElse: () => {'image': ''},
                              )['image'] ??
                              '',
                        ),
                      ),

                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          exerciseName,
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
                        child: Center(
                          child: Text(
                            'Set',
                            style: TextStyle(color: Colors.white38),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: Text(
                            'Weight',
                            style: TextStyle(color: Colors.white38),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: Text(
                            'Reps',
                            style: TextStyle(color: Colors.white38),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...sets.asMap().entries.map((setEntry) {
                    final index = setEntry.key;
                    final set = setEntry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
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
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: _buildStepper(
                              set['weight'].toString(),
                              () => updateValue(
                                exerciseName,
                                index,
                                'weight',
                                -1,
                              ),
                              () =>
                                  updateValue(exerciseName, index, 'weight', 1),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: _buildStepper(
                              set['reps'].toString(),
                              () =>
                                  updateValue(exerciseName, index, 'reps', -1),
                              () => updateValue(exerciseName, index, 'reps', 1),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => addSet(exerciseName),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add Set',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEB5E28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          elevation: 4,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color(0xFFEB5E28),
                        ),
                        onPressed: () {
                          setState(() {
                            if (exerciseSets[exerciseName]!.length > 1) {
                              exerciseSets[exerciseName]!.removeLast();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => AddExercisePage(
                            preselectedExercises: widget.selectedExercises,
                            routineTitle: _routineTitleController.text,
                            isEditing: false, // or true if appropriate
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEB5E28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Add exercise',
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildStepper(
    String value,
    VoidCallback onMinus,
    VoidCallback onPlus,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white, size: 22),
            onPressed: onMinus,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            padding: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 22),
            onPressed: onPlus,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
