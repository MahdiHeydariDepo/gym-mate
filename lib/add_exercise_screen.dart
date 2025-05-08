/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  List<Map<String, String>> allExercises = [];
  List<Map<String, String>> filteredExercises = [];
  Set<String> selectedExercises = {};
  String selectedMuscle = 'All';
  String searchQuery = '';
  bool isLoading = true;

  final List<String> muscles = ['All', 'Chest', 'Lats', 'Shoulders', 'Upper Back', 'Triceps'];

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    try {
      final response = await http.get(Uri.parse('https://your-api.com/api/exercises'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allExercises = List<Map<String, String>>.from(data.map((exercise) => {
                'name': exercise['name'],
                'muscle': exercise['muscle'],
                'imageUrl': exercise['imageUrl'],
              }));
          applyFilters();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load exercises');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void applyFilters() {
    setState(() {
      filteredExercises = allExercises
          .where((exercise) {
            final matchMuscle = selectedMuscle == 'All' || exercise['muscle'] == selectedMuscle;
            final matchSearch = exercise['name']!
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
            return matchMuscle && matchSearch;
          })
          .toList();
    });
  }

  void toggleExerciseSelection(String name) {
    setState(() {
      if (selectedExercises.contains(name)) {
        selectedExercises.remove(name);
      } else {
        selectedExercises.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 36, 34),
        title: const Text('Add Exercise', style: TextStyle(color: Colors.white)),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFFEB5E28))),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Save logic here
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFFEB5E28))),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEB5E28)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Routine title',
                          style: TextStyle(color: Colors.white70, fontSize: 18)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search exercise',
                                hintStyle: const TextStyle(color: Colors.white38),
                                filled: true,
                                fillColor: Colors.grey[900],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                searchQuery = value;
                                applyFilters();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            dropdownColor: Colors.grey[900],
                            value: selectedMuscle,
                            style: const TextStyle(color: Colors.white),
                            items: muscles
                                .map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedMuscle = value;
                                applyFilters();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];
                      final isSelected = selectedExercises.contains(exercise['name']);

                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: exercise['imageUrl'] ?? '',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(strokeWidth: 2),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image_not_supported, color: Colors.white24),
                            ),
                          ),
                          title: Text(exercise['name']!,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(exercise['muscle']!,
                              style: const TextStyle(color: Colors.white38)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Color(0xFFEB5E28))
                              : const Icon(Icons.circle_outlined, color: Colors.white24),
                          onTap: () => toggleExerciseSelection(exercise['name']!),
                        ),
                      );
                    },
                  ),
                ),
                if (selectedExercises.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEB5E28),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        // Handle adding selected exercises
                        print("Selected exercises: $selectedExercises");
                      },
                      child: Text('Add ${selectedExercises.length} exercise(s)',
                          style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  )
              ],
            ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gymmate/creat_routine_screen.dart'; // Make sure this import points to your actual routine screen
import 'package:gymmate/custom_widgets/buttom_navbar.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({Key? key}) : super(key: key);

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> allExercises = [
    {
      'name': 'Bench Press',
      'muscle': 'Chest',
      'image': 'https://via.placeholder.com/48',
    },
    {
      'name': 'Bicep Curl',
      'muscle': 'Biceps',
      'image': 'https://via.placeholder.com/48',
    },
    {
      'name': 'Face Pull',
      'muscle': 'Shoulders',
      'image': 'https://via.placeholder.com/48',
    },
    {
      'name': 'Deadlift',
      'muscle': 'Hamstrings',
      'image': 'https://via.placeholder.com/48',
    },
  ];

  TextEditingController _routineTitleController = TextEditingController();
  final List<String> selectedMuscles = [];
  final Set<String> selectedExercises = {};

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
                        selectedMuscles.add(muscle);
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
      final matchesMuscle = selectedMuscles.isEmpty ||
          selectedMuscles.contains(exercise['muscle']);
      return matchesSearch && matchesMuscle;
    }).toList();
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
              children: selectedMuscles.map((muscle) {
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
                  final isSelected =
                      selectedExercises.contains(exercise['name']);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedExercises.remove(exercise['name']);
                        } else {
                          selectedExercises.add(exercise['name']!);
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
                                backgroundImage: CachedNetworkImageProvider(
                                  exercise['image']!,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateRoutinePage(
                        selectedExercises: selectedExercises.toList(),
                        routineTitle: _routineTitleController.text.trim(),
                      ),
                    ),
                  );
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
