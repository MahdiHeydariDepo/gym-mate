import 'package:flutter/material.dart';

class CreateRoutinePage extends StatefulWidget {
  final List<Map<String, String>> selectedExercises;
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

  @override
  void initState() {
    super.initState();
    for (var exercise in widget.selectedExercises) {
      exerciseSets[exercise['name']!] = [
        {'set': 1, 'reps': 0, 'weight': 0}
      ];
    }
  }

  void addSet(String exerciseName) {
    final sets = exerciseSets[exerciseName]!;
    final newSet = {
      'set': sets.length + 1,
      'reps': 0,
      'weight': 0,
    };
    setState(() {
      sets.add(newSet);
    });
  }

  void updateValue(String exerciseName, int index, String field, int change) {
    setState(() {
      exerciseSets[exerciseName]![index][field] += change;
      if (exerciseSets[exerciseName]![index][field] < 0) {
        exerciseSets[exerciseName]![index][field] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.routineTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF252422),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: exerciseSets.keys.map((exerciseName) {
            final sets = exerciseSets[exerciseName]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2A27),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Set ${set['set']}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const Spacer(),
                        _buildStepper(
                          label: 'Reps',
                          value: set['reps'].toString(),
                          onMinus: () => updateValue(exerciseName, index, 'reps', -1),
                          onPlus: () => updateValue(exerciseName, index, 'reps', 1),
                        ),
                        const SizedBox(width: 10),
                        _buildStepper(
                          label: 'Kg',
                          value: set['weight'].toString(),
                          onMinus: () => updateValue(exerciseName, index, 'weight', -1),
                          onPlus: () => updateValue(exerciseName, index, 'weight', 1),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => addSet(exerciseName),
                    icon: const Icon(Icons.add, color: Color(0xFFEB5E28)),
                    label: const Text(
                      'Add Set',
                      style: TextStyle(color: Color(0xFFEB5E28)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEB5E28),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final payload = {
              'routineTitle': widget.routineTitle,
              'exercises': exerciseSets,
            };
            print(payload); // Replace with API call
          },
          child: const Text(
            'Save Routine',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildStepper({
    required String label,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onMinus,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onPlus,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
