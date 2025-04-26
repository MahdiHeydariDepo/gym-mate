import 'package:flutter/material.dart';
import 'package:gymmate/custom_widgets/buttom_navbar.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void _saveMeasurements() {
    final weight = weightController.text.trim();
    final height = heightController.text.trim();
    // TODO: Send updated measurements to your ASP.NET backend here.

    print('Saving Measurements: Weight: $weight, Height: $height');
    Navigator.pop(context); // After saving, go back to Profile or wherever you want
  }

  /*void _onTabTapped(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/workout');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 36, 34),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Measurements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveMeasurements,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color.fromARGB(255, 235, 94, 40),
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.accessibility,
              color: Color.fromARGB(255, 235, 94, 40),
              size: 100,
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Measurements',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextFieldRow('Body Weight (kg)', '50', weightController),
            const Divider(color: Colors.white30),
            _buildTextFieldRow('Height(m)', '160', heightController),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(currentIndex: 1)
    );
  }

  Widget _buildTextFieldRow(
      String label, String hint, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
