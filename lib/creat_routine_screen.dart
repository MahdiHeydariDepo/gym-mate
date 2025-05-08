import 'package:flutter/material.dart';

class CreateRoutinePage extends StatefulWidget {
   final List<String> selectedExercises;
  final String routineTitle;

  const CreateRoutinePage({
    Key? key,
    required this.selectedExercises,
    required this.routineTitle,
  }) : super(key: key);
  @override
  _CreateRoutinePageState createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends State<CreateRoutinePage> {
  final Map<String, List<Map<String, int>>> exerciseSets = {};

  @override
  void initState() {
    super.initState();
    for (var exercise in widget.selectedExercises) {
      exerciseSets[exercise] = [
        {'weight': 0, 'reps': 0}
      ];
    }
  }

  void _addSet(String exerciseName) {
    setState(() {
      exerciseSets[exerciseName]!.add({'weight': 0, 'reps': 0});
    });
  }

  void _updateValue(String exerciseName, int index, String key, int newValue) {
    setState(() {
      exerciseSets[exerciseName]![index][key] = newValue;
    });
  }

  Widget _buildSetRow(String exerciseName, int index) {
    final set = exerciseSets[exerciseName]![index];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('Set ${index + 1}', style: const TextStyle(color: Colors.white)),

        // Weight Controls
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white),
              onPressed: () {
                if (set['weight']! > 0) {
                  _updateValue(exerciseName, index, 'weight', set['weight']! - 1);
                }
              },
            ),
            SizedBox(
              width: 40,
              child: TextFormField(
                initialValue: set['weight'].toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
                onChanged: (val) {
                  final value = int.tryParse(val);
                  if (value != null) {
                    _updateValue(exerciseName, index, 'weight', value);
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                _updateValue(exerciseName, index, 'weight', set['weight']! + 1);
              },
            ),
            const Text("kg", style: TextStyle(color: Colors.white)),
          ],
        ),

        // Reps Controls
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white),
              onPressed: () {
                if (set['reps']! > 0) {
                  _updateValue(exerciseName, index, 'reps', set['reps']! - 1);
                }
              },
            ),
            SizedBox(
              width: 40,
              child: TextFormField(
                initialValue: set['reps'].toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
                onChanged: (val) {
                  final value = int.tryParse(val);
                  if (value != null) {
                    _updateValue(exerciseName, index, 'reps', value);
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                _updateValue(exerciseName, index, 'reps', set['reps']! + 1);
              },
            ),
            const Text("reps", style: TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }

  void _submitRoutine() {
    // Simulate sending data to API
    print("Submitting routine:");
    exerciseSets.forEach((exercise, sets) {
      print("Exercise: $exercise");
      for (var i = 0; i < sets.length; i++) {
        print("  Set ${i + 1}: ${sets[i]['weight']}kg x ${sets[i]['reps']} reps");
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Routine submitted (simulated)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Create Routine"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: widget.selectedExercises.length,
        itemBuilder: (context, i) {
          final exerciseName = widget.selectedExercises[i];
          final sets = exerciseSets[exerciseName]!;

          return Card(
            color: Colors.grey[850],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(sets.length, (index) => _buildSetRow(exerciseName, index)),
                  TextButton.icon(
                    onPressed: () => _addSet(exerciseName),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Add Set", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _submitRoutine,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Submit Routine", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
