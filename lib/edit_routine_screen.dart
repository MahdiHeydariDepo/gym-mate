import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_exercise_screen.dart';
import 'custom_widgets/buttom_navbar.dart';

class EditRoutinePage extends StatefulWidget {
  final String routineId;
  final String routineTitle;
  final List<Map<String, dynamic>> routineExercises;
  final List<Map<String, dynamic>> selectedExercises;

  const EditRoutinePage({
    Key? key,
    required this.routineId,
    required this.routineTitle,
    required this.routineExercises,
    required this.selectedExercises,
  }) : super(key: key);

  @override
  State<EditRoutinePage> createState() => _EditRoutinePageState();
}

class _EditRoutinePageState extends State<EditRoutinePage> {
  late TextEditingController _routineTitleController;

  // ✅ نوع درست:
  late List<Map<String, dynamic>> _selectedExercises;

  final Map<String, List<Map<String, dynamic>>> exerciseSets = {};

  @override
  void initState() {
    super.initState();
    _routineTitleController = TextEditingController(text: widget.routineTitle);

    // ✅ کپی درست با نوع dynamic:
    _selectedExercises = List<Map<String, dynamic>>.from(widget.selectedExercises);

    for (var item in widget.routineExercises) {
      final name = item['name'];
      if (!exerciseSets.containsKey(name)) {
        exerciseSets[name] = [];
      }

      exerciseSets[name]!.add({
        'set': item['set'],
        'reps': item['reps'],
        'weight': item['weight'],
        'exerciseId': item['exerciseId'],
      });
    }
  }

  @override
  void dispose() {
    _routineTitleController.dispose();
    super.dispose();
  }


  Future<void> _saveUpdatedRoutine() async {
    final updatedTitle = _routineTitleController.text.trim();
    if (updatedTitle.isEmpty) {
      _showErrorDialog("Please enter a routine title.");
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final routineId = int.tryParse(widget.routineId);
    if (routineId == null) {
      _showErrorDialog("Invalid routine ID.");
      return;
    }

    try {
      // 1. Update Routine Name
      final nameResponse = await http.put(
        Uri.parse('http://10.0.2.2:5000/Routine/UpdateRoutineName'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json-patch+json',
        },
        body: jsonEncode({
          'routineId': routineId,
          'newName': updatedTitle,
        }),
      );

      if (nameResponse.statusCode != 200) {
        throw Exception('Failed to update routine name');
      }

      // 3. Add new exercises if not in the original list
      for (var exercise in _selectedExercises) {
        final exerciseId = exercise['exerciseId'];

        final isNew = !widget.routineExercises.any((e) => e['exerciseId'] == exerciseId);

        if (isNew) {
          final exerciseName = exercise['name'];
          final sets = exerciseSets[exerciseName];
          if (sets == null || sets.isEmpty) continue;

          final reps = sets[0]['reps'];
          final weight = sets[0]['weight'];

          final addResponse = await http.post(
            Uri.parse('http://10.0.2.2:5000/Routine/AddExerciseToRoutine'),
            headers: {
              'accept': '*/*',
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json-patch+json',
            },
            body: jsonEncode({
              'routineId': routineId,
              'exerciseId': exerciseId,
              'sets': 1,
              'reps': reps,
              'weight': weight,
            }),
          );

          if (addResponse.statusCode != 200) {
            throw Exception('Failed to add exercise $exerciseId');
          }
        }
      }


      // 2. Update each exercise set
      for (var entry in exerciseSets.entries) {
        for (var set in entry.value) {
          final exerciseId = set['exerciseId'];
          final reps = set['reps'];
          final weight = set['weight'];

          final exerciseResponse = await http.put(
            Uri.parse('http://10.0.2.2:5000/Routine/UpdateExerciseInRoutine'),
            headers: {
              'accept': '*/*',
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json-patch+json',
            },
            body: jsonEncode({
              'routineId': routineId,
              'exerciseId': exerciseId,
              'sets': 1,
              'reps': reps,
              'weight': weight,
            }),
          );

          if (exerciseResponse.statusCode != 200) {
            throw Exception('Failed to update exercise $exerciseId');
          }
        }
      }

      Navigator.pop(context, 'update'); // go back on success
    } catch (e) {
      _showErrorDialog('Failed to update routine: $e');
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

  void _updateSet(String exerciseName, int setIndex, String field,
      String value) {
    setState(() {
      if (field == 'reps') {
        exerciseSets[exerciseName]![setIndex]['reps'] =
            int.tryParse(value) ?? 0;
      } else if (field == 'weight') {
        exerciseSets[exerciseName]![setIndex]['weight'] =
            double.tryParse(value) ?? 0.0;
      }
    });
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text("OK"))
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Edit Routine',
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
                    (_) =>
                    AlertDialog(
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
                            _saveUpdatedRoutine();  // then save
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
                          )['image'] ?? '',),
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
                  ...sets
                      .asMap()
                      .entries
                      .map((setEntry) {
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
                                  () =>
                                  updateValue(
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
                                  () =>
                                  updateValue(exerciseName, index, 'reps', 1),
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
                onPressed: () async {
                  final selectedExercises = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddExercisePage(
                        isEditing: true,
                        preselectedExercises: _selectedExercises,
                        routineTitle: _routineTitleController.text,
                      ),
                    ),
                  );

                  if (selectedExercises != null) {
                    setState(() {
                      _selectedExercises = List<Map<String, dynamic>>.from(selectedExercises);
                    });
                  }
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