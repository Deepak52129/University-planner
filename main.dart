import 'package:flutter/material.dart';
import 'screens/subjects_screen.dart';
import 'screens/assignments_screen.dart';
import 'screens/timetable_screen.dart';

void main() {
  runApp(const UniversityPlannerApp());
}

class UniversityPlannerApp extends StatelessWidget {
  const UniversityPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),

      // NOTE: use Builder here so `context` below is inside the MaterialApp
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('University Planner'),
              backgroundColor: Colors.deepPurple,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome to University Planner!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: () {
                      // debug line to verify button press in console
                      // (you should see this printed in the terminal)
                      debugPrint('Subjects button pressed');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubjectsScreen()),
                      );
                    },
                    child: const Text("Subjects"),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      debugPrint('Assignments button pressed');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AssignmentsScreen()),
                      );
                    },
                    child: const Text("Assignments"),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      debugPrint('Timetable button pressed');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TimetableScreen()),
                      );
                    },
                    child: const Text("Timetable"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
