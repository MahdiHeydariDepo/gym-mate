import 'package:flutter/material.dart';
import 'package:gymmate/profile_screen.dart';
import 'package:gymmate/workout_screen.dart';
import 'splash_screen.dart';
import 'login_screen.dart';

void main() {
  runApp(GymMateApp());
}

class GymMateApp extends StatelessWidget {
  const GymMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WorkoutScreen(),
      debugShowCheckedModeBanner: false,
      title: 'GYMMATE',
      theme: ThemeData.dark(), // optional, you can customize it
     // initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfileScreen(),
        '/workout' : (context) => WorkoutScreen()
      },
    );
  }
}
