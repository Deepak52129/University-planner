import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  List<Map<String, String>> subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  // 🔹 LOAD SUBJECTS
  Future<void> _loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('subjects');

    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() {
        subjects = decoded.map((e) => Map<String, String>.from(e)).toList();
      });
    }
  }

  // 🔹 SAVE SUBJECTS
  Future<void> _saveSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subjects', jsonEncode(subjects));
  }

  void _addSubject() {
    String courseName = '';
    String courseCode = '';
    String professor = '';
    String type = 'ETH';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Subject"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Course Name"),
              onChanged: (v) => courseName = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Course Code"),
              onChanged: (v) => courseCode = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Professor"),
              onChanged: (v) => professor = v,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: "Type"),
              items: const [
                DropdownMenuItem(value: "ETH", child: Text("ETH")),
                DropdownMenuItem(value: "ELA", child: Text("ELA")),
              ],
              onChanged: (v) => type = v!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (courseName.isNotEmpty && courseCode.isNotEmpty) {
                setState(() {
                  subjects.add({
                    'name': courseName,
                    'code': courseCode,
                    'professor': professor,
                    'type': type,
                  });
                });
                _saveSubjects(); // 🔥 SAVE HERE
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subjects"),
        backgroundColor: Colors.deepPurple,
      ),
      body: subjects.isEmpty
          ? const Center(
              child: Text(
                "No subjects added yet",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final s = subjects[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      "${s['name']} (${s['code']})",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Professor: ${s['professor']}\nType: ${s['type']}",
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubject,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
