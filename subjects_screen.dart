import 'package:flutter/material.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subjects"),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          "Your Subjects Will Appear Here",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
