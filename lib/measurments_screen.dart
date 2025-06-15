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
  String selectedSex = 'Male';

  double? _bmi;
  String _bmiCategory = '';
  Color _barColor = Colors.green;
  String _idealWeight = '';

  void _calculateBMI() {
    final weight = double.tryParse(weightController.text.trim());
    final height = double.tryParse(heightController.text.trim());

    if (weight == null || height == null || height <= 0) {
      setState(() {
        _bmi = null;
        _bmiCategory = 'Please enter valid weight and height';
        _idealWeight = '';
      });
      return;
    }

    final bmi = weight / (height * height);
    String category;
    Color barColor;

    if (bmi < 16) {
      category = "Severely Underweight";
      barColor = Colors.red;
    } else if (bmi < 18.5) {
      category = "Underweight";
      barColor = Colors.orange;
    } else if (bmi < 25) {
      category = "Normal";
      barColor = Colors.green;
    } else if (bmi < 30) {
      category = "Overweight";
      barColor = Colors.yellow;
    } else if (bmi < 35) {
      category = "Obese Class I";
      barColor = Colors.orange.shade700;
    } else if (bmi < 40) {
      category = "Obese Class II";
      barColor = Colors.deepOrange;
    } else {
      category = "Obese Class III";
      barColor = Colors.red.shade900;
    }

    // Calculate Ideal Weight (Devine Formula)
    double heightCm = height * 100;
    double idealWeight;
    if (selectedSex == 'Male') {
      idealWeight = 50 + 0.9 * (heightCm - 152);
    } else {
      idealWeight = 45.5 + 0.9 * (heightCm - 152);
    }

    setState(() {
      _bmi = bmi;
      _bmiCategory = category;
      _barColor = barColor;
      _idealWeight = idealWeight.toStringAsFixed(1);
    });
  }

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
          'BMI Calculator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.accessibility_new_rounded, size: 100, color: Color.fromARGB(255, 235, 94, 40)),
            const SizedBox(height: 30),
            _buildTextField('Weight (kg)', '50', weightController),
            const SizedBox(height: 16),
            _buildTextField('Height (m)', '1.75', heightController),
            const SizedBox(height: 16),
            _buildSexDropdown(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 235, 94, 40),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Calculate BMI',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            if (_bmi != null) _buildResultSection(),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 235, 94, 40)),
        ),
      ),
    );
  }

  Widget _buildSexDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: DropdownButton<String>(
        dropdownColor: Colors.grey[850],
        value: selectedSex,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        items: ['Male', 'Female'].map((sex) {
          return DropdownMenuItem(
            value: sex,
            child: Text(sex),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedSex = value!;
          });
        },
      ),
    );
  }

  Widget _buildResultSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.2),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _bmi == null
          ? const SizedBox.shrink()
          : Column(
        key: ValueKey(_bmi),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0, end: _bmi!),
            builder: (context, value, _) => Text(
              'Your BMI: ${value.toStringAsFixed(1)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Category: $_bmiCategory',
            style: TextStyle(
              color: _barColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ideal Weight (Devine Formula): $_idealWeight kg',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),

          // Rounded Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(
                begin: 0,
                end: (_bmi! / 40).clamp(0.0, 1.0),
              ),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 16,
                backgroundColor: Colors.grey[800],
                color: _barColor,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

}
