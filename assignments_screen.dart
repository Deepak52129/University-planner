import 'package:flutter/material.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assignments"),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          "Your Assignments Will Appear Here",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
