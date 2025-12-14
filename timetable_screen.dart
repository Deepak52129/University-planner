import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final List<String> days = ["MON", "TUE", "WED", "THU", "FRI", "SAT"];

  final List<String> theoryTimes = [
    "08:00", "09:00", "10:00", "11:00", "12:00",
    "14:00", "15:00", "16:00"
  ];

  final List<String> labTimes = [
    "08:00–08:50", "08:51–09:40", "09:51–10:40",
    "10:41–11:30", "11:40–12:30",
    "14:00–14:50", "14:51–15:40", "15:51–16:40"
  ];

  Map<String, Map<String, dynamic>> timetableData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ---------------- STORAGE ----------------

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('timetable');
    if (data != null) {
      setState(() {
        timetableData =
            Map<String, Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('timetable', jsonEncode(timetableData));
  }

  // ---------------- COLOR LOGIC ----------------

  Color _colorFromAttendance(int att) {
    if (att >= 90) return Colors.green;
    if (att >= 80) return Colors.orange;
    return Colors.red;
  }

  // ---------------- DIALOG ----------------

  void _editBlock(String key) {
    String course = timetableData[key]?['course'] ?? '';
    String classNo = timetableData[key]?['class'] ?? '';
    String attendance =
        timetableData[key]?['attendance']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Class Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Course Code"),
              controller: TextEditingController(text: course),
              onChanged: (v) => course = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Class No"),
              controller: TextEditingController(text: classNo),
              onChanged: (v) => classNo = v,
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Attendance %"),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: attendance),
              onChanged: (v) => attendance = v,
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
              final att = int.tryParse(attendance) ?? 0;
              setState(() {
                timetableData[key] = {
                  'course': course,
                  'class': classNo,
                  'attendance': att,
                };
              });
              _saveData();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------

  Widget _headerRow(String label, List<String> times) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...times.map(
          (t) => Expanded(
            child: Center(
              child: Text(t,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _grid() {
    return Expanded(
      child: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, dayIndex) {
          return Row(
            children: [
              SizedBox(
                width: 70,
                child: Center(child: Text(days[dayIndex])),
              ),
              ...List.generate(theoryTimes.length, (slot) {
                final key = "${days[dayIndex]}_$slot";
                final data = timetableData[key];
                final color = data == null
                    ? Colors.grey[300]
                    : _colorFromAttendance(data['attendance']);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _editBlock(key),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      height: 60,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: data == null
                            ? const Text("")
                            : Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(data['course'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(data['class'],
                                      style:
                                          const TextStyle(fontSize: 12)),
                                ],
                              ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timetable"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _headerRow("THEORY", theoryTimes),
          const Divider(),
          _headerRow("LAB", labTimes),
          const Divider(thickness: 2),
          _grid(),
        ],
      ),
    );
  }
}
